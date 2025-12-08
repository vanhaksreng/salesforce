package com.clearviewerp.salesforce;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import io.flutter.plugin.common.MethodCall
import android.bluetooth.BluetoothManager
import android.os.Build;
import android.os.Bundle;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.imin.library.IminSDKManager;
import com.imin.library.SystemPropManager;
import com.imin.printerlib.IminPrintUtils;
import java.util.List;
import android.util.Log
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.bluetooth.BluetoothAdapter



class MainActivity : FlutterActivity(){
    private val htmlPdfChannel = "flutter_html_to_pdf"
    private val locationMethodChannel = "com.clearviewerp.salesforce/background_service"
    private val locationPermissionRequestCode = 101
    private val PERMISSION_REQUEST_CODE = 1001
    private val BLUETOOTH_ENABLE_REQUEST = 1002
    private val bluetoothPermissionChannel = "bluetooth_permissions"

    private var permissionChannel: MethodChannel? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var permissionResultCallback: ((Boolean) -> Unit)? = null
    private var pendingMode: String? = null
    //=====================imin=================
    private val printerChannelImin = "com.imin.printersdk"
    private var connectType: IminPrintUtils.PrintConnectType? = null
    private var isPrinterInitialized = false
    companion object {
        private const val PRINTER_TAG = "IminPrinter"
    }
    //=====================imin=================

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


        // Set up the method channel for location service
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel)
        LocationService.setMethodChannel(methodChannel)
        LocationService.syncLocations(this)

        setupHtmlToPdfChannel(flutterEngine)
        setupLocationService(flutterEngine)
        setupIminPrinterChannel(flutterEngine)
        setupBluetoothPermissionChannel(flutterEngine) 
    }

    override fun onDestroy() {
        LocationService.onFlutterEngineDestroyed()
        super.onDestroy()
    }

    override fun detachFromFlutterEngine() {
        LocationService.onFlutterEngineDestroyed()
        super.detachFromFlutterEngine()
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

    //=====================imin=====================================================================================
    private fun setupIminPrinterChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, printerChannelImin)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "sdkInit" -> {
                        try {
                            val deviceModel = SystemPropManager.getModel()
                            Log.d(PRINTER_TAG, "Device Model: $deviceModel, Android Version: ${Build.VERSION.RELEASE}")

                            connectType = if (deviceModel.contains("M2-203") ||
                                deviceModel.contains("M2-202") ||
                                deviceModel.contains("M2 Pro")) {
                                IminPrintUtils.PrintConnectType.SPI
                            } else {
                                IminPrintUtils.PrintConnectType.USB
                            }

                            connectType?.let { type ->
                                Log.d(PRINTER_TAG, "Initializing printer with connection type: $type")
                                IminPrintUtils.getInstance(this@MainActivity).initPrinter(type)

                                // For Android 8.1, give more time for initialization
                                Thread.sleep(3000)

                                // Try to reset printer state for better reliability
                                try {
                                    IminPrintUtils.getInstance(this@MainActivity).resetDevice()
                                    Thread.sleep(1000)
                                    Log.d(PRINTER_TAG, "Printer reset completed")
                                } catch (e: Exception) {
                                    Log.w(PRINTER_TAG, "Reset printer failed: ${e.message}")
                                }

                                isPrinterInitialized = true
                            }
                            result.success("init")
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to initialize printer", e)
                            isPrinterInitialized = false
                            result.error("INIT_ERROR", "Failed to initialize printer", e.message)
                        }
                    }

                    "getStatus" -> {
                        try {
                            if (!isPrinterInitialized) {
                                result.error("ERROR", "Printer not initialized", null)
                                return@setMethodCallHandler
                            }

                            connectType?.let { type ->
                                // Multiple status checks with delays for Android 8.1
                                var status = -1
                                var attempts = 0
                                val maxAttempts = 3

                                while (status == -1 && attempts < maxAttempts) {
                                    Thread.sleep(500)
                                    status = IminPrintUtils.getInstance(this@MainActivity).getPrinterStatus(type)
                                    attempts++
                                    Log.d(PRINTER_TAG, "Status check attempt $attempts: Status = $status")
                                }

                                // Log status meaning for debugging
                                val statusMessage = when(status) {
                                    0 -> "Normal"
                                    1 -> "Printer busy"
                                    2 -> "Out of paper"
                                    3 -> "Paper jam"
                                    4 -> "Printer cover open"
                                    5 -> "Printer overheating"
                                    -1 -> "Error/Not ready"
                                    else -> "Unknown status"
                                }
                                Log.d(PRINTER_TAG, "Final printer status: $status ($statusMessage)")

                                result.success(mapOf(
                                    "status" to status,
                                    "message" to statusMessage,
                                    "attempts" to attempts
                                ))
                            } ?: result.error("ERROR", "Printer not initialized", null)
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to get printer status", e)
                            result.error("STATUS_ERROR", "Failed to get printer status", e.message)
                        }
                    }

                    "printText" -> {
                        try {
                            if (!isPrinterInitialized) {
                                result.error("ERROR", "Printer not initialized", null)
                                return@setMethodCallHandler
                            }

                            val text = when (val arguments = call.arguments) {
                                is List<*> -> {
                                    if (arguments.isNotEmpty()) {
                                        arguments[0].toString()
                                    } else {
                                        null
                                    }
                                }
                                is Map<*, *> -> {
                                    arguments["text"]?.toString()
                                }
                                is String -> {
                                    arguments
                                }
                                else -> null
                            }

                            if (text != null && text.isNotEmpty()) {
                                // Check printer status before printing
                                connectType?.let { type ->
                                    val status = IminPrintUtils.getInstance(this@MainActivity).getPrinterStatus(type)
                                    if (status != 0) {
                                        Log.w(PRINTER_TAG, "Printer status is $status, but attempting to print anyway")
                                    }
                                }

                                val mIminPrintUtils = IminPrintUtils.getInstance(this@MainActivity)
                                mIminPrintUtils.printText("$text\n")
                                Log.d(PRINTER_TAG, "Text printed successfully: $text")
                                result.success(text)
                            } else {
                                result.error("INVALID_ARGUMENT", "Text argument is required", null)
                            }
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to print text", e)
                            result.error("PRINT_ERROR", "Failed to print text", e.message)
                        }
                    }

                    "getSn" -> {
                        try {
                            val sn = if (Build.VERSION.SDK_INT >= 30) {
                                SystemPropManager.getSystemProperties("persist.sys.imin.sn")
                            } else {
                                // For Android 8.1 (API 27)
                                SystemPropManager.getSn()
                            }
                            Log.d(PRINTER_TAG, "Serial number retrieved: $sn")
                            result.success(sn)
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to get serial number", e)
                            result.error("SN_ERROR", "Failed to get serial number", e.message)
                        }
                    }

                    "opencashBox" -> {
                        try {
                            IminSDKManager.opencashBox()
                            Log.d(PRINTER_TAG, "Cash box opened successfully")
                            result.success("opencashBox")
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to open cash box", e)
                            result.error("CASHBOX_ERROR", "Failed to open cash box", e.message)
                        }
                    }

                    "printBitmap" -> {
                        try {
                            if (!isPrinterInitialized) {
                                result.error("ERROR", "Printer not initialized", null)
                                return@setMethodCallHandler
                            }

                            val imageBytes = call.argument<ByteArray>("image")
                            if (imageBytes != null) {
                                val bitmap = byteToBitmap(imageBytes)
                                bitmap?.let { bmp ->
                                    // Check printer status before printing
                                    connectType?.let { type ->
                                        val status = IminPrintUtils.getInstance(this@MainActivity).getPrinterStatus(type)
                                        if (status != 0) {
                                            Log.w(PRINTER_TAG, "Printer status is $status, but attempting to print bitmap anyway")
                                        }
                                    }

                                    val mIminPrintUtils = IminPrintUtils.getInstance(this@MainActivity)
                                    mIminPrintUtils.printSingleBitmap(bmp)
                                    Log.d(PRINTER_TAG, "Bitmap printed successfully")
                                    result.success("printBitmap")
                                } ?: result.error("BITMAP_ERROR", "Failed to convert bytes to bitmap", null)
                            } else {
                                result.error("INVALID_ARGUMENT", "Image bytes are required", null)
                            }
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to print bitmap", e)
                            result.error("BITMAP_PRINT_ERROR", "Failed to print bitmap", e.message)
                        }
                    }

                    "resetPrinter" -> {
                        try {
                            if (!isPrinterInitialized) {
                                result.error("ERROR", "Printer not initialized", null)
                                return@setMethodCallHandler
                            }

                            IminPrintUtils.getInstance(this@MainActivity).resetDevice()
                            Thread.sleep(1500) // Wait after reset
                            Log.d(PRINTER_TAG, "Printer reset completed")
                            result.success("reset")
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to reset printer", e)
                            result.error("RESET_ERROR", "Failed to reset printer", e.message)
                        }
                    }

                    "getDeviceInfo" -> {
                        try {
                            val deviceModel = SystemPropManager.getModel()
                            val androidVersion = Build.VERSION.RELEASE
                            val sdkInt = Build.VERSION.SDK_INT

                            val deviceInfo = mapOf(
                                "deviceModel" to deviceModel,
                                "androidVersion" to androidVersion,
                                "sdkInt" to sdkInt,
                                "printerInitialized" to isPrinterInitialized,
                                "connectionType" to (connectType?.toString() ?: "Not set")
                            )

                            Log.d(PRINTER_TAG, "Device info: $deviceInfo")
                            result.success(deviceInfo)
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to get device info", e)
                            result.error("DEVICE_INFO_ERROR", "Failed to get device info", e.message)
                        }
                    }

                    "testPrint" -> {
                        try {
                            if (!isPrinterInitialized) {
                                result.error("ERROR", "Printer not initialized", null)
                                return@setMethodCallHandler
                            }

                            val mIminPrintUtils = IminPrintUtils.getInstance(this@MainActivity)

                            // Print test receipt
                            mIminPrintUtils.printText("================================\n")
                            mIminPrintUtils.printText("         TEST PRINT\n")
                            mIminPrintUtils.printText("================================\n")
                            mIminPrintUtils.printText("Device: ${SystemPropManager.getModel()}\n")
                            mIminPrintUtils.printText("Android: ${Build.VERSION.RELEASE}\n")
                            mIminPrintUtils.printText("Time: ${System.currentTimeMillis()}\n")
                            mIminPrintUtils.printText("================================\n")
                            mIminPrintUtils.printText("\n\n\n")

                            Log.d(PRINTER_TAG, "Test print completed")
                            result.success("Test print completed")
                        } catch (e: Exception) {
                            Log.e(PRINTER_TAG, "Failed to print test", e)
                            result.error("TEST_PRINT_ERROR", "Failed to print test", e.message)
                        }
                    }

                    else -> {
                        Log.w(PRINTER_TAG, "Method not implemented: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }

    private fun byteToBitmap(imgByte: ByteArray): Bitmap? {
        return try {
            val options = BitmapFactory.Options().apply {
                inSampleSize = 1
                inPreferredConfig = Bitmap.Config.RGB_565 // Use less memory for Android 8.1
                inJustDecodeBounds = false
            }

            // First check the size
            val boundsOptions = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeByteArray(imgByte, 0, imgByte.size, boundsOptions)

            // Calculate sample size if image is too large
            val imageSize = boundsOptions.outWidth * boundsOptions.outHeight * 2 // RGB_565 uses 2 bytes per pixel
            val maxSize = 2 * 1024 * 1024 // 2MB limit for Android 8.1

            if (imageSize > maxSize) {
                val sampleSize = Math.ceil(Math.sqrt((imageSize / maxSize).toDouble())).toInt()
                options.inSampleSize = sampleSize
                Log.d(PRINTER_TAG, "Large image detected, using sample size: $sampleSize")
            }

            val bitmap = BitmapFactory.decodeByteArray(imgByte, 0, imgByte.size, options)
            if (bitmap == null) {
                Log.e(PRINTER_TAG, "BitmapFactory.decodeByteArray returned null")
            } else {
                Log.d(PRINTER_TAG, "Bitmap created successfully: ${bitmap.width}x${bitmap.height}")
            }
            bitmap
        } catch (e: Exception) {
            Log.e(PRINTER_TAG, "Failed to convert bytes to bitmap", e)
            null
        } catch (e: OutOfMemoryError) {
            Log.e(PRINTER_TAG, "Out of memory while converting bytes to bitmap", e)
            // Try with higher sample size
            try {
                val options = BitmapFactory.Options().apply {
                    inSampleSize = 4 // Reduce size significantly
                    inPreferredConfig = Bitmap.Config.RGB_565
                }
                val bitmap = BitmapFactory.decodeByteArray(imgByte, 0, imgByte.size, options)
                Log.d(PRINTER_TAG, "Bitmap created with reduced size due to OOM")
                bitmap
            } catch (e2: Exception) {
                Log.e(PRINTER_TAG, "Failed to create bitmap even with reduced size", e2)
                null
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

    

//=========================================new printer sdk=========================================
    // private fun setupIminPrinterChannel(flutterEngine: FlutterEngine) {
    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, printerChannelImin)
    //         .setMethodCallHandler { call, result ->

    //             when (call.method) {

    //                 "sdkInit" -> {
    //                     try {
    //                         val deviceModel = SystemPropManager.getModel()
    //                         connectType = if (deviceModel.contains("M2-203") ||
    //                             deviceModel.contains("M2-202") ||
    //                             deviceModel.contains("M2 Pro")) {
    //                             IminPrintUtils.PrintConnectType.USB
    //                         } else {
    //                             IminPrintUtils.PrintConnectType.USB
    //                         }

    //                         connectType?.let { type ->
    //                             IminPrintUtils.getInstance(this@MainActivity).initPrinter(type)
    //                         }
    //                         result.success("init")
    //                     } catch (e: Exception) {
    //                         result.error("INIT_ERROR", "Failed to initialize printer", e.message)
    //                     }
    //                 }

    //                 "getStatus" -> {
    //                     try {
    //                         connectType?.let { type ->
    //                             val status = IminPrintUtils.getInstance(this@MainActivity).getPrinterStatus(type)
    //                             result.success(status.toString())
    //                         } ?: result.error("ERROR", "Printer not initialized", null)
    //                     } catch (e: Exception) {
    //                         result.error("STATUS_ERROR", "Failed to get printer status", e.message)
    //                     }
    //                 }

    //                 "printText" -> {
    //                     try {
    //                         val text = when (val arguments = call.arguments) {
    //                             is List<*> -> {
    //                                 if (arguments.isNotEmpty()) {
    //                                     arguments[0].toString()
    //                                 } else {
    //                                     null
    //                                 }
    //                             }
    //                             is Map<*, *> -> {
    //                                 arguments["text"]?.toString()
    //                             }
    //                             is String -> {
    //                                 arguments
    //                             }
    //                             else -> null
    //                         }

    //                         if (text != null && text.isNotEmpty()) {
    //                             val mIminPrintUtils = IminPrintUtils.getInstance(this@MainActivity)
    //                             mIminPrintUtils.printText("$text   \n")
    //                             result.success(text)
    //                         } else {
    //                             result.error("INVALID_ARGUMENT", "Text argument is required", null)
    //                         }
    //                     } catch (e: Exception) {
    //                         result.error("PRINT_ERROR", "Failed to print text", e.message)
    //                     }
    //                 }

    //                 "getSn" -> {
    //                     try {
    //                         val sn = if (Build.VERSION.SDK_INT >= 30) {
    //                             SystemPropManager.getSystemProperties("persist.sys.imin.sn")
    //                         } else {
    //                             SystemPropManager.getSn()
    //                         }
    //                         result.success(sn)
    //                     } catch (e: Exception) {
    //                         result.error("SN_ERROR", "Failed to get serial number", e.message)
    //                     }
    //                 }

    //                 "opencashBox" -> {
    //                     try {
    //                         IminSDKManager.opencashBox()
    //                         result.success("opencashBox")
    //                     } catch (e: Exception) {
    //                         result.error("CASHBOX_ERROR", "Failed to open cash box", e.message)
    //                     }
    //                 }

    //                 "printBitmap" -> {
    //                     try {
    //                         val imageBytes = call.argument<ByteArray>("image")
    //                         if (imageBytes != null) {
    //                             val bitmap = byteToBitmap(imageBytes)
    //                             bitmap?.let { bmp ->
    //                                 val mIminPrintUtils = IminPrintUtils.getInstance(this@MainActivity)
    //                                 mIminPrintUtils.printSingleBitmap(bmp)
    //                                 result.success("printBitmap")
    //                             } ?: result.error("BITMAP_ERROR", "Failed to convert bytes to bitmap", null)
    //                         } else {
    //                             result.error("INVALID_ARGUMENT", "Image bytes are required", null)
    //                         }
    //                     } catch (e: Exception) {
    //                         result.error("BITMAP_PRINT_ERROR", "Failed to print bitmap", e.message)
    //                     }
    //                 }

    //                 else -> result.notImplemented()
    //             }
    //         }
    // }

    // private fun byteToBitmap(imgByte: ByteArray): Bitmap? {
    //     return try {
    //         val options = BitmapFactory.Options().apply {
    //             inSampleSize = 1
    //             inPreferredConfig = Bitmap.Config.RGB_565 // Use less memory
    //         }

    //         val bitmap = BitmapFactory.decodeByteArray(imgByte, 0, imgByte.size, options)
    //         if (bitmap == null) {
    //             Log.e("ByteToBitmap", "BitmapFactory.decodeByteArray returned null")
    //         }
    //         bitmap
    //     } catch (e: Exception) {
    //         Log.e("ByteToBitmap", "Failed to convert bytes to bitmap", e)
    //         null
    //     } catch (e: OutOfMemoryError) {
    //         Log.e("ByteToBitmap", "Out of memory while converting bytes to bitmap", e)
    //         null
    //     }
    // }

}