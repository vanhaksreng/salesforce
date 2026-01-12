package com.clearviewerp.salesforce

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.android.gms.location.LocationServices
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class LocationWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        try {
            val fusedLocationClient = LocationServices.getFusedLocationProviderClient(applicationContext)
            if (PermissionUtils.canTrackLocation(applicationContext)) {
                fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                    if (location != null) {
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
                            "trackingMode" to "periodic"
                        )

                        LocationService.saveLocation(applicationContext, locationData)
                    } else {
                        // Log.w("LocationWorker", "Location is null")
                    }
                }.addOnFailureListener { e ->
                   // Log.e("LocationWorker", "Failed to get location: ${e.message}")
                }
            } else {
               // Log.w("LocationWorker", "Location permissions not granted")
            }
            return Result.success()
        } catch (e: Exception) {
            return Result.failure()
        }
    }
}