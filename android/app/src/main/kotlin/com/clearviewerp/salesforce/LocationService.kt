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
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit
import androidx.work.*
import kotlin.math.abs

class LocationService : Service() {
    companion object {
        private const val FILE_NAME = "locations.json"
        private const val MAX_STORED_LOCATIONS = 1000
        private const val MAX_BUFFER_SIZE = 10
        private var channel: MethodChannel? = null
        private var isTracking = false
        private var isFlutterEngineActive = false
        private val accuracyThreshold = 8.0
        private var locationBuffer: MutableList<Map<String, Any>> = mutableListOf()

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
                    Log.d("LocationService", "Successfully sent $method to Flutter")
                } else {
                    Log.d("LocationService", "Flutter engine not active, skipping $method")
                }
            } catch (e: Exception) {
                isFlutterEngineActive = false
                channel = null
                Log.e("LocationService", "Failed to invoke $method: ${e.message}")
            }
        }

        private fun getLocationFile(context: Context): File {
            return File(context.getDir("locations", Context.MODE_PRIVATE), FILE_NAME)
        }

        private fun loadExistingLocations(context: Context): JSONObject {
            val file = getLocationFile(context)
            return try {
                if (file.exists()) {
                    val content = file.readText()
                    JSONObject(content)
                } else {
                    createEmptyLocationFile()
                }
            } catch (e: Exception) {
                Log.e("LocationService", "Error loading location file: ${e.message}")
                createEmptyLocationFile()
            }
        }

        private fun createEmptyLocationFile(): JSONObject {
            return JSONObject().apply {
                put("version", "1.0")
                put("created", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()))
                put("locations", JSONArray())
                put("count", 0)
            }
        }

        private fun saveLocationsToFile(context: Context, locationData: JSONObject) {
            val file = getLocationFile(context)
            try {
                file.parentFile?.mkdirs() // Ensure directory exists
                file.writeText(locationData.toString(2)) // Pretty print with indent
                Log.d("LocationService", "Saved locations to file: ${file.path}")
            } catch (e: Exception) {
                Log.e("LocationService", "Error saving location file: ${e.message}")
            }
        }

        fun saveLocation(context: Context, locationData: Map<String, Any>) {
            try {
                val locationWithMetadata = locationData.toMutableMap().apply {
                    put("source", "android_native")
                }
                
                locationBuffer.add(locationWithMetadata)

                if (locationBuffer.size >= MAX_BUFFER_SIZE) {
                    saveBufferedLocations(context)
                }
            } catch (e: Exception) {
                Log.e("LocationService", "Failed to save location: ${e.message}")
            }
        }

        private fun saveBufferedLocations(context: Context) {
            if (locationBuffer.isEmpty()) return

            val locationData = loadExistingLocations(context)
            val existingLocations = locationData.optJSONArray("locations") ?: JSONArray()

            locationBuffer.forEach { location ->
                existingLocations.put(JSONObject(location))
            }

            // Sort by timestamp
            val sortedLocations = JSONArray().apply {
                val tempList = (0 until existingLocations.length())
                    .map { existingLocations.getJSONObject(it) }
                    .sortedBy { it.optLong("timestamp", 0) }
                tempList.forEach { put(it) }
            }

            // Limit to MAX_STORED_LOCATIONS
            while (sortedLocations.length() > MAX_STORED_LOCATIONS) {
                sortedLocations.remove(0)
            }

            locationData.put("locations", sortedLocations)
            locationData.put("updated", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).format(Date()))
            locationData.put("count", sortedLocations.length())

            saveLocationsToFile(context, locationData)
            Log.d("LocationService", "Saved ${locationBuffer.size} locations. Total: ${sortedLocations.length()}")
            locationBuffer.clear()
        }

        fun syncLocations(context: Context) {
            try {
                // Save any buffered locations first
                saveBufferedLocations(context)

                val locationData = loadExistingLocations(context)
                val locationsArray = locationData.optJSONArray("locations") ?: JSONArray()
                val locationList = mutableListOf<Map<String, Any>>()

                for (i in 0 until locationsArray.length()) {
                    locationList.add(locationsArray.getJSONObject(i).toMap())
                }

                if (locationList.isNotEmpty()) {
                    safeInvokeMethod("syncLocations", mapOf("data" to locationList))
                    if (isFlutterEngineActive) {
                        val emptyData = createEmptyLocationFile()
                        saveLocationsToFile(context, emptyData)
                        Log.d("LocationService", "Synced ${locationList.size} locations and cleared file")
                    }
                } else {
                    Log.d("LocationService", "No locations to sync")
                }
            } catch (e: Exception) {
                Log.e("LocationService", "Failed to sync locations: ${e.message}")
                safeInvokeMethod("error", mapOf("message" to "Failed to sync locations: ${e.message}"))
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
    private var lastLocationTime: Long = 0
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(1, notification)
        }

        trackingMode = intent?.getStringExtra("mode") ?: "foreground"
        startLocationUpdates()
        isTracking = true

        safeInvokeMethod("trackingStarted", mapOf("mode" to trackingMode))

        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        isTracking = false
        // Save any remaining buffered locations
        saveBufferedLocations(this)
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
                                    saveLocation(this@LocationService, locationData)
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

        val maxAge = when (trackingMode) {
            "significant", "periodic" -> 300_000L  // 5 minutes for background modes
            else -> 60_000L                        // 1 minute for active tracking
        }

        if (age > maxAge) {
            return false
        }

        if (accuracy <= 0.0) {
            return false
        }

        val maxAccuracy = when (trackingMode) {
            "foreground" -> 10.0
            else -> 15.0
        }

        if (accuracy > maxAccuracy) {
            return false
        }

        val minInterval = when (trackingMode) {
            "foreground" -> 1_000L      // 1 second
            "background" -> 3_000L
            "significant", "periodic" -> 3_000L
            else -> 1_000L
        }

        if (currentTime - lastLocationTime < minInterval) {
           Log.d("LocationService", "Rejected: Too frequent (${currentTime - lastLocationTime}ms < ${minInterval}ms)")
            return false
        }

        Log.d("LocationService", "✅ Accepted location (accuracy: ${String.format("%.1f", accuracy)}m)")
        lastLocationTime = currentTime
        return true
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