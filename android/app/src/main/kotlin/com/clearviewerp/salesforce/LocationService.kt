package com.clearviewerp.salesforce

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.ServiceInfo
import com.google.android.gms.location.*
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit
import androidx.work.*
import androidx.core.content.edit
import kotlin.math.abs

class LocationService : Service() {
    companion object {
        private const val PREFS_NAME = "LocationPrefs"
        private const val KEY_LOCATIONS = "pending_locations"
        private var channel: MethodChannel? = null
        private var isTracking = false
        private var isFlutterEngineActive = false
        private val accuracyThreshold = 8.0

        fun setMethodChannel(methodChannel: MethodChannel) {
            channel = methodChannel
            isFlutterEngineActive = true
        }

        fun getChannel(): MethodChannel? {
            return if (isFlutterEngineActive) channel else null
        }

        fun onFlutterEngineDestroyed() {
            isFlutterEngineActive = false
            channel = null
            Log.d("LocationService", "Flutter engine destroyed, channel cleared")
        }

        private fun safeInvokeMethod(method: String, arguments: Any?) {
            try {
                if (isFlutterEngineActive && channel != null) {
                    channel?.invokeMethod(method, arguments)
                    // Log.d("LocationService", "Successfully sent $method to Flutter")
                } else {
                   // Log.d("LocationService", "Flutter engine not active, skipping $method")
                }
            } catch (e: Exception) {
                isFlutterEngineActive = false
                channel = null
            }
        }

        fun saveLocationToPrefs(context: Context, locationData: Map<String, Any>) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
                prefs.edit {
                    val locations = prefs.getString(KEY_LOCATIONS, "[]")
                    val jsonArray = JSONArray(locations)
                    jsonArray.put(JSONObject(locationData))
                    putString(KEY_LOCATIONS, jsonArray.toString())
                }
            } catch (e: Exception) {
                // Log.e("LocationService", "Failed to save location to SharedPreferences: ${e.message}")
            }
        }

        fun syncLocations(context: Context) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
                val locations = prefs.getString(KEY_LOCATIONS, "[]")
                val jsonArray = JSONArray(locations)
                val locationList = mutableListOf<Map<String, Any>>()
                for (i in 0 until jsonArray.length()) {
                    locationList.add(jsonArray.getJSONObject(i).toMap())
                }
                
                if (locationList.isNotEmpty()) {
                    safeInvokeMethod("syncLocations", mapOf(
                        "data" to locationList
                    ))

                    if (isFlutterEngineActive) {
                        prefs.edit { putString(KEY_LOCATIONS, "[]") }
                    }
                } else {
                   // Log.d("LocationService", "No locations to sync")
                }
            } catch (e: Exception) {
               // Log.e("LocationService", "Failed to sync locations: ${e.message}")
            }
        }

        fun schedulePeriodicUpdate(context: Context, intervalSeconds: Double) {
            try {
                val minSeconds = TimeUnit.MINUTES.toSeconds(15)
                val validInterval = maxOf(intervalSeconds.toLong(), minSeconds) // Enforce 15-minute minimum
                val workRequest = PeriodicWorkRequestBuilder<LocationWorker>(
                    validInterval,
                    TimeUnit.SECONDS
                ).setConstraints(
                    Constraints.Builder().setRequiredNetworkType(NetworkType.NOT_REQUIRED).build()
                ).build()

                WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                    "locationWork",
                    ExistingPeriodicWorkPolicy.KEEP,
                    workRequest
                )
                safeInvokeMethod("log", mapOf("message" to "Scheduled periodic location update"))
            } catch (e: Exception) {
                safeInvokeMethod("error", mapOf("message" to "Failed to schedule periodic update: ${e.message}"))
            }
        }
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var locationCallback: LocationCallback? = null
    private var trackingMode: String = "foreground"
    private var distanceFilter: Float = 0f
    private var lastLocationTime: Long = 0
    private var maxLocationAge: Long = 30_000L
    private var lastValidLocation: android.location.Location? = null

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!PermissionUtils.canTrackLocation(this)) {
            safeInvokeMethod("error", mapOf("message" to "Location permissions not granted"))
            stopSelf()
            return START_NOT_STICKY
        }

        createNotificationChannel(this)
        val notification = NotificationCompat.Builder(this, "location_channel")
            .setContentTitle("Location Tracker Active")
            .setContentText("We tracking your location")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        // Use foregroundServiceType for Android 14+ (API 34+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(1, notification)
        }

        startLocationUpdates()
        isTracking = true

        safeInvokeMethod("trackingStarted", mapOf("mode" to trackingMode, "filter" to distanceFilter))

        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        isTracking = false

        safeInvokeMethod("trackingStopped", emptyMap<String, Any>())
        super.onDestroy()
    }

    private fun startLocationUpdates() {
        try {
            val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
                .setMinUpdateIntervalMillis(200L)
                .setMinUpdateDistanceMeters(2f)
                .setGranularity(Granularity.GRANULARITY_PERMISSION_LEVEL)
                .setWaitForAccurateLocation(false)
                .build()

            locationCallback = object : LocationCallback() {
                override fun onLocationResult(result: LocationResult) {
                    try {
                        result.lastLocation?.let { location ->

                            if (!isLocationAcceptable(location)) return

                            val locationData = mapOf(
                                "latitude" to location.latitude,
                                "longitude" to location.longitude,
                                "timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(
                                    Date(location.time)
                                ),
                                "accuracy" to location.accuracy,
                                "altitude" to location.altitude,
                                "speed" to maxOf(location.speed, 0f),
                                "provider" to "FusedLocation",
                                "trackingMode" to trackingMode
                            )

                            Handler(Looper.getMainLooper()).post {
                                if (isFlutterEngineActive && channel != null) {
                                    safeInvokeMethod("locationUpdate", locationData)
                                } else {
                                    saveLocationToPrefs(this@LocationService, locationData)
                                }
                            }
                        } ?: run {
                            safeInvokeMethod("error", mapOf("message" to "Location is null"))
                        }
                    } catch (e: Exception) {
                        safeInvokeMethod("error", mapOf("message" to "Failed to process location update: ${e.message}"))
                    }
                }
            }

            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        } catch (e: SecurityException) {
            safeInvokeMethod("error", mapOf("message" to "Permission error: ${e.message}"))
            stopSelf()
        } catch (e: Exception) {
            safeInvokeMethod("error", mapOf("message" to "Failed to start location updates: ${e.message}"))
            stopSelf()
        }
    }

    private fun isLocationAcceptable(location: android.location.Location): Boolean {
        val currentTime = System.currentTimeMillis()
        val age = abs(currentTime - location.time)
        val accuracy = location.accuracy.toDouble()
        val speed = maxOf(location.speed, 0f).toDouble()    // m/s
        val speedKMH = speed * 3.6                          // km/h

        Log.d("LocationService", "Location check: age=${age}ms, accuracy=${accuracy}m, speed=${speedKMH}km/h")

        // 1. age (milliseconds)
        if (age > maxLocationAge) {
            Log.d("LocationService", "Rejected: Location too old (age=${age}ms > ${maxLocationAge}ms)")
            return false
        }

        // 2. accuracy validity
        if (accuracy <= 0.0) {
            Log.d("LocationService", "Rejected: Invalid accuracy ($accuracy)")
            return false
        }

        // 3. speed-based required accuracy (meters)
        val requiredAccuracy = when {
            speedKMH > 80 -> accuracyThreshold * 1.2
            speedKMH > 50 -> accuracyThreshold
            speedKMH > 20 -> accuracyThreshold * 0.8
            else -> accuracyThreshold * 0.6
        }

        if (accuracy > requiredAccuracy) {
            Log.d("LocationService", "Rejected: Poor accuracy ($accuracy > $requiredAccuracy)")
            return false
        }

        // 4. stationary filtering
        if (speed < 0.5 && accuracy > accuracyThreshold) {
            Log.d("LocationService", "Rejected: Stationary with poor accuracy (speed=${speed} m/s, accuracy=${accuracy})")
            return false
        }

        // 5. adaptive interval (milliseconds)
        var adaptiveInterval = getSpeedBasedInterval(speedKMH)

        lastValidLocation?.let { lastLoc ->
            if (location.hasBearing() && lastLoc.hasBearing()) {
                val bearingChange = calculateBearingChange(lastLoc.bearing, location.bearing)
                adaptiveInterval = when {
                    bearingChange > 15f -> 2_000L   // 2s for sharp turn
                    bearingChange > 8f  -> 1_000L   // 1s for moderate turn
                    bearingChange > 3f  -> 500L     // 0.5s for gentle curve
                    else -> adaptiveInterval
                }
            }
        }

        // 6. time interval check: use location.time and adaptiveInterval (both ms)
        if (location.time - lastLocationTime < adaptiveInterval) {
            Log.d("LocationService", "Rejected: Too frequent: ${(location.time - lastLocationTime)}ms < $adaptiveInterval ms")
            return false
        }

        // 7. GPS jump detection (keep using location.time vs lastLoc.time)
        lastValidLocation?.let { lastLoc ->
            val distance = lastLoc.distanceTo(location) // meters
            val timeDiff = (location.time - lastLoc.time) / 1000.0 // seconds

            if (timeDiff > 0.5) {
                val calculatedSpeed = distance / timeDiff // m/s
                val speedDifference = abs(calculatedSpeed - speed)

                if (speed > 1.0 && speedDifference > (speed * 0.8)) {
                    Log.d("LocationService", "Rejected: GPS jump (calcSpeed=$calculatedSpeed m/s, reported=$speed m/s, diff=$speedDifference)")
                    return false
                }
            }
        }

        // accept: update state using the location timestamp so intervals stay consistent
        Log.w("LocationService","Accepted")
        lastValidLocation = location
        lastLocationTime = location.time
        return true
    }

    private fun getSpeedBasedInterval(speedKmh: Double): Long {
        return when {
            speedKmh > 80 -> 1_000L   // 1s (highway)
            speedKmh > 50 -> 1_500L   // 1.5s (city fast)
            speedKmh > 30 -> 2_000L   // 2s (city normal)
            speedKmh > 10 -> 3_000L   // 3s (slow roads)
            else -> 5_000L            // 5s (very slow/stationary)
        }
    }
    
    // Calculate bearing change between two points (for detecting turns)
    private fun calculateBearingChange(oldBearing: Float, newBearing: Float): Double {
        var diff = abs(newBearing - oldBearing).toDouble()
        if (diff > 180.0) {
            diff = 360.0 - diff
        }

        return diff
    }

    private fun stopLocationUpdates() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
        locationCallback = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "location_channel",
                "Location Tracking",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    // Add a method to safely invoke methods with fallback
    private fun safeInvokeMethod(method: String, arguments: Any?) =
        Companion.safeInvokeMethod(method, arguments)
}

fun JSONObject.toMap(): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    val keys = keys()
    while (keys.hasNext()) {
        val key = keys.next()
        try {
            val value = get(key)
            map[key] = when (value) {
                is JSONObject -> value.toMap()
                is JSONArray -> value.toList()
                else -> value
            }
        } catch (e: Exception) {
           // Log.e("JSONObject", "Error converting key $key: ${e.message}")
        }
    }
    return map
}

fun JSONArray.toList(): List<Any> {
    val list = mutableListOf<Any>()
    for (i in 0 until length()) {
        try {
            val value = get(i)
            list.add(when (value) {
                is JSONObject -> value.toMap()
                is JSONArray -> value.toList()
                else -> value
            })
        } catch (e: Exception) {
           // Log.e("JSONArray", "Error converting index $i: ${e.message}")
        }
    }
    return list
}