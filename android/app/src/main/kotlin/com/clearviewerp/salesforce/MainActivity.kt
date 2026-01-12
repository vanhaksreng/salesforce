package com.clearviewerp.salesforce;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.bluetooth.BluetoothManager
import android.os.Build;
import android.os.Bundle;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.bluetooth.BluetoothAdapter

class MainActivity : FlutterActivity(){
    private val htmlPdfChannel = "flutter_html_to_pdf"
    private val locationMethodChannel = "com.clearviewerp.salesforce/background_service"
    private val locationPermissionRequestCode = 101
    private val PERMISSION_REQUEST_CODE = 1001
    private val BLUETOOTH_ENABLE_REQUEST = 1002

    private lateinit var iminPrinter: IminPrinter
    private val printerChannelImin = "com.imin.printersdk"

    private val bluetoothPermissionChannel = "bluetooth_permissions"
    private var permissionResultCallback: ((Boolean) -> Unit)? = null
    private var pendingMode: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (intent?.getBooleanExtra("requestPermissions", false) == true) {
            requestPermissions("always")
        }
    }
    
    override fun onResume() {
        super.onResume()
        LocationService.syncLocations(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // Register your custom thermal printer plugin
        flutterEngine.plugins.add(ThermalPrinterPlugin())
//        setupIminPrinterChannel(flutterEngine)

        // Set up the method channel for location service
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel)
        LocationService.setMethodChannel(methodChannel)
        LocationService.syncLocations(this)

        setupHtmlToPdfChannel(flutterEngine)
        setupLocationService(flutterEngine)

        setupBluetoothPermissionChannel(flutterEngine)
        setupIminPrinterChannel(flutterEngine)
    }

    override fun onDestroy() {
        LocationService.onFlutterEngineDestroyed()
        super.onDestroy()
    }

    override fun detachFromFlutterEngine() {
        LocationService.onFlutterEngineDestroyed()
        super.detachFromFlutterEngine()
    }

    private fun setupIminPrinterChannel(flutterEngine: FlutterEngine) {
        try {

            // Create the printer instance
            iminPrinter = IminPrinter(this)

            // Register the method channel with the printer as the handler
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                printerChannelImin
            ).setMethodCallHandler(iminPrinter)

        } catch (e: Exception) {
            //Log.e(io.flutter.plugins.sharedpreferences.TAG, "❌ Failed to setup iMin Printer", e)
        }
    }

    private fun setupBluetoothPermissionChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bluetoothPermissionChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestBluetoothPermissions" -> {
                        requestBluetoothPermissionsIfNeeded()
                        result.success(true)
                    }
                    "checkBluetoothPermissions" -> {
                        val hasPermissions = checkBluetoothPermissions()
                        result.success(hasPermissions)
                    }
                    "enableBluetooth" -> {
                        ensureBluetoothEnabled()
                        result.success(true)
                    }
                    "isBluetoothEnabled" -> {
                        val isEnabled = isBluetoothEnabled()
                        result.success(isEnabled)
                    }
                  
                    "getBluetoothStatus" -> {
                        val status = getBluetoothStatus()
                        result.success(status)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setupLocationService(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startService" -> {
                        val mode = call.argument<String>("mode") ?: "foreground"
                        val interval = 900L
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

        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.isNotEmpty() &&
                    grantResults.all { it == PackageManager.PERMISSION_GRANTED }

            if (allGranted) {
                println("All Bluetooth permissions granted")
                ensureBluetoothEnabled()
            } else {
                println("Some Bluetooth permissions denied")
            }
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

    //======================================printer===================
    private fun requestBluetoothPermissionsIfNeeded() {
        val hasPermissions = checkBluetoothPermissions()

        if (!hasPermissions) {
            println("📱 Requesting Bluetooth permissions...")
            val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                arrayOf(
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_SCAN
                )
            } else {
                arrayOf(
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
            }
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
        } else {
            println("✅ Bluetooth permissions already granted")
            ensureBluetoothEnabled()
        }
    }

     private fun isBluetoothEnabled(): Boolean {
        val bluetoothManager = getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager
        val bluetoothAdapter = bluetoothManager?.adapter
        
        return bluetoothAdapter?.isEnabled ?: false
    }

    private fun getBluetoothStatus(): Map<String, Any> {
        val bluetoothManager = getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager
        val bluetoothAdapter = bluetoothManager?.adapter
        
        val hasPermissions = checkBluetoothPermissions()
        val isEnabled = bluetoothAdapter?.isEnabled ?: false
        val isSupported = bluetoothAdapter != null
        
        return mapOf(
            "hasPermissions" to hasPermissions,
            "isEnabled" to isEnabled,
            "isSupported" to isSupported,
            "canUse" to (hasPermissions && isEnabled)
        )
    }

    private fun checkBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.BLUETOOTH_SCAN
                    ) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.BLUETOOTH_ADMIN
                    ) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun ensureBluetoothEnabled() {
        val bluetoothManager = getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager
        val bluetoothAdapter = bluetoothManager?.adapter

        if (bluetoothAdapter?.isEnabled == false) {
            println("📱 Bluetooth is OFF, requesting to enable...")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                    startActivityForResult(enableBtIntent, BLUETOOTH_ENABLE_REQUEST)
                }
            } else {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                startActivityForResult(enableBtIntent, BLUETOOTH_ENABLE_REQUEST)
            }
        } else {
            println("Bluetooth is already enabled")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == BLUETOOTH_ENABLE_REQUEST) {
            if (resultCode == RESULT_OK) {
                println(" Bluetooth enabled by user")
            } else {
                println("User declined to enable Bluetooth")
            }
        }
    }

    private fun byteToBitmap(imgByte: ByteArray): Bitmap? {
         return try {
             val options = BitmapFactory.Options().apply {
                 inSampleSize = 1
                 inPreferredConfig = Bitmap.Config.RGB_565 // Use less memory
             }

             val bitmap = BitmapFactory.decodeByteArray(imgByte, 0, imgByte.size, options)
             if (bitmap == null) {
                //Log.e("ByteToBitmap", "BitmapFactory.decodeByteArray returned null")
             }
             bitmap
         } catch (e: Exception) {
             null
         } catch (e: OutOfMemoryError) {
             null
         }
     }

}