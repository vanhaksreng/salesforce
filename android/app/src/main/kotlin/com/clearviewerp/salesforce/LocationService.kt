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

class LocationService : Service() {
    companion object {
        private const val CHANNEL_NAME = "com.clearviewerp.salesforce/background_service"
        private const val PREFS_NAME = "LocationPrefs"
        private const val KEY_LOCATIONS = "pending_locations"
        private var channel: MethodChannel? = null
        private var isTracking = false

        fun setMethodChannel(methodChannel: MethodChannel) {
            channel = methodChannel
        }

        fun getChannel(): MethodChannel? {
            return channel
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
                Log.d("LocationService", "Saved location to SharedPreferences: $locationData")
            } catch (e: Exception) {
                Log.e("LocationService", "Failed to save location to SharedPreferences: ${e.message}")
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
                    getChannel()?.invokeMethod("syncLocations", locationList)
                    Log.d("LocationService", "Synced ${locationList.size} locations to Flutter")
                }
                prefs.edit { putString(KEY_LOCATIONS, "[]") }
            } catch (e: Exception) {
                Log.e("LocationService", "Failed to sync locations: ${e.message}")
            }
        }

        fun schedulePeriodicUpdate(context: Context, intervalSeconds: Double) {
            try {
                val validInterval = maxOf(intervalSeconds.toLong(), 900L) // Enforce 15-minute minimum
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
                try {
                    channel?.invokeMethod("log", mapOf("message" to "Scheduled periodic location update"))
                } catch (e: Exception) {
                    Log.w("LocationService", "Failed to send log (Flutter engine likely detached): ${e.message}")
                }
            } catch (e: Exception) {
                try {
                    channel?.invokeMethod("error", mapOf("message" to "Failed to schedule periodic update: ${e.message}"))
                } catch (e: Exception) {
                    Log.w("LocationService", "Failed to send error (Flutter engine likely detached): ${e.message}")
                }
            }
        }
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var locationCallback: LocationCallback? = null
    private var trackingMode: String = "foreground"
    private var distanceFilter: Float = 10f
    private var lastLocationTime: Long = 0
    private val minUpdateInterval: Long = 30_000

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!PermissionUtils.canTrackLocation(this)) {
            try {
                channel?.invokeMethod("error", mapOf("message" to "Location permissions not granted"))
            } catch (e: Exception) {
                Log.w("LocationService", "Failed to send error (Flutter engine likely detached): ${e.message}")
            }
            stopSelf()
            return START_NOT_STICKY
        }

        createNotificationChannel(this)
        val notification = NotificationCompat.Builder(this, "location_channel")
            .setContentTitle("GPS Tracker Active")
            .setContentText("Tracking your location in the background")
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
        try {
            channel?.let {
                Log.d("LocationService", "Sending trackingStarted to Flutter")
                it.invokeMethod("trackingStarted", mapOf("mode" to trackingMode, "filter" to distanceFilter))
            } ?: Log.w("LocationService", "MethodChannel is null, skipping trackingStarted")
        } catch (e: Exception) {
            Log.w("LocationService", "Failed to send trackingStarted (Flutter engine likely detached): ${e.message}")
        }

        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        isTracking = false
        try {
            channel?.let {
                Log.d("LocationService", "Sending trackingStopped to Flutter")
                it.invokeMethod("trackingStopped", emptyMap<String, Any>())
            } ?: Log.w("LocationService", "MethodChannel is null, skipping trackingStopped")
        } catch (e: Exception) {
            Log.w("LocationService", "Failed to send trackingStopped (Flutter engine likely detached): ${e.message}")
        }
        super.onDestroy()
    }

    private fun isAppInForeground(context: Context): Boolean {
        val activityManager = context.getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
        val runningProcesses = activityManager.runningAppProcesses ?: return false
        val packageName = context.packageName
        return runningProcesses.any { process ->
            process.importance == android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND &&
                    process.pkgList.contains(packageName)
        }
    }

    private fun startLocationUpdates() {
        try {
            val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10000)
                .setMinUpdateIntervalMillis(5000)
                .setMinUpdateDistanceMeters(10f)
                .build()

            locationCallback = object : LocationCallback() {
                override fun onLocationResult(result: LocationResult) {
                    try {
                        result.lastLocation?.let { location ->
                            val now = System.currentTimeMillis()
                            if (trackingMode != "foreground" && now - lastLocationTime < minUpdateInterval) {
                                return
                            }

                            lastLocationTime = now
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
                                try {
                                    channel?.let {
                                        Log.d("LocationService", "Sending locationUpdate to Flutter: $locationData")
                                        it.invokeMethod("locationUpdate", locationData)
                                    } ?: run {
                                        Log.w("LocationService", "MethodChannel is null, saving location locally")
                                        saveLocationToPrefs(this@LocationService, locationData)
                                    }
                                } catch (e: Exception) {
                                    Log.w("LocationService", "Failed to send locationUpdate (Flutter engine likely detached): ${e.message}")
                                    saveLocationToPrefs(this@LocationService, locationData)
                                }
                            }
                        } ?: run {
                            Log.w("LocationService", "Location is null in onLocationResult")
                            try {
                                channel?.invokeMethod("error", mapOf("message" to "Location is null"))
                            } catch (e: Exception) {
                                Log.w("LocationService", "Failed to send error (Flutter engine likely detached): ${e.message}")
                            }
                        }
                    } catch (e: Exception) {
                        channel?.invokeMethod("error", mapOf("message" to "Failed to process location update: ${e.message}"))
                    }
                }
            }

            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        } catch (e: SecurityException) {
            Log.e("LocationService", "Permission error: ${e.message}")
            try {
                channel?.invokeMethod("error", mapOf("message" to "Permission error: ${e.message}"))
            } catch (e: Exception) {
                Log.w("LocationService", "Failed to send error (Flutter engine likely detached): ${e.message}")
            }
            stopSelf()
        } catch (e: Exception) {
            Log.e("LocationService", "Failed to start location updates: ${e.message}")
            try {
                channel?.invokeMethod("error", mapOf("message" to "Failed to start location updates: ${e.message}"))
            } catch (e: Exception) {
                Log.w("LocationService", "Failed to send error (Flutter engine likely detached): ${e.message}")
            }
            stopSelf()
        }
    }

    private fun stopLocationUpdates() {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
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
            Log.e("JSONObject", "Error converting key $key: ${e.message}")
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
            Log.e("JSONArray", "Error converting index $i: ${e.message}")
        }
    }
    return list
}