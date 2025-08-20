package com.clearviewerp.salesforce

import android.Manifest
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val htmlPdfChannel = "flutter_html_to_pdf"
    private val locationMethodChannel = "com.clearviewerp.salesforce/background_service"
    private val locationPermissionRequestCode = 101
    private var permissionResultCallback: ((Boolean) -> Unit)? = null
    private var pendingMode: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent?.getBooleanExtra("requestPermissions", false) == true) {
            requestPermissions("always")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the method channel for location service
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel)
        LocationService.setMethodChannel(methodChannel)
        LocationService.syncLocations(this)

        setupHtmlToPdfChannel(flutterEngine)
        setupLocationService(flutterEngine)
    }

    override fun onDestroy() {
        LocationService.onFlutterEngineDestroyed()
        super.onDestroy()
    }

    override fun detachFromFlutterEngine() {
        LocationService.onFlutterEngineDestroyed()
        super.detachFromFlutterEngine()
    }
    
    private fun setupLocationService(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startService" -> {
                        val mode = call.argument<String>("mode") ?: "foreground"
                        val interval = call.argument<Double>("interval")?.toLong() ?: 900L
                        permissionResultCallback = { granted ->
                            if (granted) {
                                LocationService.schedulePeriodicUpdate(this, interval.toDouble())
                                val intent = Intent(this, LocationService::class.java).apply {
                                    putExtra("mode", mode)
                                }

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    startForegroundService(intent)
                                }else {
                                    startService(intent)
                                }

                                result.success(true)
                            } else {
                                result.error("PERMISSION_DENIED", "Location permissions not granted", null)
                            }
                        }

                        pendingMode = mode
                        requestPermissions(mode)
                    }
                    "stopService" -> {
                        val intent = Intent(this, LocationService::class.java)
                        stopService(intent)
                        result.success(true)
                    }
                    "requestPermissions" -> {
                        val mode = call.argument<String>("mode") ?: "foreground"
                        permissionResultCallback = { granted ->
                            result.success(granted)
                        }
                        requestPermissions(mode)
                    }
                    "checkPermissions" -> {
                        result.success(PermissionUtils.getPermissionStatus(this))
                    }
                    "schedulePeriodicUpdate" -> {
                        val interval = call.argument<Double>("interval") ?: (15.0 * 60)
                        LocationService.schedulePeriodicUpdate(this, interval)
                        result.success(true)
                    }
                    "syncPendingLocations" -> {
                        LocationService.syncLocations(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("METHOD_ERROR", "Failed to handle ${call.method}: ${e.message}", null)
            }
        }
    }

    private fun requestPermissions(mode: String) {
        try {

            val hasPermission = if (mode == "foreground") PermissionUtils.canTrackWhileInUse(this)
            else PermissionUtils.canTrackAlways(this)

            if (hasPermission) {
                permissionResultCallback?.invoke(true)
                try {
                    safeInvokeFlutterMethod(
                        "permissionChanged",
                        mapOf("status" to PermissionUtils.getPermissionStatus(this))
                    )
                } catch (e: Exception) {
                    //Log.w("MainActivity", "Failed to send permissionChanged (Flutter engine likely detached): ${e.message}")
                }

                return
            }
            
            requestLocationPermissions(mode)

        } catch (e: Exception) {
            safeInvokeFlutterMethod(
                "error",
                mapOf("message" to "Failed to request permissions: ${e.message}")
            )
            permissionResultCallback?.invoke(false)
        }
    }

    private fun requestLocationPermissions(mode: String) {
        try {
            val permissions = mutableListOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
            if (mode != "foreground" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                permissions.add(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
            }

            val permissionsNeeded = permissions.filter {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }.toTypedArray()

            if (permissionsNeeded.isNotEmpty()) {
                ActivityCompat.requestPermissions(
                    this,
                    permissionsNeeded,
                    locationPermissionRequestCode
                )
            } else {
                permissionResultCallback?.invoke(
                    if (mode == "foreground") PermissionUtils.canTrackWhileInUse(this)
                    else PermissionUtils.canTrackAlways(this)
                )
                try {
                    safeInvokeFlutterMethod(
                        "permissionChanged",
                        mapOf("status" to PermissionUtils.getPermissionStatus(this))
                    )
                } catch (e: Exception) {
//                    Log.w("MainActivity", "Failed to send permissionChanged (Flutter engine likely detached): ${e.message}")
                }
            }
        } catch (e: Exception) {

            try {
                safeInvokeFlutterMethod(
                    "error",
                    mapOf("message" to "Failed to request permissions: ${e.message}")
                )
            } catch (e: Exception) {
//                Log.w("MainActivity", "Failed to send error (Flutter engine likely detached): ${e.message}")
            }
            permissionResultCallback?.invoke(false)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == locationPermissionRequestCode) {
            val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            safeInvokeFlutterMethod(
                "permissionChanged",
                mapOf("status" to PermissionUtils.getPermissionStatus(this))
            )
            permissionResultCallback?.invoke(granted)
            permissionResultCallback = null
        }
    }
    private fun safeInvokeFlutterMethod(method: String, arguments: Any?) {
        try {
            LocationService.getChannel()?.invokeMethod(method, arguments)
        } catch (e: Exception) {
            android.util.Log.w("MainActivity", "Failed to invoke Flutter method $method: ${e.message}")
        }
    }

    private fun setupHtmlToPdfChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, htmlPdfChannel).setMethodCallHandler { call, result ->
            if (call.method == "convertHtmlToPdf") {
                val htmlFilePath = call.argument<String>("htmlFilePath")
                if (htmlFilePath == null) {
                    result.error("INVALID_ARGUMENT", "htmlFilePath is null", null)
                    return@setMethodCallHandler
                }

                HtmlToPdfConverter().convert(htmlFilePath, applicationContext, object : HtmlToPdfConverter.Callback {
                    override fun onSuccess(filePath: String) {
                        result.success(filePath)
                    }

                    override fun onFailure() {
                        result.error("ERROR", "Failed to convert HTML to PDF", null)
                    }
                })
            } else {
                result.notImplemented()
            }
        }
    }
}
