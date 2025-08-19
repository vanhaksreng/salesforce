package com.clearviewerp.salesforce

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability

object PermissionUtils {
    // Check if location permissions are granted
    private fun hasLocationPermissions(context: Context): Boolean {
        val fineLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        val coarseLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        // At least one of fine or coarse location permission is required
        return fineLocation || coarseLocation
    }

    // Check background location permission (required for Android 10+)
    private fun hasBackgroundLocationPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { // API 29+
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true // Not required for API < 29
        }
    }

    fun canTrackWhileInUse(context: Context): Boolean {
        val fineLocation = ContextCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseLocation = ContextCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        return (fineLocation || coarseLocation) &&
        isGooglePlayServicesAvailable(context)
    }

    // Checks if the app can track location in the background ("Always")
    fun canTrackAlways(context: Context): Boolean {
        val fineLocation = ContextCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseLocation = ContextCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val backgroundLocation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED
        } else {
            true // Background permission not needed pre-Android 10
        }
        return (fineLocation || coarseLocation) && backgroundLocation &&
                isGooglePlayServicesAvailable(context)
    }

    // Check if Google Play Services is available
    private fun isGooglePlayServicesAvailable(context: Context): Boolean {
        val googleApiAvailability = GoogleApiAvailability.getInstance()
        val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(context)
        return resultCode == ConnectionResult.SUCCESS
    }

    fun canTrackLocation(context: Context, mode: String = "foreground"): Boolean {
        return hasLocationPermissions(context) &&
                (mode == "foreground" || hasBackgroundLocationPermission(context)) &&
                isGooglePlayServicesAvailable(context)
    }
    
    fun getPermissionStatus(context: Context): Map<String, Boolean> {
        return mapOf(
            "canTrackForeground" to hasLocationPermissions(context),
            "background" to hasBackgroundLocationPermission(context)
        )
    }
}