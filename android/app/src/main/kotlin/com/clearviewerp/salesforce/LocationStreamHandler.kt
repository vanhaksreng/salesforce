package com.clearviewerp.salesforce

import android.content.Context
import android.os.Looper
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import io.flutter.plugin.common.EventChannel
import java.lang.SecurityException

class LocationStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        if (PermissionUtils.canTrackLocation(context)) {
            startLocationUpdates()
        } else {
            eventSink?.error("PERMISSION_DENIED", "Location permissions or Google Play Services unavailable", null)
        }
    }

    override fun onCancel(arguments: Any?) {
        stopLocationUpdates()
        eventSink = null
    }

    private fun startLocationUpdates() {
        if (!PermissionUtils.canTrackLocation(context)) {
            eventSink?.error("PERMISSION_DENIED", "Location permissions or Google Play Services unavailable", null)
            return
        }

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10000)
            .setMinUpdateIntervalMillis(5000)
            .setMinUpdateDistanceMeters(10f)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.lastLocation?.let { location ->
                    val locationData = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "timestamp" to location.time,
                        "accuracy" to location.accuracy
                    )
                    eventSink?.success(locationData)
                }
            }
        }

        try {
            fusedLocationClient?.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        } catch (e: SecurityException) {
            eventSink?.error("SECURITY_EXCEPTION", "Permission error: ${e.message}", null)
            stopLocationUpdates()
        }
    }

    private fun stopLocationUpdates() {
        locationCallback?.let { fusedLocationClient?.removeLocationUpdates(it) }
        locationCallback = null
        fusedLocationClient = null
    }
}