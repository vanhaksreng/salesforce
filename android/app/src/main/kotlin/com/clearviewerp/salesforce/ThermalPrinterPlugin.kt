package com.clearviewerp.salesforce

import android.Manifest
import android.bluetooth.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.*
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.net.Socket
import java.util.*
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

// ====================================================================
// Configuration
// ====================================================================
object PrinterConfig {
    const val WIDTH_58MM = 384
    const val WIDTH_80MM = 576
    const val CONNECTION_TIMEOUT = 15000L
}

// ====================================================================
// Printer Settings Data Class
// ====================================================================
data class PrinterSettings(
    val width: Int,
    val maxChars: Int,
    val fontScaleSmall: Float,
    val fontScaleMedium: Float,
    val fontScaleLarge: Float,
    val fontScaleXLarge: Float,
    val lineSpacingTight: Float,
    val lineSpacingNormal: Float,
    val paddingSmall: Float,
    val paddingMedium: Float,
    val paddingLarge: Float
)

// ====================================================================
// Data Classes
// ====================================================================
data class MonochromeData(val width: Int, val height: Int, val data: ByteArray) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        other as MonochromeData
        return width == other.width && height == other.height && data.contentEquals(other.data)
    }

    override fun hashCode(): Int {
        var result = width
        result = 31 * result + height
        result = 31 * result + data.contentHashCode()
        return result
    }
}

data class PosColumn(
    val text: String,
    val width: Int,
    val align: String,
    val bold: Boolean
)

enum class ImageAlignment(val value: Int) {
    LEFT(0),
    CENTER(1),
    RIGHT(2);

    companion object {
        fun fromInt(value: Int) = values().firstOrNull { it.value == value } ?: CENTER
    }
}

enum class ConnectionType {
    BLUETOOTH_CLASSIC,
    BLUETOOTH_BLE,
    NETWORK,
    USB,
    NONE
}

private var printerModel: PrinterModel = PrinterModel.UNKNOWN

enum class PrinterModel {
    UNKNOWN,
    SLOW,      // Old printers (50 bytes/ms)
    MEDIUM,    // Standard printers (80 bytes/ms)
    FAST       // Modern printers (120 bytes/ms)
}

private var printerSpeed: PrinterSpeed = PrinterSpeed.UNKNOWN

enum class PrinterSpeed {
    UNKNOWN,
    SLOW,      // < 3 bytes/ms
    MEDIUM,    // 3-6 bytes/ms
    FAST       // > 6 bytes/ms
}

// ====================================================================
// Main Plugin Class
// ====================================================================
class ThermalPrinterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())

    // Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var bluetoothSocket: android.bluetooth.BluetoothSocket? = null
    private val discoveredDevices = Collections.synchronizedList(mutableListOf<BluetoothDevice>())
    private var discoveryReceiver: BroadcastReceiver? = null

    // USB
    private var usbManager: UsbManager? = null

    // Network
    private var networkSocket: Socket? = null

    // Connection state
    @Volatile
    private var currentConnectionType = ConnectionType.NONE
    private var printerWidth = PrinterConfig.WIDTH_80MM  // Default to 80mm

    // ESC/POS Commands
    private val ESC: Byte = 0x1B
    private val GS: Byte = 0x1D

    // Coroutine scope
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private val printMutex = Mutex()

    // Write synchronization
    private val writeSync = Object()
    @Volatile private var writeCompleted = false
    private var writeLatch: CountDownLatch? = null
    private var currentWriteDeferred: CompletableDeferred<Boolean>? = null

    // Pending results (thread-safe)
    private val pendingResults = ConcurrentHashMap<String, MethodChannel.Result>()

    // Font cache
    private val khmerTypefaceCache = ConcurrentHashMap<String, Typeface>()
    private val receiptBuffer = mutableListOf<Byte>()
    private var isBatchMode = false

    // ====================================================================
    // Helper function to get printer-specific settings
    // ====================================================================
    private fun getPrinterConfig(): PrinterSettings {
        return when (printerWidth) {
            PrinterConfig.WIDTH_58MM -> PrinterSettings(
                width = 384,
                maxChars = 32,
                fontScaleSmall = 0.6f,
                fontScaleMedium = 0.75f,
                fontScaleLarge = 0.9f,
                fontScaleXLarge = 1.2f,
                lineSpacingTight = 0.95f,
                lineSpacingNormal = 0.92f,
                paddingSmall = 1f,
                paddingMedium = 2f,
                paddingLarge = 3f
            )
            else -> PrinterSettings(  // 80mm default
                width = 576,
                maxChars = 48,
                fontScaleSmall = 0.6f,
                fontScaleMedium = 0.8f,
                fontScaleLarge = 1.0f,
                fontScaleXLarge = 1.5f,
                lineSpacingTight = 0.90f,
                lineSpacingNormal = 0.88f,
                paddingSmall = 2f,
                paddingMedium = 3f,
                paddingLarge = 4f
            )
        }
    }

    // ====================================================================
    // Plugin Lifecycle
    // ====================================================================
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "thermal_printer")
        channel.setMethodCallHandler(this)

        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
        usbManager = context.getSystemService(Context.USB_SERVICE) as? UsbManager

        preloadFonts()
        println("🔵 ThermalPrinterPlugin initialized")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        // Cleanup connections
        cleanupAllConnections()

        // Unregister discovery receiver
        discoveryReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                println("⚠️ Receiver already unregistered")
            }
        }

        // Cancel coroutines
        scope.cancel()

        // Clear caches
        khmerTypefaceCache.clear()
        pendingResults.clear()
    }

    // ====================================================================
    // Batch Mode Management
    // ====================================================================
    private fun startBatchMode() {
        receiptBuffer.clear()
        isBatchMode = true

        // ✅ CRITICAL: Initialize printer ONCE at the start
        val initCommands = mutableListOf<Byte>()
        initCommands.addAll(listOf(ESC, 0x40))           // Reset printer
        initCommands.addAll(listOf(ESC, 0x74, 0x01))     // Set code page
        initCommands.addAll(listOf(ESC, 0x33, 0x30))     // Set line spacing

        receiptBuffer.addAll(initCommands)

        println("📦 Started batch mode with initialization (${if (printerWidth == 384) "58mm" else "80mm"})")
    }

    private fun endBatchMode() {
        isBatchMode = false
        if (receiptBuffer.isNotEmpty()) {
            println("📤 Optimizing and sending batched receipt: ${receiptBuffer.size} bytes")

            // ✅ CRITICAL: Optimize the data before sending
            val optimizedData = optimizeLineFeeds(receiptBuffer.toByteArray())

            println("✅ Optimized: ${receiptBuffer.size} → ${optimizedData.size} bytes")

            writeDataSmooth(optimizedData)
            receiptBuffer.clear()
        }
    }

    private fun addToBuffer(data: ByteArray) {
        if (isBatchMode) {
            receiptBuffer.addAll(data.toList())
            println("➕ Added ${data.size} bytes to buffer (total: ${receiptBuffer.size})")
        } else {
            writeDataSmooth(data)
        }
    }

    private fun optimizeLineFeeds(data: ByteArray): ByteArray {
        // OOMAS printers stutter when there are too many consecutive line feeds
        // Consolidate multiple 0x0A bytes into larger chunks
        val optimized = mutableListOf<Byte>()
        var consecutiveLineFeeds = 0

        for (byte in data) {
            if (byte == 0x0A.toByte()) {
                consecutiveLineFeeds++
            } else {
                if (consecutiveLineFeeds > 0) {
                    // Add all line feeds at once (more efficient)
                    for (i in 0 until consecutiveLineFeeds) {
                        optimized.add(0x0A.toByte())
                    }
                    consecutiveLineFeeds = 0
                }
                optimized.add(byte)
            }
        }

        // Add any remaining line feeds
        if (consecutiveLineFeeds > 0) {
            for (i in 0 until consecutiveLineFeeds) {
                optimized.add(0x0A.toByte())
            }
        }

        return optimized.toByteArray()
    }

    // ====================================================================
    // Diagnostic Tests
    // ====================================================================
    private fun testPaperFeed(result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                println("🧪 TEST 1: Paper Feed Test")
                println("Listen for 'stuck stuck' sound...")

                // Test A: Feed paper only (no printing)
                val feedCommand = ByteArray(10) { 0x0A.toByte() } // 10 line feeds
                writeDataSmooth(feedCommand)
                Thread.sleep(2000)

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "test" to "paper_feed",
                        "instruction" to "Did you hear 'stuck stuck' during paper feed? YES = Paper problem, NO = Code problem"
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TEST_ERROR", e.message, null)
                }
            }
        }
    }

    private fun testSlowPrint(result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                println("🧪 TEST 2: Slow Print Test")

                val commands = mutableListOf<Byte>()
                commands.addAll(listOf(ESC, 0x40)) // Initialize
                commands.addAll("TEST LINE 1".toByteArray(charset("CP437")).toList())
                commands.add(0x0A.toByte())

                writeDataSmooth(commands.toByteArray())
                Thread.sleep(1000)

                commands.clear()
                commands.addAll("TEST LINE 2".toByteArray(charset("CP437")).toList())
                commands.add(0x0A.toByte())

                writeDataSmooth(commands.toByteArray())
                Thread.sleep(1000)

                commands.clear()
                commands.addAll("TEST LINE 3".toByteArray(charset("CP437")).toList())
                commands.add(0x0A.toByte())

                writeDataSmooth(commands.toByteArray())

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "test" to "slow_print",
                        "instruction" to "Was it smooth? If YES → code was too fast before, If NO → hardware issue"
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TEST_ERROR", e.message, null)
                }
            }
        }
    }

    private fun checkPrinterStatus(result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                println("🧪 TEST 3: Printer Status Check")

                val statusCommand = byteArrayOf(0x10, 0x04, 0x01) // DLE EOT n

                writeDataSmooth(statusCommand)
                Thread.sleep(100)

                val status = when (currentConnectionType) {
                    ConnectionType.BLUETOOTH_CLASSIC -> {
                        try {
                            val inputStream = bluetoothSocket?.inputStream
                            if (inputStream?.available() ?: 0 > 0) {
                                val buffer = ByteArray(10)
                                val read = inputStream?.read(buffer)
                                "Status bytes read: $read"
                            } else {
                                "No response from printer"
                            }
                        } catch (e: Exception) {
                            "Error reading: ${e.message}"
                        }
                    }
                    else -> "Status check only available for Classic BT"
                }

                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "test" to "status_check",
                        "status" to status
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TEST_ERROR", e.message, null)
                }
            }
        }
    }

    private fun runCompleteDiagnostic(result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                val diagnosticResults = mutableMapOf<String, String>()

                println("""
                ═══════════════════════════════════════
                🔍 COMPLETE PRINTER DIAGNOSTIC
                ═══════════════════════════════════════
            """.trimIndent())

                // Test 1: Paper feed only
                println("\n▶️ TEST 1: Paper Feed Test")
                val feedCommand = ByteArray(5) { 0x0A.toByte() }
                writeDataSmooth(feedCommand)
                Thread.sleep(2000)
                diagnosticResults["paper_feed"] = "Check if 'stuck stuck' sound occurred"

                // Test 2: Single line text
                println("\n▶️ TEST 2: Single Line Test")
                val textCommand = "TEST LINE\n".toByteArray(charset("CP437"))
                writeDataSmooth(textCommand)
                Thread.sleep(2000)
                diagnosticResults["single_line"] = "Check if smooth"

                // Test 3: Multiple lines with delays
                println("\n▶️ TEST 3: Multiple Lines (with delays)")
                for (i in 1..3) {
                    val line = "Line $i\n".toByteArray(charset("CP437"))
                    writeDataSmooth(line)
                    Thread.sleep(500)
                }
                diagnosticResults["multiple_lines"] = "Check if smooth with delays"

                // Test 4: Multiple lines fast
                println("\n▶️ TEST 4: Multiple Lines (fast)")
                val fastLines = "Fast Line 1\nFast Line 2\nFast Line 3\n".toByteArray(charset("CP437"))
                writeDataSmooth(fastLines)
                Thread.sleep(2000)
                diagnosticResults["fast_lines"] = "Check if 'stuck stuck' occurs when fast"

                println("""
                
                ═══════════════════════════════════════
                📊 DIAGNOSTIC RESULTS
                ═══════════════════════════════════════
                ${diagnosticResults.entries.joinToString("\n") { "${it.key}: ${it.value}" }}
                
                ═══════════════════════════════════════
                📋 INTERPRETATION:
                ═══════════════════════════════════════
                ✅ If smooth in TEST 3 (slow) but stuck in TEST 4 (fast)
                   → SOLUTION: Add delays between commands
                
                ✅ If stuck in TEST 1 (paper feed only)
                   → PROBLEM: Paper or mechanical issue (not code)
                   → CHECK: Paper quality, paper sensor, roller
                
                ✅ If stuck in all tests
                   → PROBLEM: Printer hardware issue
                   → CHECK: Battery, print head, motor
                
                ✅ If smooth in all tests
                   → PROBLEM: Complex data causing issues
                   → SOLUTION: Use ultra-smooth mode for images
                ═══════════════════════════════════════
            """.trimIndent())

                withContext(Dispatchers.Main) {
                    result.success(diagnosticResults)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DIAGNOSTIC_ERROR", e.message, null)
                }
            }
        }
    }

    private fun initializePrinterOptimal() {
        println("🔧 Initializing printer with optimal settings...")

        val commands = mutableListOf<Byte>()

        commands.addAll(listOf(ESC, 0x40))
        commands.addAll(listOf(ESC, 0x21, 0x00))
        commands.addAll(listOf(ESC, 0x33, 0x40.toByte()))
        commands.addAll(listOf(ESC, 0x47, 0x00))

        writeDataSmooth(commands.toByteArray())
        Thread.sleep(200)

        println("✅ Printer initialized with smooth settings")
    }

    private fun cleanupAllConnections() {
        try {
            bluetoothSocket?.close()
            bluetoothSocket = null

            bluetoothGatt?.disconnect()
            bluetoothGatt?.close()
            bluetoothGatt = null
            writeCharacteristic = null

            networkSocket?.close()
            networkSocket = null

            currentConnectionType = ConnectionType.NONE
            println("🧹 All connections cleaned up")
        } catch (e: Exception) {
            println("⚠️ Cleanup error: ${e.message}")
        }
    }

    // ====================================================================
    // Method Call Handler
    // ====================================================================
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startBatch" -> {
                startBatchMode()
                result.success(true)
            }

            "printSeparator" -> {
                val width = call.argument<Int>("width") ?: 48
                printSeparator(width, result)
            }

            "endBatch" -> {
                endBatchMode()
                result.success(true)
            }

            "configureOOMAS" -> {
                configureForOOMAS()
                result.success(true)
            }

            "warmUpPrinter" -> {
                warmUpPrinter()
                result.success(true)
            }

            "testPaperFeed" -> testPaperFeed(result)
            "testSlowPrint" -> testSlowPrint(result)
            "checkPrinterStatus" -> checkPrinterStatus(result)
            "runDiagnostic" -> runCompleteDiagnostic(result)
            "initializePrinter" -> {
                initializePrinterOptimal()
                result.success(true)
            }

            "discoverPrinters" -> {
                val type = call.argument<String>("type")
                if (type != null) {
                    discoverPrinters(type, result)
                } else {
                    result.error("INVALID_ARGS", "Missing type", null)
                }
            }

            "discoverAllPrinters" -> discoverAllPrinters(result)

            "connect" -> {
                val address = call.argument<String>("address")
                val type = call.argument<String>("type")
                if (address != null && type != null) {
                    connect(address, type, result)
                } else {
                    result.error("INVALID_ARGS", "Missing arguments", null)
                }
            }

            "connectNetwork" -> {
                val ipAddress = call.argument<String>("ipAddress")
                val port = call.argument<Int>("port") ?: 9100
                if (ipAddress != null) {
                    connectNetwork(ipAddress, port, result)
                } else {
                    result.error("INVALID_ARGS", "Missing IP address", null)
                }
            }

            "disconnect" -> disconnect(result)

            "printText" -> {
                val text = call.argument<String>("text")
                val fontSize = call.argument<Int>("fontSize") ?: 24
                val bold = call.argument<Boolean>("bold") ?: false
                val align = call.argument<String>("align") ?: "left"
                val maxCharsPerLine = call.argument<Int>("maxCharsPerLine") ?: 0
                if (text != null) {
                    printText(text, fontSize, bold, align, maxCharsPerLine, result)
                } else {
                    result.error("INVALID_ARGS", "Missing text", null)
                }
            }

            "printRow" -> {
                val columns = call.argument<List<Map<String, Any>>>("columns") ?: emptyList()
                val fontSize = call.argument<Int>("fontSize") ?: 24
                printRow(columns, fontSize, result)
            }

            "printImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val width = call.argument<Int>("width") ?: printerWidth
                val align = call.argument<Int>("align") ?: 1
                if (imageBytes != null) {
                    printImage(imageBytes, width, align, result)
                } else {
                    result.error("INVALID_ARGS", "Missing imageBytes", null)
                }
            }

            "printImageWithPadding" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val width = call.argument<Int>("width") ?: 384
                val align = call.argument<Int>("align") ?: 1
                val paperWidth = call.argument<Int>("paperWidth") ?: 576

                if (imageBytes == null) {
                    result.error("INVALID_ARGUMENT", "imageBytes is required", null)
                    return
                }

                printImageWithPadding(imageBytes, width, align, paperWidth, result)
            }

            "feedPaper" -> {
                val lines = call.argument<Int>("lines") ?: 1
                feedPaper(lines, result)
            }

            "cutPaper" -> cutPaper(result)

            "getStatus" -> getStatus(result)

            "setPrinterWidth" -> {
                val width = call.argument<Int>("width")
                if (width != null) {
                    setPrinterWidth(width, result)
                } else {
                    result.error("INVALID_ARGS", "Missing width", null)
                }
            }

            "checkBluetoothPermission" -> checkBluetoothPermission(result)

            else -> result.notImplemented()
        }
    }

    // ====================================================================
    // Discovery Methods
    // ====================================================================
    private fun discoverPrinters(type: String, result: MethodChannel.Result) {
        when (type) {
            "bluetooth", "ble" -> discoverBluetoothPrinters(result)
            "usb" -> discoverUSBPrinters(result)
            "network" -> result.success(emptyList<Map<String, Any>>())
            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
        }
    }

    private fun discoverAllPrinters(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
            return
        }

        discoveredDevices.clear()

        try {
            bluetoothAdapter?.bondedDevices?.forEach { device ->
                discoveredDevices.add(device)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
            return
        }

        val allPrinters = mutableListOf<Map<String, Any>>()

        discoveredDevices.forEach { device ->
            try {
                val deviceName = device.name
                if (!deviceName.isNullOrBlank() && deviceName != "Unknown Device") {
                    allPrinters.add(
                        mapOf(
                            "name" to deviceName,
                            "address" to device.address,
                            "type" to "bluetooth"
                        )
                    )
                }
            } catch (e: SecurityException) {
                println("⚠️ Cannot access device: ${e.message}")
            }
        }

        usbManager?.deviceList?.values?.forEach { device ->
            allPrinters.add(
                mapOf(
                    "name" to device.deviceName,
                    "address" to device.deviceId.toString(),
                    "type" to "usb"
                )
            )
        }

        result.success(allPrinters)
    }

    private fun discoverBluetoothPrinters(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
            return
        }

        discoveredDevices.clear()

        try {
            bluetoothAdapter?.bondedDevices?.forEach { device ->
                discoveredDevices.add(device)
            }

            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }
            bluetoothAdapter?.startDiscovery()

            registerDiscoveryReceiver(result)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        }
    }

    private fun registerDiscoveryReceiver(result: MethodChannel.Result) {
        discoveryReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                // Already unregistered
            }
        }

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    BluetoothDevice.ACTION_FOUND -> {
                        val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        device?.let {
                            val deviceName = it.name
                            if (!deviceName.isNullOrEmpty() &&
                                deviceName != "Unknown" &&
                                !discoveredDevices.contains(it)) {
                                discoveredDevices.add(it)
                                println("📱 Found device: $deviceName (${it.address})")
                            } else {
                                println("⏭️ Skipped device: ${deviceName ?: "null"} (${it.address})")
                            }
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        println("🔍 Discovery finished. Named devices: ${discoveredDevices.size}")
                        returnDiscoveredDevices(result)
                        try {
                            context?.unregisterReceiver(this)
                            discoveryReceiver = null
                        } catch (e: IllegalArgumentException) {
                            // Already unregistered
                        }
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }

        discoveryReceiver = receiver
        context.registerReceiver(receiver, filter)
        println("🔍 Starting Bluetooth discovery...")
    }

    private fun returnDiscoveredDevices(result: MethodChannel.Result) {
        try {
            val printers = discoveredDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unknown Device"),
                    "address" to device.address,
                    "type" to "bluetooth"
                )
            }
            result.success(printers)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        }
    }

    private fun discoverUSBPrinters(result: MethodChannel.Result) {
        val devices = usbManager?.deviceList?.values?.map { device ->
            mapOf(
                "name" to device.deviceName,
                "address" to device.deviceId.toString(),
                "type" to "usb"
            )
        } ?: emptyList()

        result.success(devices)
    }

    // ====================================================================
    // Connection Methods
    // ====================================================================
    private fun connect(address: String, type: String, result: MethodChannel.Result) {
        println("🔵 Connect request: address=$address, type=$type")

        when (type) {
            "bluetooth" -> connectClassicBluetooth(address, result)
            "ble" -> connectBLE(address, result)
            "usb" -> result.error("NOT_IMPLEMENTED", "USB not yet implemented", null)
            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
        }
    }

    private fun connectClassicBluetooth(address: String, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
            return
        }

        if (bluetoothAdapter?.isEnabled != true) {
            result.error("BLUETOOTH_OFF", "Bluetooth is turned off", null)
            return
        }

        scope.launch(Dispatchers.IO) {
            try {
                val device = bluetoothAdapter?.getRemoteDevice(address)
                if (device == null) {
                    withContext(Dispatchers.Main) {
                        result.error("NOT_FOUND", "Device not found", null)
                    }
                    return@launch
                }

                println("🔵 Connecting via Classic Bluetooth: ${device.name} ($address)")

                bluetoothSocket?.close()
                bluetoothAdapter?.cancelDiscovery()

                val uuids = listOf(
                    "00001101-0000-1000-8000-00805F9B34FB",
                    "00001102-0000-1000-8000-00805F9B34FB",
                    "00001103-0000-1000-8000-00805F9B34FB"
                )

                var connected = false
                var lastException: Exception? = null

                for (uuidString in uuids) {
                    try {
                        val uuid = UUID.fromString(uuidString)
                        println("🔵 Trying UUID: $uuidString")

                        bluetoothSocket = device.createRfcommSocketToServiceRecord(uuid)

                        println("🔵 Attempting SPP connection...")
                        bluetoothSocket?.connect()

                        if (bluetoothSocket?.isConnected == true) {
                            println("✅ Classic Bluetooth Connected with UUID: $uuidString!")
                            connected = true
                            break
                        }
                    } catch (e: Exception) {
                        println("❌ Failed with UUID $uuidString: ${e.message}")
                        lastException = e
                        bluetoothSocket?.close()
                        bluetoothSocket = null
                    }
                }

                if (connected) {
                    currentConnectionType = ConnectionType.BLUETOOTH_CLASSIC

                    try {
                        initializePrinterForSmoothPrinting()
                        println("✅ Printer initialized for smooth printing")
                    } catch (e: Exception) {
                        println("⚠️ Could not initialize printer settings: ${e.message}")
                    }

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } else {
                    throw lastException ?: Exception("Failed to connect with all UUIDs")
                }
            } catch (e: SecurityException) {
                println("❌ Security exception: ${e.message}")
                withContext(Dispatchers.Main) {
                    result.error("PERMISSION_DENIED", e.message, null)
                }
            } catch (e: Exception) {
                println("❌ Classic Bluetooth connection failed: ${e.message}")
                println("📋 Stack trace: ${e.stackTraceToString()}")
                println("🔄 Falling back to BLE connection...")
                withContext(Dispatchers.Main) {
                    connectBLE(address, result)
                }
            }
        }
    }

    private fun connectBLE(address: String, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
            return
        }

        if (bluetoothAdapter?.isEnabled != true) {
            result.error("BLUETOOTH_OFF", "Bluetooth is turned off", null)
            return
        }

        try {
            val device = bluetoothAdapter?.getRemoteDevice(address)
            if (device == null) {
                result.error("NOT_FOUND", "Device not found", null)
                return
            }

            cleanupBeforeConnect()

            val resultKey = "connection_$address"
            pendingResults[resultKey] = result

            bluetoothGatt = device.connectGatt(
                context,
                false,
                createGattCallback(resultKey),
                BluetoothDevice.TRANSPORT_LE
            )

            mainHandler.postDelayed({
                if (pendingResults.remove(resultKey) != null) {
                    println("⏱️ BLE Connection timeout")
                    result.error("TIMEOUT", "Connection timeout after ${PrinterConfig.CONNECTION_TIMEOUT}ms", null)
                    bluetoothGatt?.disconnect()
                    bluetoothGatt?.close()
                    bluetoothGatt = null
                }
            }, PrinterConfig.CONNECTION_TIMEOUT)

        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", e.message, null)
        }
    }

    private fun connectNetwork(ipAddress: String, port: Int, result: MethodChannel.Result) {
        scope.launch(Dispatchers.IO) {
            try {
                networkSocket = Socket(ipAddress, port)
                currentConnectionType = ConnectionType.NETWORK

                try {
                    initializePrinterForSmoothPrinting()
                    println("✅ Printer initialized for smooth printing")
                } catch (e: Exception) {
                    println("⚠️ Could not initialize printer settings: ${e.message}")
                }

                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("CONNECTION_FAILED", e.message, null)
                }
            }
        }
    }

    private fun disconnect(result: MethodChannel.Result) {
        cleanupAllConnections()
        result.success(true)
    }

    private fun createGattCallback(resultKey: String): BluetoothGattCallback {
        return object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                when (newState) {
                    BluetoothProfile.STATE_CONNECTED -> {
                        println("✅ BLE Connected! Status: $status")
                        if (status == BluetoothGatt.GATT_SUCCESS) {
                            try {
                                Thread.sleep(600)
                                gatt.discoverServices()
                            } catch (e: Exception) {
                                handleConnectionError(resultKey, "DISCOVER_FAILED", e.message)
                                gatt.disconnect()
                                gatt.close()
                            }
                        } else {
                            handleConnectionError(resultKey, "CONNECTION_ERROR", "Status: $status")
                            gatt.disconnect()
                            gatt.close()
                        }
                    }

                    BluetoothProfile.STATE_DISCONNECTED -> {
                        val errorMsg = getDisconnectReason(status)
                        println("❌ Disconnected: $errorMsg")
                        handleConnectionError(resultKey, "DISCONNECTED", errorMsg)
                        gatt.close()
                    }
                }
            }

            override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    handleConnectionError(resultKey, "DISCOVER_FAILED", "Status: $status")
                    gatt.disconnect()
                    gatt.close()
                    return
                }

                val characteristic = findWritableCharacteristic(gatt)

                if (characteristic != null) {
                    writeCharacteristic = characteristic
                    currentConnectionType = ConnectionType.BLUETOOTH_BLE
                    println("✅ BLE Connection Success! Char: ${characteristic.uuid}")

                    try {
                        initializePrinterForSmoothPrinting()
                        println("✅ Printer initialized for smooth printing")
                    } catch (e: Exception) {
                        println("⚠️ Could not initialize printer settings: ${e.message}")
                    }

                    mainHandler.post {
                        pendingResults.remove(resultKey)?.success(true)
                    }
                } else {
                    handleConnectionError(resultKey, "NO_CHARACTERISTIC", "No writable characteristic found")
                    gatt.disconnect()
                    gatt.close()
                }
            }

            override fun onCharacteristicWrite(
                gatt: BluetoothGatt?,
                characteristic: BluetoothGattCharacteristic?,
                status: Int
            ) {
                synchronized(writeSync) {
                    writeCompleted = (status == BluetoothGatt.GATT_SUCCESS)
                    writeLatch?.countDown()
                    currentWriteDeferred?.complete(writeCompleted)
                    currentWriteDeferred = null
                }
            }
        }
    }

    private fun findWritableCharacteristic(gatt: BluetoothGatt): BluetoothGattCharacteristic? {
        val printerServiceUUIDs = listOf(
            "000018f0-0000-1000-8000-00805f9b34fb",
            "49535343-fe7d-4ae5-8fa9-9fafd205e455",
            "0000ffe0-0000-1000-8000-00805f9b34fb",
            "0000fff0-0000-1000-8000-00805f9b34fb"
        )

        for (serviceUuidStr in printerServiceUUIDs) {
            try {
                val service = gatt.getService(UUID.fromString(serviceUuidStr))
                service?.characteristics?.forEach { char ->
                    if (isWritable(char)) {
                        println("✅ Found writable char in known service: ${char.uuid}")
                        return char
                    }
                }
            } catch (e: Exception) {
                println("⚠️ Error checking service $serviceUuidStr: ${e.message}")
            }
        }

        gatt.services.forEach { service ->
            service.characteristics.forEach { char ->
                if (isWritable(char)) {
                    println("✅ Found writable char: ${char.uuid}")
                    return char
                }
            }
        }

        return null
    }

    private fun isWritable(char: BluetoothGattCharacteristic): Boolean {
        val props = char.properties
        return (props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
                (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
    }

    private fun handleConnectionError(resultKey: String, code: String, message: String?) {
        mainHandler.post {
            pendingResults.remove(resultKey)?.error(code, message, null)
        }
    }

    private fun getDisconnectReason(status: Int): String {
        return when (status) {
            0 -> "Disconnected normally"
            8 -> "Connection timeout - device not responding"
            19 -> "Connection terminated by peer device"
            22 -> "Connection failed - device busy or unavailable"
            133 -> "GATT error 133 - Device out of range or not ready"
            else -> "Disconnected with status: $status"
        }
    }

    private fun cleanupBeforeConnect() {
        try {
            bluetoothGatt?.let { gatt ->
                println("🧹 Cleaning up existing BLE connection...")
                gatt.disconnect()
                Thread.sleep(300)
                gatt.close()
                Thread.sleep(300)
            }
        } catch (e: Exception) {
            println("⚠️ Cleanup error: ${e.message}")
        }
        bluetoothGatt = null
        writeCharacteristic = null
    }

    // ====================================================================
    // Write Methods
    // ====================================================================
    private fun writeDataSmooth(data: ByteArray) {
        val startTime = System.currentTimeMillis()

        val lineFeeds = data.count { it == 0x0A.toByte() }

        try {
            when (currentConnectionType) {
                ConnectionType.BLUETOOTH_CLASSIC -> {
                    bluetoothSocket?.let { socket ->
                        if (socket.isConnected) {
                            writeClassicBluetoothWithLineDelay(socket, data, lineFeeds)

                            val elapsed = System.currentTimeMillis() - startTime
                            println("✅ Classic BT: ${data.size} bytes in ${elapsed}ms")
                            return
                        }
                    }
                }

                ConnectionType.BLUETOOTH_BLE -> {
                    writeBLEDataOptimized(data, startTime)
                    if (lineFeeds > 0) {
                        Thread.sleep(lineFeeds * 30L)
                    }
                }

                ConnectionType.NETWORK -> {
                    writeNetworkOptimized(data)
                    if (lineFeeds > 0) {
                        Thread.sleep(lineFeeds * 30L)
                    }
                }

                else -> println("❌ No active connection")
            }
        } catch (e: Exception) {
            println("❌ Write error: ${e.message}")
            throw e
        }
    }

    private fun writeClassicBluetoothWithLineDelay(
        socket: android.bluetooth.BluetoothSocket,
        data: ByteArray,
        lineFeeds: Int
    ) {
        val outputStream = socket.outputStream

        if (lineFeeds > 0 && data.size < 500) {
            println("📝 Writing with line feed delays (${lineFeeds} line feeds)")

            for (i in data.indices) {
                outputStream.write(data[i].toInt())

                if (data[i] == 0x0A.toByte()) {
                    outputStream.flush()
                    Thread.sleep(50L)
                    println("⏸️ Line feed delay")
                }
            }
            outputStream.flush()
            return
        }

        if (data.size >= 500) {
            val chunkSize = 256
            var offset = 0

            while (offset < data.size) {
                val end = (offset + chunkSize).coerceAtMost(data.size)
                val chunk = data.copyOfRange(offset, end)

                outputStream.write(chunk)
                outputStream.flush()

                if (end < data.size) {
                    Thread.sleep(15L)
                }

                offset = end
            }
            return
        }

        outputStream.write(data)
        outputStream.flush()
    }

    private fun writeBLEDataOptimized(data: ByteArray, startTime: Long) {
        val characteristic = writeCharacteristic
        val gatt = bluetoothGatt

        if (characteristic == null || gatt == null) {
            println("❌ No BLE connection")
            return
        }

        try {
            val useNoResponse = (characteristic.properties and
                    BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0

            if (useNoResponse) {
                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE

                val chunkSize = 128
                val delay = 8L

                var offset = 0
                while (offset < data.size) {
                    val end = (offset + chunkSize).coerceAtMost(data.size)
                    val chunk = data.copyOfRange(offset, end)

                    characteristic.value = chunk
                    gatt.writeCharacteristic(characteristic)

                    if (end < data.size) {
                        Thread.sleep(delay)
                    }

                    offset = end
                }
            } else {
                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
                val chunkSize = 20

                var offset = 0
                while (offset < data.size) {
                    val end = (offset + chunkSize).coerceAtMost(data.size)
                    val chunk = data.copyOfRange(offset, end)

                    synchronized(writeSync) {
                        writeLatch = CountDownLatch(1)
                        writeCompleted = false
                    }

                    characteristic.value = chunk
                    gatt.writeCharacteristic(characteristic)

                    writeLatch?.await(100, TimeUnit.MILLISECONDS)
                    offset = end
                }
            }

            val elapsed = System.currentTimeMillis() - startTime
            println("✅ BLE: ${elapsed}ms total")

        } catch (e: Exception) {
            println("❌ BLE Error: ${e.message}")
            throw e
        }
    }

    private fun writeNetworkOptimized(data: ByteArray) {
        try {
            val outputStream = networkSocket?.getOutputStream()

            if (data.size < 1000) {
                outputStream?.write(data)
                outputStream?.flush()
                return
            }

            val chunkSize = 512
            var offset = 0

            while (offset < data.size) {
                val end = (offset + chunkSize).coerceAtMost(data.size)
                val chunk = data.copyOfRange(offset, end)

                outputStream?.write(chunk)
                outputStream?.flush()

                if (end < data.size) {
                    Thread.sleep(10L)
                }

                offset = end
            }
        } catch (e: Exception) {
            println("❌ Network error: ${e.message}")
            throw e
        }
    }

    // ====================================================================
    // Printer Configuration
    // ====================================================================
    private fun warmUpPrinter() {
        println("🔥 Warming up printer...")

        val warmUpData = byteArrayOf(
            ESC, 0x40,
            0x0A.toByte(),
        )

        try {
            when (currentConnectionType) {
                ConnectionType.BLUETOOTH_CLASSIC -> {
                    bluetoothSocket?.outputStream?.let { stream ->
                        stream.write(warmUpData)
                        stream.flush()
                        Thread.sleep(100)
                    }
                }
                ConnectionType.BLUETOOTH_BLE -> {
                    writeCharacteristic?.let { char ->
                        bluetoothGatt?.let { gatt ->
                            char.value = warmUpData
                            char.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
                            gatt.writeCharacteristic(char)
                            Thread.sleep(100)
                        }
                    }
                }
                else -> {}
            }
            println("✅ Printer warmed up")
        } catch (e: Exception) {
            println("⚠️ Warm-up failed: ${e.message}")
        }
    }

    private fun configureForOOMAS() {
        println("⚙️ Configuring for OOMAS printer...")

        val config = mutableListOf<Byte>()

        config.addAll(listOf(ESC, 0x33, 0x40.toByte()))
        config.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x05.toByte()))
        config.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x00.toByte()))

        writeDataSmooth(config.toByteArray())

        println("✅ OOMAS configuration applied")
    }

    private fun initializePrinterForSmoothPrinting() {
        println("🔧 Initializing printer for smooth printing...")

        val commands = mutableListOf<Byte>()

        commands.addAll(listOf(ESC, 0x40))
        Thread.sleep(100)

        commands.addAll(listOf(ESC, 0x33, 0x50.toByte()))

        commands.addAll(listOf(
            GS, 0x28, 0x4B,
            0x02, 0x00,
            0x30,
            0x06.toByte()
        ))

        writeDataSmooth(commands.toByteArray())
        Thread.sleep(200)

        println("✅ Printer initialized for smooth operation")
    }

    private fun printSeparator(width: Int, result: MethodChannel.Result) {
        scope.launch {
            printMutex.withLock {
                try {
                    val commands = mutableListOf<Byte>()

                    commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03.toByte()))
                    commands.addAll(listOf(ESC, 0x61, 0x01))
                    commands.addAll(listOf(ESC, 0x21, 0x00))

                    val separator = "=".repeat(width)
                    commands.addAll(separator.toByteArray(charset("CP437")).toList())
                    commands.add(0x0A.toByte())

                    commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06.toByte()))
                    commands.addAll(listOf(ESC, 0x61, 0x00))

                    addToBuffer(commands.toByteArray())

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        result.error("SEPARATOR_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    // ====================================================================
    // Print Text
    // ====================================================================
    private fun printText(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int,
        result: MethodChannel.Result
    ) {
        val startTime = System.currentTimeMillis()

        scope.launch {
            printMutex.withLock {
                try {
                    // ✅ KEY FIX: For small fonts, always render as image
                    val shouldRenderAsImage = fontSize < 20 || containsComplexUnicode(text)

                    if (shouldRenderAsImage) {
                        println("🖼️ Rendering as image (fontSize: $fontSize): \"${text.take(30)}...\"")
                        val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)

                        if (imageData == null || imageData.isEmpty()) {
                            throw Exception("Failed to render text")
                        }

                        val alignLeftCommand = byteArrayOf(ESC, 0x61.toByte(), 0x00.toByte())
                        val finalData = alignLeftCommand + imageData

                        addToBuffer(finalData)
                    } else {
                        println("📝 Printing as text (fontSize: $fontSize): \"${text.take(30)}...\"")
                        printSimpleTextInternalBatched(text, fontSize, bold, align, maxCharsPerLine)
                    }

                    val elapsed = System.currentTimeMillis() - startTime
                    println("✅ Text added to buffer in ${elapsed}ms")

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    println("❌ Print error: ${e.message}")
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    private fun printSimpleTextInternalBatched(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int
    ) {
        println("🔵 Adding text to buffer: \"${text.take(30)}...\"")

        val commands = mutableListOf<Byte>()

        val isSeparatorLine = text.count { it == '=' } > (text.length * 0.8)

        if (isSeparatorLine) {
            println("📏 Detected separator line - using lower density")
            commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03.toByte()))
        }

        commands.addAll(listOf(ESC, 0x45, if (bold) 0x01 else 0x00))

        val alignValue = when (align.lowercase()) {
            "center" -> 0x01.toByte()
            "right" -> 0x02.toByte()
            else -> 0x00.toByte()
        }
        commands.addAll(listOf(ESC, 0x61, alignValue))

        val sizeCommand: Byte = if (isSeparatorLine) {
            0x00.toByte()
        } else {
            when {
                fontSize > 30 -> 0x30.toByte()
                fontSize > 24 -> 0x11.toByte()
                fontSize >= 18 -> 0x00.toByte()
                else -> 0x01.toByte()
            }
        }
        commands.addAll(listOf(ESC, 0x21, sizeCommand))

        val wrappedText = if (maxCharsPerLine > 0) wrapText(text, maxCharsPerLine) else text
        commands.addAll(wrappedText.toByteArray(charset("CP437")).toList())
        commands.add(0x0A.toByte())

        commands.addAll(listOf(ESC, 0x45, 0x00))
        commands.addAll(listOf(ESC, 0x61, 0x00))

        if (isSeparatorLine) {
            commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06.toByte()))
        }

        addToBuffer(commands.toByteArray())
    }

    private fun renderTextToData(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int
    ): ByteArray? {
        var bitmap: Bitmap? = null

        try {
            val config = getPrinterConfig()
            val khmerTypeface = getKhmerTypeface(bold)

            val baseFontSize = 20f
            val scaledFontSize = when {
                fontSize >= 30 -> baseFontSize * 2.0f
                fontSize >= 24 -> baseFontSize * config.fontScaleXLarge
                fontSize >= 18 -> baseFontSize * config.fontScaleLarge
                fontSize >= 14 -> baseFontSize * config.fontScaleMedium
                fontSize >= 12 -> baseFontSize * 0.75f
                else -> baseFontSize * config.fontScaleSmall
            }

            println("📐 Font rendering: fontSize=$fontSize → scaledFontSize=$scaledFontSize (${if (printerWidth == 384) "58mm" else "80mm"})")

            val paint = Paint().apply {
                textSize = scaledFontSize
                typeface = khmerTypeface
                isFakeBoldText = bold && fontSize < 16
                strokeWidth = if (bold && fontSize < 16) 0.5f else 0f
                style = Paint.Style.FILL
                isAntiAlias = true
                color = Color.BLACK
                textAlign = when (align.lowercase()) {
                    "center" -> Paint.Align.CENTER
                    "right" -> Paint.Align.RIGHT
                    else -> Paint.Align.LEFT
                }
            }

            val maxWidth = printerWidth.toFloat()
            val padding = when {
                fontSize < 14 -> config.paddingSmall
                fontSize < 18 -> config.paddingMedium
                else -> config.paddingLarge
            }
            val leftMarginOffset = if (paint.textAlign == Paint.Align.LEFT) padding else 0f

            val textToRender = if (maxCharsPerLine > 0) {
                wrapText(text, maxCharsPerLine)
            } else {
                text
            }

            val lines = textToRender.split("\n")

            val lineSpacingMultiplier = when {
                fontSize < 14 -> config.lineSpacingTight
                fontSize < 18 -> config.lineSpacingNormal
                else -> 0.90f
            }
            val lineHeight = paint.fontMetrics.let { (it.descent - it.ascent) * lineSpacingMultiplier }
            val totalHeight = (lines.size * lineHeight + padding * 2).toInt()

            bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)

            var y = padding - paint.fontMetrics.ascent
            for (line in lines) {
                if (line.isNotBlank()) {
                    val x = when (paint.textAlign) {
                        Paint.Align.CENTER -> maxWidth / 2
                        Paint.Align.RIGHT -> maxWidth - padding
                        else -> leftMarginOffset
                    }
                    canvas.drawText(line, x, y, paint)
                }
                y += lineHeight
            }

            val monoData = convertToMonochromeFast(bitmap)

            if (monoData == null) {
                println("❌ Failed to convert to monochrome")
                return null
            }

            val widthBytes = (monoData.width + 7) / 8
            val commandSize = 8 + monoData.data.size
            val commands = ByteArray(commandSize)

            var idx = 0
            commands[idx++] = GS
            commands[idx++] = 0x76
            commands[idx++] = 0x30
            commands[idx++] = 0x00
            commands[idx++] = (widthBytes and 0xFF).toByte()
            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()
            commands[idx++] = (monoData.height and 0xFF).toByte()
            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()

            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)

            println("✅ Rendered ${lines.size} lines, total height: ${totalHeight}px")
            return commands

        } catch (e: Exception) {
            println("❌ Render error: ${e.message}")
            return null
        } finally {
            bitmap?.recycle()
        }
    }

    // ====================================================================
    // Print Row
    // ====================================================================
    private fun printRow(
        columns: List<Map<String, Any>>,
        fontSize: Int,
        result: MethodChannel.Result
    ) {
        val startTime = System.currentTimeMillis()

        scope.launch {
            printMutex.withLock {
                try {
                    val posColumns = columns.map { col ->
                        PosColumn(
                            text = col["text"] as? String ?: "",
                            width = col["width"] as? Int ?: 6,
                            align = col["align"] as? String ?: "left",
                            bold = col["bold"] as? Boolean ?: false
                        )
                    }

                    val totalWidth = posColumns.sumOf { it.width }
                    if (totalWidth > 12) {
                        withContext(Dispatchers.Main) {
                            result.error("ROW_ERROR", "Total width exceeds 12: $totalWidth", null)
                        }
                        return@withLock
                    }

                    // ✅ KEY FIX: Force image rendering for small fonts or complex Unicode
                    val hasComplexUnicode = posColumns.any { containsComplexUnicode(it.text) }
                    val shouldRenderAsImage = fontSize < 20 || hasComplexUnicode

                    if (shouldRenderAsImage) {
                        println("🖼️ Rendering row as image (fontSize: $fontSize)")
                        val imageData = renderRowToData(posColumns, fontSize)
                        if (imageData == null || imageData.isEmpty()) {
                            withContext(Dispatchers.Main) {
                                result.error("RENDER_ERROR", "Failed to render row", null)
                            }
                            return@withLock
                        }
                        addToBuffer(imageData)
                    } else {
                        println("📝 Printing row as text (fontSize: $fontSize)")
                        printRowUsingTextMethodBatched(posColumns, fontSize)
                    }

                    val elapsed = System.currentTimeMillis() - startTime
                    println("✅ Row added to buffer in ${elapsed}ms")

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    println("❌ Row error: ${e.message}")
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ROW_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    private fun printRowUsingTextMethodBatched(columns: List<PosColumn>, fontSize: Int) {
        val totalChars = when {
            fontSize >= 30 -> 20
            fontSize >= 24 -> 28
            fontSize >= 20 -> 32
            fontSize >= 16 -> 36
            fontSize >= 14 -> 40
            fontSize >= 12 -> 44
            else -> 48
        }

        val columnTextLists = columns.map { column ->
            val maxCharsPerColumn = (totalChars * column.width) / 12
            val lines = wrapTextToList(column.text, maxCharsPerColumn)
            Triple(lines, maxCharsPerColumn, column.align)
        }

        val maxLines = columnTextLists.maxOfOrNull { it.first.size } ?: 1
        val commands = mutableListOf<Byte>()

        val sizeCommand: Byte = when {
            fontSize >= 30 -> 0x30.toByte()
            fontSize >= 24 -> 0x11.toByte()
            fontSize >= 18 -> 0x00.toByte()
            else -> 0x01.toByte()
        }
        commands.addAll(listOf(ESC, 0x21, sizeCommand))

        val hasBold = columns.any { it.bold }
        if (hasBold) {
            commands.addAll(listOf(ESC, 0x45, 0x01))
        }

        commands.addAll(listOf(ESC, 0x61, 0x00))

        for (lineIndex in 0 until maxLines) {
            val lineText = StringBuilder()

            for (colIndex in columnTextLists.indices) {
                val (lines, width, align) = columnTextLists[colIndex]
                val text = if (lineIndex < lines.size) lines[lineIndex] else ""
                val formattedText = formatColumnText(text, width, align)
                lineText.append(formattedText)
            }

            commands.addAll(lineText.toString().toByteArray(charset("CP437")).toList())
            commands.add(0x0A.toByte())
        }

        if (hasBold) {
            commands.addAll(listOf(ESC, 0x45, 0x00))
        }
        commands.addAll(listOf(ESC, 0x61, 0x00))

        addToBuffer(commands.toByteArray())
    }

    private fun renderRowToData(columns: List<PosColumn>, fontSize: Int): ByteArray? {
        var bitmap: Bitmap? = null
        try {
            val config = getPrinterConfig()

            val baseFontSize = 24f
            val scaledFontSize = when {
                fontSize >= 30 -> baseFontSize * 2.0f
                fontSize >= 24 -> baseFontSize * config.fontScaleXLarge
                fontSize >= 20 -> baseFontSize * config.fontScaleLarge
                fontSize >= 16 -> baseFontSize * config.fontScaleMedium
                fontSize >= 14 -> baseFontSize * 0.75f
                fontSize >= 12 -> baseFontSize * 0.65f
                fontSize >= 10 -> baseFontSize * 0.55f
                else -> baseFontSize * 0.5f
            }

            println("📐 Row rendering: fontSize=$fontSize → scaledFontSize=$scaledFontSize (${if (printerWidth == 384) "58mm" else "80mm"})")

            val maxWidth = printerWidth.toFloat()
            val columnWidths = columns.map { (maxWidth * it.width) / 12 }

            val totalChars = when {
                fontSize >= 30 -> 20
                fontSize >= 24 -> 28
                fontSize >= 20 -> 32
                fontSize >= 16 -> 36
                fontSize >= 14 -> 40
                fontSize >= 12 -> 44
                else -> config.maxChars
            }

            var maxLines = 1
            for (column in columns) {
                val colChars = (totalChars * column.width) / 12
                val lineCount = (column.text.length + colChars - 1) / colChars
                if (lineCount > maxLines) maxLines = lineCount
            }

            val basePaint = Paint().apply {
                textSize = scaledFontSize
                isAntiAlias = true
                color = Color.BLACK
                style = Paint.Style.FILL
                strokeWidth = 0f
            }

            val lineSpacingMultiplier = when {
                fontSize < 14 -> config.lineSpacingTight
                fontSize < 18 -> config.lineSpacingNormal
                else -> 0.90f
            }
            val lineHeight = basePaint.fontMetrics.let { (it.descent - it.ascent) * lineSpacingMultiplier }

            val verticalPadding = when {
                fontSize < 14 -> config.paddingSmall
                fontSize < 18 -> config.paddingMedium
                else -> config.paddingLarge
            }
            val totalHeight = (lineHeight * maxLines + verticalPadding * 2).toInt()

            bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)

            var currentX = 0f
            for (i in columns.indices) {
                val column = columns[i]
                val colWidth = columnWidths[i]
                val colChars = (totalChars * column.width) / 12

                val lines = wrapTextToList(column.text, colChars)
                val columnTypeface = getKhmerTypeface(column.bold)

                basePaint.apply {
                    typeface = columnTypeface
                    isFakeBoldText = column.bold && fontSize < 16
                    strokeWidth = if (column.bold && fontSize < 14) 0.5f else 0f
                    textAlign = when (column.align.lowercase()) {
                        "center" -> Paint.Align.CENTER
                        "right" -> Paint.Align.RIGHT
                        else -> Paint.Align.LEFT
                    }
                }

                for (lineIndex in lines.indices) {
                    val line = lines[lineIndex]
                    if (line.isBlank()) continue

                    val x = when (column.align.lowercase()) {
                        "center" -> currentX + colWidth / 2
                        "right" -> currentX + colWidth - 2f
                        else -> currentX + 2f
                    }

                    val y = verticalPadding - basePaint.fontMetrics.ascent + (lineHeight * lineIndex)
                    canvas.drawText(line, x, y, basePaint)
                }

                currentX += colWidth
            }

            val monoData = convertToMonochromeFast(bitmap)

            if (monoData == null) {
                println("❌ Failed to convert row to monochrome")
                return null
            }

            val widthBytes = (monoData.width + 7) / 8
            val commandSize = 8 + monoData.data.size
            val commands = ByteArray(commandSize)

            var idx = 0
            commands[idx++] = GS
            commands[idx++] = 0x76
            commands[idx++] = 0x30
            commands[idx++] = 0x00
            commands[idx++] = (widthBytes and 0xFF).toByte()
            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()
            commands[idx++] = (monoData.height and 0xFF).toByte()
            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()

            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)

            println("✅ Row rendered: ${columns.size} columns, ${maxLines} lines, height: ${totalHeight}px")
            return commands

        } catch (e: Exception) {
            println("❌ Row render error: ${e.message}")
            return null
        } finally {
            bitmap?.recycle()
        }
    }

    private fun formatColumnText(text: String, width: Int, align: String): String {
        if (text.length == width) return text
        if (text.length > width) return text.take(width)

        return when (align.lowercase()) {
            "center" -> {
                val totalPadding = width - text.length
                val leftPadding = totalPadding / 2
                text.padStart(text.length + leftPadding).padEnd(width)
            }
            "right" -> text.padStart(width)
            else -> text.padEnd(width)
        }
    }

    // ====================================================================
    // Print Image
    // ====================================================================
    private fun printImage(
        imageBytes: ByteArray,
        width: Int,
        align: Int,
        result: MethodChannel.Result
    ) {
        scope.launch {
            printMutex.withLock {
                var bitmap: Bitmap? = null
                var scaledBitmap: Bitmap? = null

                try {
                    bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    if (bitmap == null) {
                        withContext(Dispatchers.Main) {
                            result.error("INVALID_IMAGE", "Cannot decode image", null)
                        }
                        return@withLock
                    }

                    val alignment = ImageAlignment.fromInt(align)
                    scaledBitmap = resizeImage(bitmap, width)
                    val monochromeData = convertToMonochromeFast(scaledBitmap)

                    if (monochromeData == null) {
                        withContext(Dispatchers.Main) {
                            result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
                        }
                        return@withLock
                    }

                    val commands = mutableListOf<Byte>()

                    commands.add(ESC)
                    commands.add(0x40)

                    commands.add(ESC)
                    commands.add(0x61)
                    commands.add(alignment.value.toByte())

                    commands.add(ESC)
                    commands.add(0x33)
                    commands.add(0x00)

                    commands.add(GS)
                    commands.add(0x76)
                    commands.add(0x30)
                    commands.add(0x00)

                    val widthBytes = (monochromeData.width + 7) / 8
                    commands.add((widthBytes and 0xFF).toByte())
                    commands.add(((widthBytes shr 8) and 0xFF).toByte())
                    commands.add((monochromeData.height and 0xFF).toByte())
                    commands.add(((monochromeData.height shr 8) and 0xFF).toByte())

                    commands.addAll(monochromeData.data.toList())

                    commands.add(ESC)
                    commands.add(0x33)
                    commands.add(0x1E)

                    commands.add(ESC)
                    commands.add(0x61)
                    commands.add(0x00)

                    writeDataSmooth(commands.toByteArray())

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    println("❌ Image print error: ${e.message}")
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                } finally {
                    bitmap?.recycle()
                    scaledBitmap?.recycle()
                }
            }
        }
    }

    private fun printImageWithPadding(
        imageBytes: ByteArray,
        width: Int,
        align: Int,
        paperWidth: Int,
        result: MethodChannel.Result
    ) {
        scope.launch {
            printMutex.withLock {
                var bitmap: Bitmap? = null
                var scaledBitmap: Bitmap? = null

                try {
                    bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    if (bitmap == null) {
                        withContext(Dispatchers.Main) {
                            result.error("INVALID_IMAGE", "Cannot decode image", null)
                        }
                        return@withLock
                    }

                    val alignment = ImageAlignment.fromInt(align)
                    scaledBitmap = resizeImage(bitmap, width)
                    val originalData = convertToMonochromeFast(scaledBitmap)

                    if (originalData == null) {
                        withContext(Dispatchers.Main) {
                            result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
                        }
                        return@withLock
                    }

                    val monochromeData = if (alignment != ImageAlignment.LEFT) {
                        addPaddingToMonochrome(originalData, alignment, paperWidth)
                    } else {
                        originalData
                    }

                    val commands = mutableListOf<Byte>()

                    commands.add(ESC)
                    commands.add(0x40)
                    commands.add(GS)
                    commands.add(0x76)
                    commands.add(0x30)
                    commands.add(0x00)

                    val widthBytes = (monochromeData.width + 7) / 8
                    commands.add((widthBytes and 0xFF).toByte())
                    commands.add(((widthBytes shr 8) and 0xFF).toByte())
                    commands.add((monochromeData.height and 0xFF).toByte())
                    commands.add(((monochromeData.height shr 8) and 0xFF).toByte())

                    commands.addAll(monochromeData.data.toList())
                    commands.add(0x0A)
                    commands.add(0x0A)

                    writeDataSmooth(commands.toByteArray())

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    println("❌ Image padding print error: ${e.message}")
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                } finally {
                    bitmap?.recycle()
                    scaledBitmap?.recycle()
                }
            }
        }
    }

    // ====================================================================
    // Helper Methods
    // ====================================================================
    private fun resizeImage(bitmap: Bitmap, maxWidth: Int): Bitmap {
        if (bitmap.width <= maxWidth) return bitmap

        val ratio = maxWidth.toFloat() / bitmap.width
        val newHeight = (bitmap.height * ratio).toInt()

        return Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
    }

    private fun addPaddingToMonochrome(
        data: MonochromeData,
        alignment: ImageAlignment,
        paperWidth: Int
    ): MonochromeData {
        if (data.width >= paperWidth) return data

        val paddingTotal = paperWidth - data.width
        val leftPadding = when (alignment) {
            ImageAlignment.LEFT -> 0
            ImageAlignment.CENTER -> paddingTotal / 2
            ImageAlignment.RIGHT -> paddingTotal
        }

        val currentWidthBytes = (data.width + 7) / 8
        val newWidthBytes = (paperWidth + 7) / 8
        val newData = ByteArray(newWidthBytes * data.height)

        for (y in 0 until data.height) {
            val newRowOffset = y * newWidthBytes
            val oldRowOffset = y * currentWidthBytes
            val leftPaddingBytes = leftPadding / 8

            System.arraycopy(
                data.data,
                oldRowOffset,
                newData,
                newRowOffset + leftPaddingBytes,
                currentWidthBytes
            )
        }

        return MonochromeData(paperWidth, data.height, newData)
    }

    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
        try {
            val width = bitmap.width
            val height = bitmap.height
            val widthBytes = (width + 7) / 8
            val data = ByteArray(widthBytes * height)

            val pixels = IntArray(width * height)
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

            val grayscale = FloatArray(width * height)
            for (i in pixels.indices) {
                val pixel = pixels[i]
                val r = Color.red(pixel)
                val g = Color.green(pixel)
                val b = Color.blue(pixel)
                grayscale[i] = (0.299f * r + 0.587f * g + 0.114f * b)
            }

            for (y in 0 until height) {
                for (x in 0 until width) {
                    val index = y * width + x
                    val oldPixel = grayscale[index]

                    val newPixel = if (oldPixel > 128f) 255f else 0f
                    grayscale[index] = newPixel

                    val error = oldPixel - newPixel

                    if (x + 1 < width) {
                        grayscale[index + 1] += error * 7f / 16f
                    }
                    if (y + 1 < height) {
                        if (x > 0) {
                            grayscale[index + width - 1] += error * 3f / 16f
                        }
                        grayscale[index + width] += error * 5f / 16f
                        if (x + 1 < width) {
                            grayscale[index + width + 1] += error * 1f / 16f
                        }
                    }
                }
            }

            for (y in 0 until height) {
                for (x in 0 until width) {
                    val index = y * width + x

                    if (grayscale[index] < 128f) {
                        val byteIndex = y * widthBytes + (x / 8)
                        val bitIndex = 7 - (x % 8)
                        data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
                    }
                }
            }

            println("✅ Converted to monochrome: ${width}x${height}, ${data.size} bytes")
            return MonochromeData(width, height, data)

        } catch (e: Exception) {
            println("❌ Monochrome conversion error: ${e.message}")
            e.printStackTrace()
            return null
        }
    }

    private fun containsComplexUnicode(text: String): Boolean {
        for (char in text) {
            val code = char.code
            if (code in 0x1780..0x17FF ||
                code in 0x0E00..0x0E7F ||
                code in 0x4E00..0x9FFF ||
                code in 0xAC00..0xD7AF
            ) {
                return true
            }
        }
        return false
    }

    private fun wrapText(text: String, maxCharsPerLine: Int): String {
        return wrapTextToList(text, maxCharsPerLine).joinToString("\n")
    }

    private fun wrapTextToList(text: String, maxCharsPerLine: Int): List<String> {
        if (maxCharsPerLine <= 0) return listOf(text)

        val lines = mutableListOf<String>()
        val words = text.split(" ")
        var currentLine = StringBuilder()

        for (word in words) {
            if (word.length > maxCharsPerLine) {
                if (currentLine.isNotEmpty()) {
                    lines.add(currentLine.toString().trim())
                    currentLine = StringBuilder()
                }

                var remaining = word
                while (remaining.length > maxCharsPerLine) {
                    lines.add(remaining.take(maxCharsPerLine))
                    remaining = remaining.drop(maxCharsPerLine)
                }
                if (remaining.isNotEmpty()) {
                    currentLine.append(remaining).append(" ")
                }
                continue
            }

            val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"

            if (getVisualWidth(testLine) <= maxCharsPerLine) {
                if (currentLine.isNotEmpty()) currentLine.append(" ")
                currentLine.append(word)
            } else {
                if (currentLine.isNotEmpty()) {
                    lines.add(currentLine.toString().trim())
                }
                currentLine = StringBuilder(word).append(" ")
            }
        }

        if (currentLine.isNotEmpty()) {
            lines.add(currentLine.toString().trim())
        }

        return lines.ifEmpty { listOf("") }
    }

    private fun getVisualWidth(text: String): Double {
        var width = 0.0
        val debug = StringBuilder()

        for (char in text) {
            val code = char.code
            val charWidth = when {
                code in 0x17B4..0x17DD -> 0.0   // Combining marks FIRST
                code in 0x1780..0x17FF -> 0.75  // Base characters
                code in 0x0E00..0x0E7F -> 1.2
                code in 0x4E00..0x9FFF -> 2.0
                code in 0xAC00..0xD7AF -> 2.0
                else -> 1.0
            }
            width += charWidth
            debug.append("[$char=${String.format("U+%04X", code)}=$charWidth] ")
        }

        println("📏 Visual width for '$text': $width")
        println("   Details: $debug")

        return width
    }


    // ====================================================================
    // Paper Control
    // ====================================================================
    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
        scope.launch {
            printMutex.withLock {
                try {
                    val commands = ByteArray(lines) { 0x0A.toByte() }
                    addToBuffer(commands)

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        result.error("FEED_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    private fun cutPaper(result: MethodChannel.Result) {
        scope.launch {
            printMutex.withLock {
                try {
                    val commands = byteArrayOf(GS, 0x56, 0x00)
                    addToBuffer(commands)

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }
                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        result.error("CUT_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    private fun setPrinterWidth(width: Int, result: MethodChannel.Result) {
        printerWidth = width
        println("✅ Printer width set to $width dots (${if (width == 384) "58mm" else "80mm"})")
        result.success(true)
    }

    // ====================================================================
    // Status & Permissions
    // ====================================================================
    private fun getStatus(result: MethodChannel.Result) {
        val hasPermission = checkBluetoothPermissions()
        val isEnabled = bluetoothAdapter?.isEnabled ?: false
        val isConnected = when (currentConnectionType) {
            ConnectionType.BLUETOOTH_CLASSIC -> bluetoothSocket?.isConnected ?: false
            ConnectionType.BLUETOOTH_BLE -> bluetoothGatt != null && writeCharacteristic != null
            ConnectionType.NETWORK -> networkSocket?.isConnected ?: false
            else -> false
        }

        val status = mapOf(
            "status" to if (hasPermission) "authorized" else "denied",
            "enabled" to isEnabled,
            "connected" to isConnected,
            "connectionType" to currentConnectionType.name.lowercase(),
            "printerWidth" to printerWidth
        )

        result.success(status)
    }

    private fun checkBluetoothPermission(result: MethodChannel.Result) {
        result.success(checkBluetoothPermissions())
    }

    private fun checkBluetoothPermissions(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED &&
                    ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_SCAN
                    ) == PackageManager.PERMISSION_GRANTED
        }

        @Suppress("DEPRECATION")
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.BLUETOOTH
        ) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.BLUETOOTH_ADMIN
                ) == PackageManager.PERMISSION_GRANTED
    }

    // ====================================================================
    // Font Management
    // ====================================================================
    private fun getKhmerTypeface(bold: Boolean): Typeface {
        val fontKey = if (bold) "bold" else "regular"

        return khmerTypefaceCache.getOrPut(fontKey) {
            try {
                val fontPath = when {
                    bold -> {
                        when {
                            assetExists("fonts/NotoSansKhmer-Bold.ttf") -> "fonts/NotoSansKhmer-Bold.ttf"
                            assetExists("fonts/NotoSansKhmer-SemiBold.ttf") -> "fonts/NotoSansKhmer-SemiBold.ttf"
                            assetExists("fonts/NotoSansKhmer-Medium.ttf") -> "fonts/NotoSansKhmer-Medium.ttf"
                            else -> "fonts/NotoSansKhmer-Regular.ttf"
                        }
                    }
                    else -> "fonts/NotoSansKhmer-Regular.ttf"
                }

                println("✅ Loading font: $fontPath")
                Typeface.createFromAsset(context.assets, fontPath)
            } catch (e: Exception) {
                println("⚠️ Failed to load Khmer font: ${e.message}")
                Typeface.DEFAULT
            }
        }
    }

    private fun assetExists(path: String): Boolean {
        return try {
            context.assets.open(path).use { true }
        } catch (e: Exception) {
            false
        }
    }

    private fun preloadFonts() {
        scope.launch(Dispatchers.IO) {
            println("🔄 Preloading fonts...")
            getKhmerTypeface(false)
            getKhmerTypeface(true)
            println("✅ Fonts preloaded")
        }
    }
}



//package com.clearviewerp.salesforce
//
//import android.Manifest
//import android.bluetooth.*
//import android.content.BroadcastReceiver
//import android.content.Context
//import android.content.Intent
//import android.content.IntentFilter
//import android.content.pm.PackageManager
//import android.graphics.*
//import android.hardware.usb.UsbManager
//import android.os.Build
//import android.os.Handler
//import android.os.Looper
//import androidx.core.app.ActivityCompat
//import io.flutter.embedding.engine.plugins.FlutterPlugin
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import kotlinx.coroutines.*
//import kotlinx.coroutines.sync.Mutex
//import kotlinx.coroutines.sync.withLock
//import java.net.Socket
//import java.util.*
//import java.util.concurrent.ConcurrentHashMap
//import java.util.concurrent.CountDownLatch
//import java.util.concurrent.TimeUnit
//
//// ====================================================================
//// Configuration
//// ====================================================================
//object PrinterConfig {
//    const val DEFAULT_PRINTER_WIDTH = 576 // 80mm
//    const val SMALL_PRINTER_WIDTH = 384 // 58mm
//    const val CONNECTION_TIMEOUT = 15000L
//
//}
//
//// ====================================================================
//// Data Classes
//// ====================================================================
//data class MonochromeData(val width: Int, val height: Int, val data: ByteArray) {
//    override fun equals(other: Any?): Boolean {
//        if (this === other) return true
//        if (javaClass != other?.javaClass) return false
//        other as MonochromeData
//        return width == other.width && height == other.height && data.contentEquals(other.data)
//    }
//
//    override fun hashCode(): Int {
//        var result = width
//        result = 31 * result + height
//        result = 31 * result + data.contentHashCode()
//        return result
//    }
//}
//
//data class PosColumn(
//    val text: String,
//    val width: Int,
//    val align: String,
//    val bold: Boolean
//)
//
//enum class ImageAlignment(val value: Int) {
//    LEFT(0),
//    CENTER(1),
//    RIGHT(2);
//
//    companion object {
//        fun fromInt(value: Int) = values().firstOrNull { it.value == value } ?: CENTER
//    }
//}
//
//enum class ConnectionType {
//    BLUETOOTH_CLASSIC,
//    BLUETOOTH_BLE,
//    NETWORK,
//    USB,
//    NONE
//}
//
//private var printerModel: PrinterModel = PrinterModel.UNKNOWN
//
//
//enum class PrinterModel {
//    UNKNOWN,
//    SLOW,      // Old printers (50 bytes/ms)
//    MEDIUM,    // Standard printers (80 bytes/ms)
//    FAST       // Modern printers (120 bytes/ms)
//}
//private var printerSpeed: PrinterSpeed = PrinterSpeed.UNKNOWN
//
//
//enum class PrinterSpeed {
//    UNKNOWN,
//    SLOW,      // < 3 bytes/ms
//    MEDIUM,    // 3-6 bytes/ms
//    FAST       // > 6 bytes/ms
//}
//// ====================================================================
//// Main Plugin Class
//// ====================================================================
//class ThermalPrinterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
//
//    private lateinit var channel: MethodChannel
//    private lateinit var context: Context
//    private val mainHandler = Handler(Looper.getMainLooper())
//
//    // Bluetooth
//    private var bluetoothAdapter: BluetoothAdapter? = null
//    private var bluetoothGatt: BluetoothGatt? = null
//    private var writeCharacteristic: BluetoothGattCharacteristic? = null
//    private var bluetoothSocket: android.bluetooth.BluetoothSocket? = null
//    private val discoveredDevices = Collections.synchronizedList(mutableListOf<BluetoothDevice>())
//    private var discoveryReceiver: BroadcastReceiver? = null
//
//    // USB
//    private var usbManager: UsbManager? = null
//
//    // Network
//    private var networkSocket: Socket? = null
//
//    // Connection state
//    @Volatile
//    private var currentConnectionType = ConnectionType.NONE
//    private var printerWidth = PrinterConfig.DEFAULT_PRINTER_WIDTH
//
//    // ESC/POS Commands
//    private val ESC: Byte = 0x1B
//    private val GS: Byte = 0x1D
//
//    // Coroutine scope
//    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
//    private val printMutex = Mutex()
//
//    // Write synchronization
//    private val writeSync = Object()
//    @Volatile private var writeCompleted = false
//    private var writeLatch: CountDownLatch? = null
//    private var currentWriteDeferred: CompletableDeferred<Boolean>? = null
//
//    // Pending results (thread-safe)
//    private val pendingResults = ConcurrentHashMap<String, MethodChannel.Result>()
//
//    // Font cache
//    private val khmerTypefaceCache = ConcurrentHashMap<String, Typeface>()
//    private val receiptBuffer = mutableListOf<Byte>()
//    private var isBatchMode = false
//
//
//    // ====================================================================
//    // Plugin Lifecycle
//    // ====================================================================
//    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        context = binding.applicationContext
//        channel = MethodChannel(binding.binaryMessenger, "thermal_printer_80mm")
//        channel.setMethodCallHandler(this)
//
//        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
//        bluetoothAdapter = bluetoothManager?.adapter
//        usbManager = context.getSystemService(Context.USB_SERVICE) as? UsbManager
//
//        preloadFonts()
//        println("🔵 ThermalPrinterPlugin initialized")
//    }
//
//    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        channel.setMethodCallHandler(null)
//
//        // Cleanup connections
//        cleanupAllConnections()
//
//        // Unregister discovery receiver
//        discoveryReceiver?.let {
//            try {
//                context.unregisterReceiver(it)
//            } catch (e: IllegalArgumentException) {
//                println("⚠️ Receiver already unregistered")
//            }
//        }
//
//        // Cancel coroutines
//        scope.cancel()
//
//        // Clear caches
//        khmerTypefaceCache.clear()
//        pendingResults.clear()
//    }
//
//    //=======================================test===============
//
//    private fun startBatchMode() {
//        receiptBuffer.clear()
//        isBatchMode = true
//
//        // ✅ CRITICAL: Initialize printer ONCE at the start
//        val initCommands = mutableListOf<Byte>()
//        initCommands.addAll(listOf(ESC, 0x40))           // Reset printer
//        initCommands.addAll(listOf(ESC, 0x74, 0x01))     // Set code page
//        initCommands.addAll(listOf(ESC, 0x33, 0x30))     // Set line spacing
//
//        receiptBuffer.addAll(initCommands)
//
//        println("📦 Started batch mode with initialization")
//    }
//
//    private fun endBatchMode() {
//        isBatchMode = false
//        if (receiptBuffer.isNotEmpty()) {
//            println("📤 Optimizing and sending batched receipt: ${receiptBuffer.size} bytes")
//
//            // ✅ CRITICAL: Optimize the data before sending
//            val optimizedData = optimizeLineFeeds(receiptBuffer.toByteArray())
//
//            println("✅ Optimized: ${receiptBuffer.size} → ${optimizedData.size} bytes")
//
//            writeDataSmooth(optimizedData)
//            receiptBuffer.clear()
//        }
//    }
//
//    private fun addToBuffer(data: ByteArray) {
//        if (isBatchMode) {
//            receiptBuffer.addAll(data.toList())
//            println("➕ Added ${data.size} bytes to buffer (total: ${receiptBuffer.size})")
//        } else {
//            writeDataSmooth(data)
//        }
//    }
//
//    private fun testPaperFeed(result: MethodChannel.Result) {
//        scope.launch(Dispatchers.IO) {
//            try {
//                println("🧪 TEST 1: Paper Feed Test")
//                println("Listen for 'stuck stuck' sound...")
//
//                // Test A: Feed paper only (no printing)
//                val feedCommand = ByteArray(10) { 0x0A.toByte() } // 10 line feeds
//                writeDataSmooth(feedCommand)
//                Thread.sleep(2000)
//
//                // If "stuck stuck" happens here → PAPER PROBLEM (not code)
//                // If smooth → Code/data problem
//
//                withContext(Dispatchers.Main) {
//                    result.success(mapOf(
//                        "test" to "paper_feed",
//                        "instruction" to "Did you hear 'stuck stuck' during paper feed? YES = Paper problem, NO = Code problem"
//                    ))
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("TEST_ERROR", e.message, null)
//                }
//            }
//        }
//    }
//
//    // ====================================================================
//// DIAGNOSTIC TEST 2: Print simple text slowly
//// ====================================================================
//    private fun testSlowPrint(result: MethodChannel.Result) {
//        scope.launch(Dispatchers.IO) {
//            try {
//                println("🧪 TEST 2: Slow Print Test")
//
//                val commands = mutableListOf<Byte>()
//                commands.addAll(listOf(ESC, 0x40)) // Initialize
//                commands.addAll("TEST LINE 1".toByteArray(charset("CP437")).toList())
//                commands.add(0x0A.toByte())
//
//                writeDataSmooth(commands.toByteArray())
//                Thread.sleep(1000) // Wait 1 second
//
//                commands.clear()
//                commands.addAll("TEST LINE 2".toByteArray(charset("CP437")).toList())
//                commands.add(0x0A.toByte())
//
//                writeDataSmooth(commands.toByteArray())
//                Thread.sleep(1000)
//
//                commands.clear()
//                commands.addAll("TEST LINE 3".toByteArray(charset("CP437")).toList())
//                commands.add(0x0A.toByte())
//
//                writeDataSmooth(commands.toByteArray())
//
//                withContext(Dispatchers.Main) {
//                    result.success(mapOf(
//                        "test" to "slow_print",
//                        "instruction" to "Was it smooth? If YES → code was too fast before, If NO → hardware issue"
//                    ))
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("TEST_ERROR", e.message, null)
//                }
//            }
//        }
//    }
//
//    // ====================================================================
//// DIAGNOSTIC TEST 3: Check printer buffer status
//// ====================================================================
//    private fun checkPrinterStatus(result: MethodChannel.Result) {
//        scope.launch(Dispatchers.IO) {
//            try {
//                println("🧪 TEST 3: Printer Status Check")
//
//                // ESC/POS command to get printer status
//                val statusCommand = byteArrayOf(0x10, 0x04, 0x01) // DLE EOT n
//
//                writeDataSmooth(statusCommand)
//                Thread.sleep(100)
//
//                // Try to read response (if available)
//                val status = when (currentConnectionType) {
//                    ConnectionType.BLUETOOTH_CLASSIC -> {
//                        try {
//                            val inputStream = bluetoothSocket?.inputStream
//                            if (inputStream?.available() ?: 0 > 0) {
//                                val buffer = ByteArray(10)
//                                val read = inputStream?.read(buffer)
//                                "Status bytes read: $read"
//                            } else {
//                                "No response from printer"
//                            }
//                        } catch (e: Exception) {
//                            "Error reading: ${e.message}"
//                        }
//                    }
//                    else -> "Status check only available for Classic BT"
//                }
//
//                withContext(Dispatchers.Main) {
//                    result.success(mapOf(
//                        "test" to "status_check",
//                        "status" to status
//                    ))
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("TEST_ERROR", e.message, null)
//                }
//            }
//        }
//    }
//
//
//
//    // ====================================================================
//// FIX 5: Initialize printer with optimal settings
//// ====================================================================
//    private fun initializePrinterOptimal() {
//        println("🔧 Initializing printer with optimal settings...")
//
//        val commands = mutableListOf<Byte>()
//
//        // 1. Reset printer
//        commands.addAll(listOf(ESC, 0x40))
//
//        // 2. Set print mode to normal (not bold/emphasized)
//        commands.addAll(listOf(ESC, 0x21, 0x00))
//
//        // 3. Set line spacing (looser = smoother)
//        commands.addAll(listOf(ESC, 0x33, 0x40.toByte())) // 64/180 inch
//
//        // 4. Set print speed (if supported)
//        // Some printers support: GS ( K <pL> <pH> <cn> <fn> <n>
//
//        // 5. Disable double-strike mode (reduces mechanical stress)
//        commands.addAll(listOf(ESC, 0x47, 0x00))
//
//        writeDataSmooth(commands.toByteArray())
//        Thread.sleep(200) // Wait for settings to apply
//
//        println("✅ Printer initialized with smooth settings")
//    }
//
//
//    // ====================================================================
//// COMPLETE DIAGNOSTIC FLOW
//// ====================================================================
//    fun runCompleteDiagnostic(result: MethodChannel.Result) {
//        scope.launch(Dispatchers.IO) {
//            try {
//                val diagnosticResults = mutableMapOf<String, String>()
//
//                println("""
//                ═══════════════════════════════════════
//                🔍 COMPLETE PRINTER DIAGNOSTIC
//                ═══════════════════════════════════════
//            """.trimIndent())
//
//                // Test 1: Paper feed only
//                println("\n▶️ TEST 1: Paper Feed Test")
//                val feedCommand = ByteArray(5) { 0x0A.toByte() }
//                writeDataSmooth(feedCommand)
//                Thread.sleep(2000)
//                diagnosticResults["paper_feed"] = "Check if 'stuck stuck' sound occurred"
//
//                // Test 2: Single line text
//                println("\n▶️ TEST 2: Single Line Test")
//                val textCommand = "TEST LINE\n".toByteArray(charset("CP437"))
//                writeDataSmooth(textCommand)
//                Thread.sleep(2000)
//                diagnosticResults["single_line"] = "Check if smooth"
//
//                // Test 3: Multiple lines with delays
//                println("\n▶️ TEST 3: Multiple Lines (with delays)")
//                for (i in 1..3) {
//                    val line = "Line $i\n".toByteArray(charset("CP437"))
//                    writeDataSmooth(line)
//                    Thread.sleep(500) // 500ms between lines
//                }
//                diagnosticResults["multiple_lines"] = "Check if smooth with delays"
//
//                // Test 4: Multiple lines fast
//                println("\n▶️ TEST 4: Multiple Lines (fast)")
//                val fastLines = "Fast Line 1\nFast Line 2\nFast Line 3\n".toByteArray(charset("CP437"))
//                writeDataSmooth(fastLines)
//                Thread.sleep(2000)
//                diagnosticResults["fast_lines"] = "Check if 'stuck stuck' occurs when fast"
//
//                println("""
//
//                ═══════════════════════════════════════
//                📊 DIAGNOSTIC RESULTS
//                ═══════════════════════════════════════
//                ${diagnosticResults.entries.joinToString("\n") { "${it.key}: ${it.value}" }}
//
//                ═══════════════════════════════════════
//                📋 INTERPRETATION:
//                ═══════════════════════════════════════
//                ✅ If smooth in TEST 3 (slow) but stuck in TEST 4 (fast)
//                   → SOLUTION: Add delays between commands
//
//                ✅ If stuck in TEST 1 (paper feed only)
//                   → PROBLEM: Paper or mechanical issue (not code)
//                   → CHECK: Paper quality, paper sensor, roller
//
//                ✅ If stuck in all tests
//                   → PROBLEM: Printer hardware issue
//                   → CHECK: Battery, print head, motor
//
//                ✅ If smooth in all tests
//                   → PROBLEM: Complex data causing issues
//                   → SOLUTION: Use ultra-smooth mode for images
//                ═══════════════════════════════════════
//            """.trimIndent())
//
//                withContext(Dispatchers.Main) {
//                    result.success(diagnosticResults)
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("DIAGNOSTIC_ERROR", e.message, null)
//                }
//            }
//        }
//    }
//
//
//    private fun cleanupAllConnections() {
//        try {
//            bluetoothSocket?.close()
//            bluetoothSocket = null
//
//            bluetoothGatt?.disconnect()
//            bluetoothGatt?.close()
//            bluetoothGatt = null
//            writeCharacteristic = null
//
//            networkSocket?.close()
//            networkSocket = null
//
//            currentConnectionType = ConnectionType.NONE
//            println("🧹 All connections cleaned up")
//        } catch (e: Exception) {
//            println("⚠️ Cleanup error: ${e.message}")
//        }
//    }
//
//    // ====================================================================
//    // Method Call Handler
//    // ====================================================================
//    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        when (call.method) {
//            "startBatch" -> {
//                startBatchMode()
//                result.success(true)
//            }
//
//            "printSeparator" -> {
//                val width = call.argument<Int>("width") ?: 48
//                printSeparator(width, result)
//            }
//
//            "endBatch" -> {
//                endBatchMode()
//                result.success(true)
//            }
//            "configureOOMAS" -> {
//                configureForOOMAS()
//                result.success(true)
//            }
//
//            "warmUpPrinter" -> {
//                warmUpPrinter()
//                result.success(true)
//            }
//
//            "testPaperFeed" -> testPaperFeed(result)
//            "testSlowPrint" -> testSlowPrint(result)
//            "checkPrinterStatus" -> checkPrinterStatus(result)
//            "runDiagnostic" -> runCompleteDiagnostic(result)
//            "initializePrinter" -> {
//                initializePrinterOptimal()
//                result.success(true)
//            }
//            "discoverPrinters" -> {
//                val type = call.argument<String>("type")
//                if (type != null) {
//                    discoverPrinters(type, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing type", null)
//                }
//            }
//
//            "discoverAllPrinters" -> discoverAllPrinters(result)
//
//            "connect" -> {
//                val address = call.argument<String>("address")
//                val type = call.argument<String>("type")
//                if (address != null && type != null) {
//                    connect(address, type, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing arguments", null)
//                }
//            }
//
//            "connectNetwork" -> {
//                val ipAddress = call.argument<String>("ipAddress")
//                val port = call.argument<Int>("port") ?: 9100
//                if (ipAddress != null) {
//                    connectNetwork(ipAddress, port, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing IP address", null)
//                }
//            }
//
//            "disconnect" -> disconnect(result)
//
//            "printText" -> {
//                val text = call.argument<String>("text")
//                val fontSize = call.argument<Int>("fontSize") ?: 24
//                val bold = call.argument<Boolean>("bold") ?: false
//                val align = call.argument<String>("align") ?: "left"
//                val maxCharsPerLine = call.argument<Int>("maxCharsPerLine") ?: 0
//                if (text != null) {
//                    printText(text, fontSize, bold, align, maxCharsPerLine, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing text", null)
//                }
//            }
//
//            "printRow" -> {
//                val columns = call.argument<List<Map<String, Any>>>("columns") ?: emptyList()
//                val fontSize = call.argument<Int>("fontSize") ?: 24
//                printRow(columns, fontSize, result)
//            }
//
//            "printImage" -> {
//                val imageBytes = call.argument<ByteArray>("imageBytes")
//                val width = call.argument<Int>("width") ?: printerWidth
//                val align = call.argument<Int>("align") ?: 1
//                if (imageBytes != null) {
//                    printImage(imageBytes, width, align, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing imageBytes", null)
//                }
//            }
//
//            "printImageWithPadding" -> {
//                val imageBytes = call.argument<ByteArray>("imageBytes")
//                val width = call.argument<Int>("width") ?: 384
//                val align = call.argument<Int>("align") ?: 1
//                val paperWidth = call.argument<Int>("paperWidth") ?: 576
//
//                if (imageBytes == null) {
//                    result.error("INVALID_ARGUMENT", "imageBytes is required", null)
//                    return
//                }
//
//                printImageWithPadding(imageBytes, width, align, paperWidth, result)
//            }
//
//            "feedPaper" -> {
//                val lines = call.argument<Int>("lines") ?: 1
//                feedPaper(lines, result)
//            }
//
//            "cutPaper" -> cutPaper(result)
//
//            "getStatus" -> getStatus(result)
//
//            "setPrinterWidth" -> {
//                val width = call.argument<Int>("width")
//                if (width != null) {
//                    setPrinterWidth(width, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing width", null)
//                }
//            }
//
//            "checkBluetoothPermission" -> checkBluetoothPermission(result)
//
//            else -> result.notImplemented()
//        }
//    }
//
//
//
//    // ====================================================================
//    // Discovery Methods
//    // ====================================================================
//    private fun discoverPrinters(type: String, result: MethodChannel.Result) {
//        when (type) {
//            "bluetooth", "ble" -> discoverBluetoothPrinters(result)
//            "usb" -> discoverUSBPrinters(result)
//            "network" -> result.success(emptyList<Map<String, Any>>())
//            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
//        }
//    }
//
//    private fun discoverAllPrinters(result: MethodChannel.Result) {
//        if (!checkBluetoothPermissions()) {
//            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
//            return
//        }
//
//        discoveredDevices.clear()
//
//        try {
//            bluetoothAdapter?.bondedDevices?.forEach { device ->
//                discoveredDevices.add(device)
//            }
//        } catch (e: SecurityException) {
//            result.error("PERMISSION_DENIED", e.message, null)
//            return
//        }
//
//        val allPrinters = mutableListOf<Map<String, Any>>()
//
//        // Add Bluetooth devices
//        discoveredDevices.forEach { device ->
//            try {
//                val deviceName = device.name
//                if (!deviceName.isNullOrBlank() && deviceName != "Unknown Device") {
//                    allPrinters.add(
//                        mapOf(
//                            "name" to deviceName,
//                            "address" to device.address,
//                            "type" to "bluetooth"
//                        )
//                    )
//                }
//            } catch (e: SecurityException) {
//                println("⚠️ Cannot access device: ${e.message}")
//            }
//        }
//
//        // Add USB devices
//        usbManager?.deviceList?.values?.forEach { device ->
//            allPrinters.add(
//                mapOf(
//                    "name" to device.deviceName,
//                    "address" to device.deviceId.toString(),
//                    "type" to "usb"
//                )
//            )
//        }
//
//        result.success(allPrinters)
//    }
//
//    private fun discoverBluetoothPrinters(result: MethodChannel.Result) {
//        if (!checkBluetoothPermissions()) {
//            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
//            return
//        }
//
//        discoveredDevices.clear()
//
//        try {
//            bluetoothAdapter?.bondedDevices?.forEach { device ->
//                discoveredDevices.add(device)
//            }
//
//            if (bluetoothAdapter?.isDiscovering == true) {
//                bluetoothAdapter?.cancelDiscovery()
//            }
//            bluetoothAdapter?.startDiscovery()
//
//            registerDiscoveryReceiver(result)
//        } catch (e: SecurityException) {
//            result.error("PERMISSION_DENIED", e.message, null)
//        }
//    }
//
//    private fun registerDiscoveryReceiver(result: MethodChannel.Result) {
//        discoveryReceiver?.let {
//            try {
//                context.unregisterReceiver(it)
//            } catch (e: IllegalArgumentException) {
//                // Already unregistered
//            }
//        }
//
//        val receiver = object : BroadcastReceiver() {
//            override fun onReceive(context: Context?, intent: Intent?) {
//                when (intent?.action) {
//                    BluetoothDevice.ACTION_FOUND -> {
//                        val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
//                        device?.let {
//                            val deviceName = it.name
//                            // ✅ Skip if name is null, empty, or "Unknown"
//                            if (!deviceName.isNullOrEmpty() &&
//                                deviceName != "Unknown" &&
//                                !discoveredDevices.contains(it)) {
//                                discoveredDevices.add(it)
//                                println("📱 Found device: $deviceName (${it.address})")
//                            } else {
//                                println("⏭️ Skipped device: ${deviceName ?: "null"} (${it.address})")
//                            }
//                        }
//                    }
//                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
//                        println("🔍 Discovery finished. Named devices: ${discoveredDevices.size}")
//                        returnDiscoveredDevices(result)
//                        try {
//                            context?.unregisterReceiver(this)
//                            discoveryReceiver = null
//                        } catch (e: IllegalArgumentException) {
//                            // Already unregistered
//                        }
//                    }
//}
//                // when (intent?.action) {
//                //     BluetoothDevice.ACTION_FOUND -> {
//                //         val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
//                //         device?.let {
//                //             if (!discoveredDevices.contains(it)) {
//                //                 discoveredDevices.add(it)
//                //                 println("📱 Found device: ${it.name ?: "Unknown"} (${it.address})")
//                //             }
//                //         }
//                //     }
//                //     BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
//                //         println("🔍 Discovery finished. Total devices: ${discoveredDevices.size}")
//                //         returnDiscoveredDevices(result)
//                //         try {
//                //             context?.unregisterReceiver(this)
//                //             discoveryReceiver = null
//                //         } catch (e: IllegalArgumentException) {
//                //             // Already unregistered
//                //         }
//                //     }
//                // }
//            }
//        }
//
//        val filter = IntentFilter().apply {
//            addAction(BluetoothDevice.ACTION_FOUND)
//            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
//        }
//
//        discoveryReceiver = receiver
//        context.registerReceiver(receiver, filter)
//        println("🔍 Starting Bluetooth discovery...")
//    }
//
//    private fun returnDiscoveredDevices(result: MethodChannel.Result) {
//        try {
//            val printers = discoveredDevices.map { device ->
//                mapOf(
//                    "name" to (device.name ?: "Unknown Device"),
//                    "address" to device.address,
//                    "type" to "bluetooth"
//                )
//            }
//            result.success(printers)
//        } catch (e: SecurityException) {
//            result.error("PERMISSION_DENIED", e.message, null)
//        }
//    }
//
//    private fun discoverUSBPrinters(result: MethodChannel.Result) {
//        val devices = usbManager?.deviceList?.values?.map { device ->
//            mapOf(
//                "name" to device.deviceName,
//                "address" to device.deviceId.toString(),
//                "type" to "usb"
//            )
//        } ?: emptyList()
//
//        result.success(devices)
//    }
//
//    // ====================================================================
//    // Connection Methods
//    // ====================================================================
//    private fun connect(address: String, type: String, result: MethodChannel.Result) {
//        println("🔵 Connect request: address=$address, type=$type")
//
//        when (type) {
//            "bluetooth" -> connectClassicBluetooth(address, result)
//            "ble" -> connectBLE(address, result)
//            "usb" -> result.error("NOT_IMPLEMENTED", "USB not yet implemented", null)
//            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
//        }
//    }
//
//    private fun connectClassicBluetooth(address: String, result: MethodChannel.Result) {
//        if (!checkBluetoothPermissions()) {
//            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
//            return
//        }
//
//        if (bluetoothAdapter?.isEnabled != true) {
//            result.error("BLUETOOTH_OFF", "Bluetooth is turned off", null)
//            return
//        }
//
//        scope.launch(Dispatchers.IO) {
//            try {
//                val device = bluetoothAdapter?.getRemoteDevice(address)
//                if (device == null) {
//                    withContext(Dispatchers.Main) {
//                        result.error("NOT_FOUND", "Device not found", null)
//                    }
//                    return@launch
//                }
//
//                println("🔵 Connecting via Classic Bluetooth: ${device.name} ($address)")
//
//                // Close existing socket if any
//                bluetoothSocket?.close()
//
//                // Cancel discovery to improve connection
//                bluetoothAdapter?.cancelDiscovery()
//
//                // Try multiple UUIDs
//                val uuids = listOf(
//                    "00001101-0000-1000-8000-00805F9B34FB", // SPP (Standard)
//                    "00001102-0000-1000-8000-00805F9B34FB", // LAN Access Using PPP
//                    "00001103-0000-1000-8000-00805F9B34FB"  // Dialup Networking
//                )
//
//                var connected = false
//                var lastException: Exception? = null
//
//                for (uuidString in uuids) {
//                    try {
//                        val uuid = UUID.fromString(uuidString)
//                        println("🔵 Trying UUID: $uuidString")
//
//                        bluetoothSocket = device.createRfcommSocketToServiceRecord(uuid)
//
//                        println("🔵 Attempting SPP connection...")
//                        bluetoothSocket?.connect()
//
//                        if (bluetoothSocket?.isConnected == true) {
//                            println("✅ Classic Bluetooth Connected with UUID: $uuidString!")
//                            connected = true
//                            break
//                        }
//                    } catch (e: Exception) {
//                        println("❌ Failed with UUID $uuidString: ${e.message}")
//                        lastException = e
//                        bluetoothSocket?.close()
//                        bluetoothSocket = null
//                    }
//                }
//
//                if (connected) {
//                    // ============================================================
//                    // ✅ ADD THIS SECTION HERE - AFTER CONNECTION SUCCESS
//                    // ============================================================
//                    currentConnectionType = ConnectionType.BLUETOOTH_CLASSIC
//
//                    // Initialize printer with smooth settings
//                    try {
//                        initializePrinterForSmoothPrinting()
//                        println("✅ Printer initialized for smooth printing")
//                    } catch (e: Exception) {
//                        println("⚠️ Could not initialize printer settings: ${e.message}")
//                        // Continue anyway - connection still works
//                    }
//                    // ============================================================
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } else {
//                    throw lastException ?: Exception("Failed to connect with all UUIDs")
//                }
//            } catch (e: SecurityException) {
//                println("❌ Security exception: ${e.message}")
//                withContext(Dispatchers.Main) {
//                    result.error("PERMISSION_DENIED", e.message, null)
//                }
//            } catch (e: Exception) {
//                println("❌ Classic Bluetooth connection failed: ${e.message}")
//                println("📋 Stack trace: ${e.stackTraceToString()}")
//                // If Classic fails, try BLE as fallback
//                println("🔄 Falling back to BLE connection...")
//                withContext(Dispatchers.Main) {
//                    connectBLE(address, result)
//                }
//            }
//        }
//    }
//
//    private fun connectBLE(address: String, result: MethodChannel.Result) {
//        if (!checkBluetoothPermissions()) {
//            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
//            return
//        }
//
//        if (bluetoothAdapter?.isEnabled != true) {
//            result.error("BLUETOOTH_OFF", "Bluetooth is turned off", null)
//            return
//        }
//
//        try {
//            val device = bluetoothAdapter?.getRemoteDevice(address)
//            if (device == null) {
//                result.error("NOT_FOUND", "Device not found", null)
//                return
//            }
//
//            cleanupBeforeConnect()
//
//            val resultKey = "connection_$address"
//            pendingResults[resultKey] = result
//
//            bluetoothGatt = device.connectGatt(
//                context,
//                false,
//                createGattCallback(resultKey),
//                BluetoothDevice.TRANSPORT_LE
//            )
//
//            // Timeout handler
//            mainHandler.postDelayed({
//                if (pendingResults.remove(resultKey) != null) {
//                    println("⏱️ BLE Connection timeout")
//                    result.error("TIMEOUT", "Connection timeout after ${PrinterConfig.CONNECTION_TIMEOUT}ms", null)
//                    bluetoothGatt?.disconnect()
//                    bluetoothGatt?.close()
//                    bluetoothGatt = null
//                }
//            }, PrinterConfig.CONNECTION_TIMEOUT)
//
//        } catch (e: SecurityException) {
//            result.error("PERMISSION_DENIED", e.message, null)
//        } catch (e: Exception) {
//            result.error("CONNECTION_ERROR", e.message, null)
//        }
//    }
//
//    private fun getRequiredDelay(dataSize: Int): Long {
//        // Only add delay for LARGE data (images)
//        return when {
//            dataSize > 2000 -> when (printerSpeed) {
//                PrinterSpeed.SLOW -> 200L
//                PrinterSpeed.MEDIUM -> 100L
//                PrinterSpeed.FAST -> 50L
//                PrinterSpeed.UNKNOWN -> 100L
//            }
//            dataSize > 1000 -> 50L
//            else -> 0L  // NO DELAY for small text commands!
//        }
//    }
//
//
//    // ====================================================================
//// FIX 3: Optimized writeDataSmooth - NO unnecessary delays
//// ====================================================================
//    private fun writeDataSmooth(data: ByteArray) {
//        val startTime = System.currentTimeMillis()
//
//        // Count line feeds to know if we need delays
//        val lineFeeds = data.count { it == 0x0A.toByte() }
//        val hasImageData = data.size > 1000
//
//        try {
//            when (currentConnectionType) {
//                ConnectionType.BLUETOOTH_CLASSIC -> {
//                    bluetoothSocket?.let { socket ->
//                        if (socket.isConnected) {
//                            // Write the data
//                            writeClassicBluetoothWithLineDelay(socket, data, lineFeeds)
//
//                            val elapsed = System.currentTimeMillis() - startTime
//                            println("✅ Classic BT: ${data.size} bytes in ${elapsed}ms")
//                            return
//                        }
//                    }
//                }
//
//                ConnectionType.BLUETOOTH_BLE -> {
//                    writeBLEDataOptimized(data, startTime)
//                    // Add delay after printing if has line feeds
//                    if (lineFeeds > 0) {
//                        Thread.sleep(lineFeeds * 30L) // 30ms per line
//                    }
//                }
//
//                ConnectionType.NETWORK -> {
//                    writeNetworkOptimized(data)
//                    if (lineFeeds > 0) {
//                        Thread.sleep(lineFeeds * 30L)
//                    }
//                }
//
//                else -> println("❌ No active connection")
//            }
//        } catch (e: Exception) {
//            println("❌ Write error: ${e.message}")
//            throw e
//        }
//    }
//
//    private fun writeClassicBluetoothWithLineDelay(
//        socket: android.bluetooth.BluetoothSocket,
//        data: ByteArray,
//        lineFeeds: Int
//    ) {
//        val outputStream = socket.outputStream
//
//        // For data with line feeds, write byte-by-byte and pause at line feeds
//        if (lineFeeds > 0 && data.size < 500) {
//            println("📝 Writing with line feed delays (${lineFeeds} line feeds)")
//
//            for (i in data.indices) {
//                outputStream.write(data[i].toInt())
//
//                // CRITICAL FIX: Pause after each line feed
//                if (data[i] == 0x0A.toByte()) {
//                    outputStream.flush()
//                    Thread.sleep(50L) // 50ms for motor to complete paper feed
//                    println("⏸️ Line feed delay")
//                }
//            }
//            outputStream.flush()
//            return
//        }
//
//        // For large data (images), use chunking
//        if (data.size >= 500) {
//            val chunkSize = 256
//            var offset = 0
//
//            while (offset < data.size) {
//                val end = (offset + chunkSize).coerceAtMost(data.size)
//                val chunk = data.copyOfRange(offset, end)
//
//                outputStream.write(chunk)
//                outputStream.flush()
//
//                // Small delay between chunks
//                if (end < data.size) {
//                    Thread.sleep(15L)
//                }
//
//                offset = end
//            }
//            return
//        }
//
//        // For small data without line feeds, send all at once
//        outputStream.write(data)
//        outputStream.flush()
//    }
//
//
//    // ====================================================================
//// FIX 5: Optimized BLE - Fast for small data
//// ====================================================================
//    private fun writeBLEDataOptimized(data: ByteArray, startTime: Long) {
//        val characteristic = writeCharacteristic
//        val gatt = bluetoothGatt
//
//        if (characteristic == null || gatt == null) {
//            println("❌ No BLE connection")
//            return
//        }
//
//        try {
//            val useNoResponse = (characteristic.properties and
//                    BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
//
//            if (useNoResponse) {
//                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
//
//                // OOMAS-specific BLE settings
//                val chunkSize = 128  // OOMAS works best with 128 byte chunks for BLE
//                val delay = 8L       // Minimal delay for OOMAS BLE
//
//                var offset = 0
//                while (offset < data.size) {
//                    val end = (offset + chunkSize).coerceAtMost(data.size)
//                    val chunk = data.copyOfRange(offset, end)
//
//                    characteristic.value = chunk
//                    gatt.writeCharacteristic(characteristic)
//
//                    if (end < data.size) {
//                        Thread.sleep(delay)
//                    }
//
//                    offset = end
//                }
//            } else {
//                // With response mode
//                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
//                val chunkSize = 20
//
//                var offset = 0
//                while (offset < data.size) {
//                    val end = (offset + chunkSize).coerceAtMost(data.size)
//                    val chunk = data.copyOfRange(offset, end)
//
//                    synchronized(writeSync) {
//                        writeLatch = CountDownLatch(1)
//                        writeCompleted = false
//                    }
//
//                    characteristic.value = chunk
//                    gatt.writeCharacteristic(characteristic)
//
//                    writeLatch?.await(100, TimeUnit.MILLISECONDS)
//                    offset = end
//                }
//            }
//
//            val elapsed = System.currentTimeMillis() - startTime
//            println("✅ BLE: ${elapsed}ms total")
//
//        } catch (e: Exception) {
//            println("❌ BLE Error: ${e.message}")
//            throw e
//        }
//    }
//    private fun warmUpPrinter() {
//        println("🔥 Warming up OOMAS printer...")
//
//        // Send a small warm-up command to stabilize the motor
//        val warmUpData = byteArrayOf(
//            ESC, 0x40,           // Reset
//            0x0A.toByte(),       // One line feed
//        )
//
//        try {
//            when (currentConnectionType) {
//                ConnectionType.BLUETOOTH_CLASSIC -> {
//                    bluetoothSocket?.outputStream?.let { stream ->
//                        stream.write(warmUpData)
//                        stream.flush()
//                        Thread.sleep(100)  // Let motor stabilize
//                    }
//                }
//                ConnectionType.BLUETOOTH_BLE -> {
//                    writeCharacteristic?.let { char ->
//                        bluetoothGatt?.let { gatt ->
//                            char.value = warmUpData
//                            char.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
//                            gatt.writeCharacteristic(char)
//                            Thread.sleep(100)
//                        }
//                    }
//                }
//                else -> {}
//            }
//            println("✅ Printer warmed up")
//        } catch (e: Exception) {
//            println("⚠️ Warm-up failed: ${e.message}")
//        }
//    }
//
//
//
//
//    private fun printSeparator(width: Int, result: MethodChannel.Result) {
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    val commands = mutableListOf<Byte>()
//
//                    // ✅ CRITICAL: Lower print density for heavy lines
//                    commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03.toByte()))
//
//                    // Center align
//                    commands.addAll(listOf(ESC, 0x61, 0x01))
//
//                    // Smaller font size (uses less power)
//                    commands.addAll(listOf(ESC, 0x21, 0x00))
//
//                    // Print the equals signs
//                    val separator = "=".repeat(width)
//                    commands.addAll(separator.toByteArray(charset("CP437")).toList())
//                    commands.add(0x0A.toByte())
//
//                    // ✅ Reset density back to normal
//                    commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06.toByte()))
//
//                    // Left align
//                    commands.addAll(listOf(ESC, 0x61, 0x00))
//
//                    addToBuffer(commands.toByteArray())
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    withContext(Dispatchers.Main) {
//                        result.error("SEPARATOR_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//
//
//
//    // ====================================================================
//// FIX 6: Optimized Network writing
//// ====================================================================
//    private fun writeNetworkOptimized(data: ByteArray) {
//        try {
//            val outputStream = networkSocket?.getOutputStream()
//
//            if (data.size < 1000) {
//                outputStream?.write(data)
//                outputStream?.flush()
//                return
//            }
//
//            val chunkSize = 512
//            var offset = 0
//
//            while (offset < data.size) {
//                val end = (offset + chunkSize).coerceAtMost(data.size)
//                val chunk = data.copyOfRange(offset, end)
//
//                outputStream?.write(chunk)
//                outputStream?.flush()
//
//                if (end < data.size) {
//                    Thread.sleep(10L)
//                }
//
//                offset = end
//            }
//        } catch (e: Exception) {
//            println("❌ Network error: ${e.message}")
//            throw e
//        }
//    }
//
//    // ====================================================================
//// FIX 8: Updated printText - NO cooldown for small text
//// ====================================================================
//    private fun printText(
//        text: String,
//        fontSize: Int,
//        bold: Boolean,
//        align: String,
//        maxCharsPerLine: Int,
//        result: MethodChannel.Result
//    ) {
//        val startTime = System.currentTimeMillis()
//
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    if (containsComplexUnicode(text)) {
//                        println("🖼️ Rendering Complex text: \"${text.take(30)}...\"")
//                        val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)
//
//                        if (imageData == null || imageData.isEmpty()) {
//                            throw Exception("Failed to render text")
//                        }
//
//                        val alignLeftCommand = byteArrayOf(ESC, 0x61.toByte(), 0x00.toByte())
//                        val finalData = alignLeftCommand + imageData
//
//                        addToBuffer(finalData)  // ✅ Add to buffer
//                    } else {
//                        printSimpleTextInternalBatched(text, fontSize, bold, align, maxCharsPerLine)
//                    }
//
//                    val elapsed = System.currentTimeMillis() - startTime
//                    println("✅ Text added to buffer in ${elapsed}ms")
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    println("❌ Print error: ${e.message}")
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//
//    private fun printSimpleTextInternalBatched(
//        text: String,
//        fontSize: Int,
//        bold: Boolean,
//        align: String,
//        maxCharsPerLine: Int
//    ) {
//        println("🔵 Adding text to buffer: \"${text.take(30)}...\"")
//
//        val commands = mutableListOf<Byte>()
//
//        // ✅ CRITICAL: Detect if this is a separator line (mostly "=" characters)
//        val isSeparatorLine = text.count { it == '=' } > (text.length * 0.8)
//
//        if (isSeparatorLine) {
//            println("📏 Detected separator line - using lower density")
//            // Lower density for separator lines
//            commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03.toByte()))
//        }
//
//        // Bold
//        commands.addAll(listOf(ESC, 0x45, if (bold) 0x01 else 0x00))
//
//        // Alignment
//        val alignValue = when (align.lowercase()) {
//            "center" -> 0x01.toByte()
//            "right" -> 0x02.toByte()
//            else -> 0x00.toByte()
//        }
//        commands.addAll(listOf(ESC, 0x61, alignValue))
//
//        // Size - Use smaller size for separator lines
//        val sizeCommand: Byte = if (isSeparatorLine) {
//            0x00.toByte()  // Normal size for separators (uses less power)
//        } else {
//            when {
//                fontSize > 30 -> 0x30.toByte()
//                fontSize > 24 -> 0x11.toByte()
//                else -> 0x00.toByte()
//            }
//        }
//        commands.addAll(listOf(ESC, 0x21, sizeCommand))
//
//        // Text
//        val wrappedText = if (maxCharsPerLine > 0) wrapText(text, maxCharsPerLine) else text
//        commands.addAll(wrappedText.toByteArray(charset("CP437")).toList())
//        commands.add(0x0A.toByte())
//
//        // Reset
//        commands.addAll(listOf(ESC, 0x45, 0x00))
//        commands.addAll(listOf(ESC, 0x61, 0x00))
//
//        if (isSeparatorLine) {
//            // ✅ Reset density back to normal
//            commands.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06.toByte()))
//        }
//
//        addToBuffer(commands.toByteArray())
//    }
//
//    // ====================================================================
//// FIX 9: Batch printing for rows (print all at once)
//// ====================================================================
//    private fun printRow(
//        columns: List<Map<String, Any>>,
//        fontSize: Int,
//        result: MethodChannel.Result
//    ) {
//        val startTime = System.currentTimeMillis()
//
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    val posColumns = columns.map { col ->
//                        PosColumn(
//                            text = col["text"] as? String ?: "",
//                            width = col["width"] as? Int ?: 6,
//                            align = col["align"] as? String ?: "left",
//                            bold = col["bold"] as? Boolean ?: false
//                        )
//                    }
//
//                    val totalWidth = posColumns.sumOf { it.width }
//                    if (totalWidth > 12) {
//                        withContext(Dispatchers.Main) {
//                            result.error("ROW_ERROR", "Total width exceeds 12: $totalWidth", null)
//                        }
//                        return@withLock
//                    }
//
//                    val hasComplexUnicode = posColumns.any { containsComplexUnicode(it.text) }
//
//                    if (hasComplexUnicode) {
//                        val imageData = renderRowToData(posColumns, fontSize)
//                        if (imageData == null || imageData.isEmpty()) {
//                            withContext(Dispatchers.Main) {
//                                result.error("RENDER_ERROR", "Failed to render row", null)
//                            }
//                            return@withLock
//                        }
//                        addToBuffer(imageData)  // ✅ Add to buffer
//                    } else {
//                        printRowUsingTextMethodBatched(posColumns, fontSize)
//                    }
//
//                    val elapsed = System.currentTimeMillis() - startTime
//                    println("✅ Row added to buffer in ${elapsed}ms")
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    println("❌ Row error: ${e.message}")
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_ROW_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//    private fun printRowUsingTextMethodBatched(columns: List<PosColumn>, fontSize: Int) {
//        val totalChars = when {
//            fontSize > 30 -> 24
//            fontSize > 24 -> 32
//            else -> 48
//        }
//
//        val columnTextLists = columns.map { column ->
//            val maxCharsPerColumn = (totalChars * column.width) / 12
//            val lines = wrapTextToList(column.text, maxCharsPerColumn)
//            Triple(lines, maxCharsPerColumn, column.align)
//        }
//
//        val maxLines = columnTextLists.maxOfOrNull { it.first.size } ?: 1
//        val commands = mutableListOf<Byte>()
//
//        // Size
//        val sizeCommand: Byte = when {
//            fontSize > 30 -> 0x30.toByte()
//            fontSize > 24 -> 0x11.toByte()
//            else -> 0x00.toByte()
//        }
//        commands.addAll(listOf(ESC, 0x21, sizeCommand))
//
//        // Bold if needed
//        val hasBold = columns.any { it.bold }
//        if (hasBold) {
//            commands.addAll(listOf(ESC, 0x45, 0x01))
//        }
//
//        // Left align
//        commands.addAll(listOf(ESC, 0x61, 0x00))
//
//        // Build all rows
//        for (lineIndex in 0 until maxLines) {
//            val lineText = StringBuilder()
//
//            for (colIndex in columnTextLists.indices) {
//                val (lines, width, align) = columnTextLists[colIndex]
//                val text = if (lineIndex < lines.size) lines[lineIndex] else ""
//                val formattedText = formatColumnText(text, width, align)
//                lineText.append(formattedText)
//            }
//
//            commands.addAll(lineText.toString().toByteArray(charset("CP437")).toList())
//            commands.add(0x0A.toByte())
//        }
//
//        // Reset
//        if (hasBold) {
//            commands.addAll(listOf(ESC, 0x45, 0x00))
//        }
//        commands.addAll(listOf(ESC, 0x61, 0x00))
//
//        addToBuffer(commands.toByteArray())  // ✅ Add to buffer
//    }
//
//
//    // ====================================================================
//// OPTIONAL: Queue system for even smoother printing
//// ====================================================================
//
//    private fun createGattCallback(resultKey: String): BluetoothGattCallback {
//        return object : BluetoothGattCallback() {
//            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
//                when (newState) {
//                    BluetoothProfile.STATE_CONNECTED -> {
//                        println("✅ BLE Connected! Status: $status")
//                        if (status == BluetoothGatt.GATT_SUCCESS) {
//                            try {
//                                Thread.sleep(600)
//                                gatt.discoverServices()
//                            } catch (e: Exception) {
//                                handleConnectionError(resultKey, "DISCOVER_FAILED", e.message)
//                                gatt.disconnect()
//                                gatt.close()
//                            }
//                        } else {
//                            handleConnectionError(resultKey, "CONNECTION_ERROR", "Status: $status")
//                            gatt.disconnect()
//                            gatt.close()
//                        }
//                    }
//
//                    BluetoothProfile.STATE_DISCONNECTED -> {
//                        val errorMsg = getDisconnectReason(status)
//                        println("❌ Disconnected: $errorMsg")
//                        handleConnectionError(resultKey, "DISCONNECTED", errorMsg)
//                        gatt.close()
//                    }
//                }
//            }
//
//            override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
//                if (status != BluetoothGatt.GATT_SUCCESS) {
//                    handleConnectionError(resultKey, "DISCOVER_FAILED", "Status: $status")
//                    gatt.disconnect()
//                    gatt.close()
//                    return
//                }
//
//                val characteristic = findWritableCharacteristic(gatt)
//
//                if (characteristic != null) {
//                    writeCharacteristic = characteristic
//                    currentConnectionType = ConnectionType.BLUETOOTH_BLE
//                    println("✅ BLE Connection Success! Char: ${characteristic.uuid}")
//
//                    // ============================================================
//                    // ✅ ADD THIS SECTION HERE - AFTER BLE CONNECTION SUCCESS
//                    // ============================================================
//                    try {
//                        initializePrinterForSmoothPrinting()
//                        println("✅ Printer initialized for smooth printing")
//                    } catch (e: Exception) {
//                        println("⚠️ Could not initialize printer settings: ${e.message}")
//                    }
//                    // ============================================================
//
//                    mainHandler.post {
//                        pendingResults.remove(resultKey)?.success(true)
//                    }
//                } else {
//                    handleConnectionError(resultKey, "NO_CHARACTERISTIC", "No writable characteristic found")
//                    gatt.disconnect()
//                    gatt.close()
//                }
//            }
//
//
//            override fun onCharacteristicWrite(
//                gatt: BluetoothGatt?,
//                characteristic: BluetoothGattCharacteristic?,
//                status: Int
//            ) {
//                synchronized(writeSync) {
//                    writeCompleted = (status == BluetoothGatt.GATT_SUCCESS)
//                    writeLatch?.countDown()
//                    currentWriteDeferred?.complete(writeCompleted)
//                    currentWriteDeferred = null
//                }
//            }
//        }
//    }
//
//    private fun findWritableCharacteristic(gatt: BluetoothGatt): BluetoothGattCharacteristic? {
//        // Known printer service UUIDs
//        val printerServiceUUIDs = listOf(
//            "000018f0-0000-1000-8000-00805f9b34fb",
//            "49535343-fe7d-4ae5-8fa9-9fafd205e455",
//            "0000ffe0-0000-1000-8000-00805f9b34fb",
//            "0000fff0-0000-1000-8000-00805f9b34fb"
//        )
//
//        for (serviceUuidStr in printerServiceUUIDs) {
//            try {
//                val service = gatt.getService(UUID.fromString(serviceUuidStr))
//                service?.characteristics?.forEach { char ->
//                    if (isWritable(char)) {
//                        println("✅ Found writable char in known service: ${char.uuid}")
//                        return char
//                    }
//                }
//            } catch (e: Exception) {
//                println("⚠️ Error checking service $serviceUuidStr: ${e.message}")
//            }
//        }
//
//        // Search all services
//        gatt.services.forEach { service ->
//            service.characteristics.forEach { char ->
//                if (isWritable(char)) {
//                    println("✅ Found writable char: ${char.uuid}")
//                    return char
//                }
//            }
//        }
//
//        return null
//    }
//
//    private fun isWritable(char: BluetoothGattCharacteristic): Boolean {
//        val props = char.properties
//        return (props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
//                (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
//    }
//
//    private fun handleConnectionError(resultKey: String, code: String, message: String?) {
//        mainHandler.post {
//            pendingResults.remove(resultKey)?.error(code, message, null)
//        }
//    }
//
//    private fun getDisconnectReason(status: Int): String {
//        return when (status) {
//            0 -> "Disconnected normally"
//            8 -> "Connection timeout - device not responding"
//            19 -> "Connection terminated by peer device"
//            22 -> "Connection failed - device busy or unavailable"
//            133 -> "GATT error 133 - Device out of range or not ready"
//            else -> "Disconnected with status: $status"
//        }
//    }
//
//    private fun cleanupBeforeConnect() {
//        try {
//            bluetoothGatt?.let { gatt ->
//                println("🧹 Cleaning up existing BLE connection...")
//                gatt.disconnect()
//                Thread.sleep(300)
//                gatt.close()
//                Thread.sleep(300)
//            }
//        } catch (e: Exception) {
//            println("⚠️ Cleanup error: ${e.message}")
//        }
//        bluetoothGatt = null
//        writeCharacteristic = null
//    }
//
//    private fun connectNetwork(ipAddress: String, port: Int, result: MethodChannel.Result) {
//        scope.launch(Dispatchers.IO) {
//            try {
//                networkSocket = Socket(ipAddress, port)
//                currentConnectionType = ConnectionType.NETWORK
//
//                // ============================================================
//                // ✅ ADD THIS SECTION HERE - AFTER NETWORK CONNECTION SUCCESS
//                // ============================================================
//                try {
//                    initializePrinterForSmoothPrinting()
//                    println("✅ Printer initialized for smooth printing")
//                } catch (e: Exception) {
//                    println("⚠️ Could not initialize printer settings: ${e.message}")
//                }
//                // ============================================================
//
//                withContext(Dispatchers.Main) {
//                    result.success(true)
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("CONNECTION_FAILED", e.message, null)
//                }
//            }
//        }
//    }
//
//
//    private fun disconnect(result: MethodChannel.Result) {
//        cleanupAllConnections()
//        result.success(true)
//    }
//
//
//    private fun optimizeLineFeeds(data: ByteArray): ByteArray {
//        // OOMAS printers stutter when there are too many consecutive line feeds
//        // Consolidate multiple 0x0A bytes into larger chunks
//
//        val optimized = mutableListOf<Byte>()
//        var consecutiveLineFeeds = 0
//
//        for (byte in data) {
//            if (byte == 0x0A.toByte()) {
//                consecutiveLineFeeds++
//            } else {
//                if (consecutiveLineFeeds > 0) {
//                    // Add all line feeds at once (more efficient)
//                    for (i in 0 until consecutiveLineFeeds) {
//                        optimized.add(0x0A.toByte())
//                    }
//                    consecutiveLineFeeds = 0
//                }
//                optimized.add(byte)
//            }
//        }
//
//        // Add any remaining line feeds
//        if (consecutiveLineFeeds > 0) {
//            for (i in 0 until consecutiveLineFeeds) {
//                optimized.add(0x0A.toByte())
//            }
//        }
//
//        return optimized.toByteArray()
//    }
//
//    // ====================================================================
//    // Font Management
//    // ====================================================================
//    private fun getKhmerTypeface(bold: Boolean): Typeface {
//        val fontKey = if (bold) "bold" else "regular"
//
//        return khmerTypefaceCache.getOrPut(fontKey) {
//            try {
//                val fontPath = when {
//                    bold -> {
//                        when {
//                            assetExists("fonts/NotoSansKhmer-Bold.ttf") -> "fonts/NotoSansKhmer-Bold.ttf"
//                            assetExists("fonts/NotoSansKhmer-SemiBold.ttf") -> "fonts/NotoSansKhmer-SemiBold.ttf"
//                            assetExists("fonts/NotoSansKhmer-Medium.ttf") -> "fonts/NotoSansKhmer-Medium.ttf"
//                            else -> "fonts/NotoSansKhmer-Regular.ttf"
//                        }
//                    }
//                    else -> "fonts/NotoSansKhmer-Regular.ttf"
//                }
//
//                println("✅ Loading font: $fontPath")
//                Typeface.createFromAsset(context.assets, fontPath)
//            } catch (e: Exception) {
//                println("⚠️ Failed to load Khmer font: ${e.message}")
//                Typeface.DEFAULT
//            }
//        }
//    }
//
//    private fun assetExists(path: String): Boolean {
//        return try {
//            context.assets.open(path).use { true }
//        } catch (e: Exception) {
//            false
//        }
//    }
//
//    private fun preloadFonts() {
//        scope.launch(Dispatchers.IO) {
//            println("🔄 Preloading fonts...")
//            getKhmerTypeface(false)
//            getKhmerTypeface(true)
//            println("✅ Fonts preloaded")
//        }
//    }
//
//
//
//    private fun configureForOOMAS() {
//        println("⚙️ Configuring for OOMAS printer...")
//
//        val config = mutableListOf<Byte>()
//
//        // Set looser line spacing (prevents motor strain)
//        config.addAll(listOf(ESC, 0x33, 0x40.toByte()))  // 64/180 inch spacing
//
//        // Set lower print density (less heat = smoother)
//        config.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x05.toByte()))
//
//        // Set print speed (if supported)
//        config.addAll(listOf(GS, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x00.toByte()))
//
//        writeDataSmooth(config.toByteArray())
//
//        println("✅ OOMAS configuration applied")
//    }
//
//    private fun renderTextToData(
//        text: String,
//        fontSize: Int,
//        bold: Boolean,
//        align: String,
//        maxCharsPerLine: Int
//    ): ByteArray? {
//        var bitmap: Bitmap? = null
//
//        try {
//            val khmerTypeface = getKhmerTypeface(bold)
//
//            val baseFontSize = 20f
//            val scaledFontSize = when {
//                fontSize > 30 -> baseFontSize * 2.0f
//                fontSize > 20 -> baseFontSize * 1.5f
//                else -> baseFontSize
//            }
//
//            val paint = Paint().apply {
//                textSize = scaledFontSize
//                typeface = khmerTypeface
//                isFakeBoldText = false
//                strokeWidth = 0f
//                style = Paint.Style.FILL
//                isAntiAlias = true
//                color = Color.BLACK
//                textAlign = when (align.lowercase()) {
//                    "center" -> Paint.Align.CENTER
//                    "right" -> Paint.Align.RIGHT
//                    else -> Paint.Align.LEFT
//                }
//            }
//
//            val maxWidth = printerWidth.toFloat()
//            val padding = 2f
//            val leftMarginOffset = if (paint.textAlign == Paint.Align.LEFT) padding else 0f
//
//            val textToRender = if (maxCharsPerLine > 0) {
//                wrapText(text, maxCharsPerLine)
//            } else {
//                text
//            }
//
//            val lines = textToRender.split("\n")
//            val lineHeight = paint.fontMetrics.let { (it.descent - it.ascent) * 0.90f }
//            val totalHeight = (lines.size * lineHeight + padding * 2).toInt()
//
//            bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
//            val canvas = Canvas(bitmap)
//            canvas.drawColor(Color.WHITE)
//
//            var y = padding - paint.fontMetrics.ascent
//            for (line in lines) {
//                if (line.isNotBlank()) {
//                    val x = when (paint.textAlign) {
//                        Paint.Align.CENTER -> maxWidth / 2
//                        Paint.Align.RIGHT -> maxWidth - padding
//                        else -> leftMarginOffset
//                    }
//                    canvas.drawText(line, x, y, paint)
//                }
//                y += lineHeight
//            }
//
//            val monoData = convertToMonochromeFast(bitmap)
//
//            if (monoData == null) {
//                println("❌ Failed to convert to monochrome")
//                return null
//            }
//
//            val widthBytes = (monoData.width + 7) / 8
//            val commandSize = 8 + monoData.data.size
//            val commands = ByteArray(commandSize)
//
//            var idx = 0
//            commands[idx++] = GS
//            commands[idx++] = 0x76
//            commands[idx++] = 0x30
//            commands[idx++] = 0x00
//            commands[idx++] = (widthBytes and 0xFF).toByte()
//            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()
//            commands[idx++] = (monoData.height and 0xFF).toByte()
//            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()
//
//            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)
//
//            return commands
//
//        } catch (e: Exception) {
//            println("❌ Render error: ${e.message}")
//            return null
//        } finally {
//            bitmap?.recycle()
//        }
//    }
//
//    fun initializePrinterForSmoothPrinting() {
//        println("🔧 Initializing printer for smooth printing...")
//
//        val commands = mutableListOf<Byte>()
//
//        // 1. Reset printer
//        commands.addAll(listOf(ESC, 0x40))
//        Thread.sleep(100)
//
//        // 2. Set looser line spacing (prevents motor strain)
//        commands.addAll(listOf(ESC, 0x33, 0x50.toByte())) // 80/180 inch (looser)
//
//        // 3. Set lower print density (less heat = smoother)
//        commands.addAll(listOf(
//            GS, 0x28, 0x4B,
//            0x02, 0x00,
//            0x30,
//            0x06.toByte() // Density 6 (lower than default 8)
//        ))
//
//        // 4. Set print speed to slower (if supported)
//        // Note: Not all printers support this
//
//        writeDataSmooth(commands.toByteArray())
//        Thread.sleep(200)
//
//        println("✅ Printer initialized for smooth operation")
//    }
//
//    private fun renderRowToData(columns: List<PosColumn>, fontSize: Int): ByteArray? {
//        var bitmap: Bitmap? = null
//        try {
//            val baseFontSize = 24f
//            val scaledFontSize = when {
//                fontSize > 30 -> baseFontSize * 2.0f
//                fontSize > 24 -> baseFontSize * 1.5f
//                else -> baseFontSize
//            }
//
//            val maxWidth = printerWidth.toFloat()
//            val columnWidths = columns.map { (maxWidth * it.width) / 12 }
//
//            val totalChars = when {
//                fontSize > 30 -> 20
//                fontSize > 24 -> 28
//                else -> 48
//            }
//
//            var maxLines = 1
//            for (column in columns) {
//                val colChars = (totalChars * column.width) / 12
//                val lineCount = (column.text.length + colChars - 1) / colChars
//                if (lineCount > maxLines) maxLines = lineCount
//            }
//
//            val basePaint = Paint().apply {
//                textSize = scaledFontSize
//                isAntiAlias = false
//                color = Color.BLACK
//                style = Paint.Style.FILL
//                strokeWidth = 0f
//            }
//
//            val lineHeight = basePaint.fontMetrics.let { (it.descent - it.ascent) * 0.90f }
//            val verticalPadding = 4f
//            val totalHeight = (lineHeight * maxLines + verticalPadding * 2).toInt()
//
//            bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
//            val canvas = Canvas(bitmap)
//            canvas.drawColor(Color.WHITE)
//
//            var currentX = 0f
//            for (i in columns.indices) {
//                val column = columns[i]
//                val colWidth = columnWidths[i]
//                val colChars = (totalChars * column.width) / 12
//
//                val lines = wrapTextToList(column.text, colChars)
//                val columnTypeface = getKhmerTypeface(column.bold)
//
//                basePaint.apply {
//                    typeface = columnTypeface
//                    isFakeBoldText = false
//                    textAlign = when (column.align.lowercase()) {
//                        "center" -> Paint.Align.CENTER
//                        "right" -> Paint.Align.RIGHT
//                        else -> Paint.Align.LEFT
//                    }
//                }
//
//                for (lineIndex in lines.indices) {
//                    val line = lines[lineIndex]
//                    if (line.isBlank()) continue
//
//                    val x = when (column.align.lowercase()) {
//                        "center" -> currentX + colWidth / 2
//                        "right" -> currentX + colWidth
//                        else -> currentX
//                    }
//
//                    val y = verticalPadding - basePaint.fontMetrics.ascent + (lineHeight * lineIndex)
//                    canvas.drawText(line, x, y, basePaint)
//                }
//
//                currentX += colWidth
//            }
//
//            val monoData = convertToMonochromeFast(bitmap)
//
//            if (monoData == null) {
//                println("❌ Failed to convert row to monochrome")
//                return null
//            }
//
//            val widthBytes = (monoData.width + 7) / 8
//            val commandSize = 8 + monoData.data.size
//            val commands = ByteArray(commandSize)
//
//            var idx = 0
//            commands[idx++] = GS
//            commands[idx++] = 0x76
//            commands[idx++] = 0x30
//            commands[idx++] = 0x00
//            commands[idx++] = (widthBytes and 0xFF).toByte()
//            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()
//            commands[idx++] = (monoData.height and 0xFF).toByte()
//            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()
//
//            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)
//
//            return commands
//
//        } catch (e: Exception) {
//            println("❌ Row render error: ${e.message}")
//            return null
//        } finally {
//            bitmap?.recycle()
//        }
//    }
//
//    private fun formatColumnText(text: String, width: Int, align: String): String {
//        if (text.length == width) return text
//        if (text.length > width) return text.take(width)
//
//        return when (align.lowercase()) {
//            "center" -> {
//                val totalPadding = width - text.length
//                val leftPadding = totalPadding / 2
//                text.padStart(text.length + leftPadding).padEnd(width)
//            }
//            "right" -> text.padStart(width)
//            else -> text.padEnd(width)
//        }
//    }
//
//    // ====================================================================
//    // Print Image
//    // ====================================================================
//    private fun printImage(
//        imageBytes: ByteArray,
//        width: Int,
//        align: Int,
//        result: MethodChannel.Result
//    ) {
//        scope.launch {
//            printMutex.withLock {
//                var bitmap: Bitmap? = null
//                var scaledBitmap: Bitmap? = null
//
//                try {
//                    bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
//                    if (bitmap == null) {
//                        withContext(Dispatchers.Main) {
//                            result.error("INVALID_IMAGE", "Cannot decode image", null)
//                        }
//                        return@withLock
//                    }
//
//                    val alignment = ImageAlignment.fromInt(align)
//                    scaledBitmap = resizeImage(bitmap, width)
//                    val monochromeData = convertToMonochromeFast(scaledBitmap)
//
//                    if (monochromeData == null) {
//                        withContext(Dispatchers.Main) {
//                            result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
//                        }
//                        return@withLock
//                    }
//
//                    val commands = mutableListOf<Byte>()
//
//                    // Initialize
//                    commands.add(ESC)
//                    commands.add(0x40)
//
//                    // Alignment
//                    commands.add(ESC)
//                    commands.add(0x61)
//                    commands.add(alignment.value.toByte())
//
//                    // Set line spacing to minimum (optional - reduces space between lines)
//                    commands.add(ESC)
//                    commands.add(0x33)
//                    commands.add(0x00) // 0 dots line spacing
//
//                    // Image command
//                    commands.add(GS)
//                    commands.add(0x76)
//                    commands.add(0x30)
//                    commands.add(0x00)
//
//                    val widthBytes = (monochromeData.width + 7) / 8
//                    commands.add((widthBytes and 0xFF).toByte())
//                    commands.add(((widthBytes shr 8) and 0xFF).toByte())
//                    commands.add((monochromeData.height and 0xFF).toByte())
//                    commands.add(((monochromeData.height shr 8) and 0xFF).toByte())
//
//                    commands.addAll(monochromeData.data.toList())
//
//                    // Reset line spacing to default
//                    commands.add(ESC)
//                    commands.add(0x33)
//                    commands.add(0x1E) // Default spacing (30 dots)
//
//                    // Reset alignment
//                    commands.add(ESC)
//                    commands.add(0x61)
//                    commands.add(0x00)
//
//                    // Remove these lines - they add extra space!
//                    // commands.add(0x0A)  // <- REMOVE THIS
//                    // commands.add(0x0A)  // <- REMOVE THIS
//
//                    writeDataSmooth(commands.toByteArray())
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    println("❌ Image print error: ${e.message}")
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_ERROR", e.message, null)
//                    }
//                } finally {
//                    bitmap?.recycle()
//                    scaledBitmap?.recycle()
//                }
//            }
//        }
//    }
//
//    private fun printImageWithPadding(
//        imageBytes: ByteArray,
//        width: Int,
//        align: Int,
//        paperWidth: Int,
//        result: MethodChannel.Result
//    ) {
//        scope.launch {
//            printMutex.withLock {
//                var bitmap: Bitmap? = null
//                var scaledBitmap: Bitmap? = null
//
//                try {
//                    bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
//                    if (bitmap == null) {
//                        withContext(Dispatchers.Main) {
//                            result.error("INVALID_IMAGE", "Cannot decode image", null)
//                        }
//                        return@withLock
//                    }
//
//                    val alignment = ImageAlignment.fromInt(align)
//                    scaledBitmap = resizeImage(bitmap, width)
//                    val originalData = convertToMonochromeFast(scaledBitmap)
//
//                    if (originalData == null) {
//                        withContext(Dispatchers.Main) {
//                            result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
//                        }
//                        return@withLock
//                    }
//
//                    val monochromeData = if (alignment != ImageAlignment.LEFT) {
//                        addPaddingToMonochrome(originalData, alignment, paperWidth)
//                    } else {
//                        originalData
//                    }
//
//                    val commands = mutableListOf<Byte>()
//
//                    commands.add(ESC)
//                    commands.add(0x40)
//                    commands.add(GS)
//                    commands.add(0x76)
//                    commands.add(0x30)
//                    commands.add(0x00)
//
//                    val widthBytes = (monochromeData.width + 7) / 8
//                    commands.add((widthBytes and 0xFF).toByte())
//                    commands.add(((widthBytes shr 8) and 0xFF).toByte())
//                    commands.add((monochromeData.height and 0xFF).toByte())
//                    commands.add(((monochromeData.height shr 8) and 0xFF).toByte())
//
//                    commands.addAll(monochromeData.data.toList())
//                    commands.add(0x0A)
//                    commands.add(0x0A)
//
//                    writeDataSmooth(commands.toByteArray())
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    println("❌ Image padding print error: ${e.message}")
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_ERROR", e.message, null)
//                    }
//                } finally {
//                    bitmap?.recycle()
//                    scaledBitmap?.recycle()
//                }
//            }
//        }
//    }
//
//    // ====================================================================
//    // Helper Methods
//    // ====================================================================
//    private fun resizeImage(bitmap: Bitmap, maxWidth: Int): Bitmap {
//        if (bitmap.width <= maxWidth) return bitmap
//
//        val ratio = maxWidth.toFloat() / bitmap.width
//        val newHeight = (bitmap.height * ratio).toInt()
//
//        return Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
//    }
//
//    private fun addPaddingToMonochrome(
//        data: MonochromeData,
//        alignment: ImageAlignment,
//        paperWidth: Int
//    ): MonochromeData {
//        if (data.width >= paperWidth) return data
//
//        val paddingTotal = paperWidth - data.width
//        val leftPadding = when (alignment) {
//            ImageAlignment.LEFT -> 0
//            ImageAlignment.CENTER -> paddingTotal / 2
//            ImageAlignment.RIGHT -> paddingTotal
//        }
//
//        val currentWidthBytes = (data.width + 7) / 8
//        val newWidthBytes = (paperWidth + 7) / 8
//        val newData = ByteArray(newWidthBytes * data.height)
//
//        for (y in 0 until data.height) {
//            val newRowOffset = y * newWidthBytes
//            val oldRowOffset = y * currentWidthBytes
//            val leftPaddingBytes = leftPadding / 8
//
//            System.arraycopy(
//                data.data,
//                oldRowOffset,
//                newData,
//                newRowOffset + leftPaddingBytes,
//                currentWidthBytes
//            )
//        }
//
//        return MonochromeData(paperWidth, data.height, newData)
//    }
//
//
//    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
//        try {
//            val width = bitmap.width
//            val height = bitmap.height
//            val widthBytes = (width + 7) / 8
//            val data = ByteArray(widthBytes * height)
//
//            // Get all pixels
//            val pixels = IntArray(width * height)
//            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
//
//            // Convert to grayscale with proper luminance calculation
//            val grayscale = FloatArray(width * height)
//            for (i in pixels.indices) {
//                val pixel = pixels[i]
//                val r = Color.red(pixel)
//                val g = Color.green(pixel)
//                val b = Color.blue(pixel)
//                // Standard luminance formula
//                grayscale[i] = (0.299f * r + 0.587f * g + 0.114f * b)
//            }
//
//            // Floyd-Steinberg dithering for better quality
//            for (y in 0 until height) {
//                for (x in 0 until width) {
//                    val index = y * width + x
//                    val oldPixel = grayscale[index]
//
//                    // Threshold at 128 (middle gray)
//                    val newPixel = if (oldPixel > 128f) 255f else 0f
//                    grayscale[index] = newPixel
//
//                    // Calculate and distribute error
//                    val error = oldPixel - newPixel
//
//                    // Distribute error to neighboring pixels
//                    if (x + 1 < width) {
//                        grayscale[index + 1] += error * 7f / 16f
//                    }
//                    if (y + 1 < height) {
//                        if (x > 0) {
//                            grayscale[index + width - 1] += error * 3f / 16f
//                        }
//                        grayscale[index + width] += error * 5f / 16f
//                        if (x + 1 < width) {
//                            grayscale[index + width + 1] += error * 1f / 16f
//                        }
//                    }
//                }
//            }
//
//            // Convert to byte array (pack 8 pixels per byte)
//            for (y in 0 until height) {
//                for (x in 0 until width) {
//                    val index = y * width + x
//
//                    // If pixel is black (0), set the bit to 1
//                    if (grayscale[index] < 128f) {
//                        val byteIndex = y * widthBytes + (x / 8)
//                        val bitIndex = 7 - (x % 8)
//                        data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
//                    }
//                }
//            }
//
//            println("✅ Converted to monochrome: ${width}x${height}, ${data.size} bytes")
//            return MonochromeData(width, height, data)
//
//        } catch (e: Exception) {
//            println("❌ Monochrome conversion error: ${e.message}")
//            e.printStackTrace()
//            return null
//        }
//    }
////    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
////        try {
////            val width = bitmap.width
////            val height = bitmap.height
////            val pixels = IntArray(width * height)
////            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
////
////            val widthBytes = (width + 7) / 8
////            val totalBytes = widthBytes * height
////            val data = ByteArray(totalBytes)
////
////            val threshold = -0x5f5f60 // Approximately 160 in grayscale
////
////            for (y in 0 until height) {
////                val bitmapRowOffset = y * widthBytes
////                for (x in 0 until width) {
////                    if (pixels[y * width + x] < threshold) {
////                        val byteIndex = bitmapRowOffset + (x / 8)
////                        val bitIndex = 7 - (x % 8)
////                        data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
////                    }
////                }
////            }
////
////            return MonochromeData(width, height, data)
////        } catch (e: Exception) {
////            println("❌ Monochrome conversion error: ${e.message}")
////            return null
////        }
////    }
//
//    private fun containsComplexUnicode(text: String): Boolean {
//        for (char in text) {
//            val code = char.code
//            if (code in 0x1780..0x17FF ||  // Khmer
//                code in 0x0E00..0x0E7F ||  // Thai
//                code in 0x4E00..0x9FFF ||  // CJK
//                code in 0xAC00..0xD7AF     // Hangul
//            ) {
//                return true
//            }
//        }
//        return false
//    }
//
//    private fun wrapText(text: String, maxCharsPerLine: Int): String {
//        return wrapTextToList(text, maxCharsPerLine).joinToString("\n")
//    }
//
//    private fun wrapTextToList(text: String, maxCharsPerLine: Int): List<String> {
//        if (maxCharsPerLine <= 0) return listOf(text)
//
//        val lines = mutableListOf<String>()
//        val words = text.split(" ")
//        var currentLine = StringBuilder()
//
//        for (word in words) {
//            // Handle words longer than max line
//            if (word.length > maxCharsPerLine) {
//                // Add current line if not empty
//                if (currentLine.isNotEmpty()) {
//                    lines.add(currentLine.toString().trim())
//                    currentLine = StringBuilder()
//                }
//
//                // Split long word
//                var remaining = word
//                while (remaining.length > maxCharsPerLine) {
//                    lines.add(remaining.take(maxCharsPerLine))
//                    remaining = remaining.drop(maxCharsPerLine)
//                }
//                if (remaining.isNotEmpty()) {
//                    currentLine.append(remaining).append(" ")
//                }
//                continue
//            }
//
//            // Check if adding word would exceed limit
//            val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"
//
//            if (getVisualWidth(testLine) <= maxCharsPerLine) {
//                if (currentLine.isNotEmpty()) currentLine.append(" ")
//                currentLine.append(word)
//            } else {
//                if (currentLine.isNotEmpty()) {
//                    lines.add(currentLine.toString().trim())
//                }
//                currentLine = StringBuilder(word).append(" ")
//            }
//        }
//
//        if (currentLine.isNotEmpty()) {
//            lines.add(currentLine.toString().trim())
//        }
//
//        return lines.ifEmpty { listOf("") }
//    }
//
//    private fun getVisualWidth(text: String): Double {
//        var width = 0.0
//        for (char in text) {
//            val code = char.code
//            width += when {
//                code in 0x1780..0x17FF -> 1.4  // Khmer base
//                code in 0x17B4..0x17D3 -> 0.0  // Khmer combining marks
//                code in 0x0E00..0x0E7F -> 1.2  // Thai
//                code in 0x4E00..0x9FFF -> 2.0  // CJK (double width)
//                code in 0xAC00..0xD7AF -> 2.0  // Hangul (double width)
//                else -> 1.0  // ASCII/Latin
//            }
//        }
//        return width
//    }
//
//    // ====================================================================
//    // Paper Control
//    // ====================================================================
//    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    val commands = ByteArray(lines) { 0x0A.toByte() }
//                    addToBuffer(commands)  // ✅ Add to buffer
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    withContext(Dispatchers.Main) {
//                        result.error("FEED_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//
//
//    private fun cutPaper(result: MethodChannel.Result) {
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    val commands = byteArrayOf(GS, 0x56, 0x00)
//                    addToBuffer(commands)  // ✅ Add to buffer
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    withContext(Dispatchers.Main) {
//                        result.error("CUT_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//
//
//    private fun setPrinterWidth(width: Int, result: MethodChannel.Result) {
//        printerWidth = width
//        println("✅ Printer width set to $width dots")
//        result.success(true)
//    }
//
//    // ====================================================================
//    // Status & Permissions
//    // ====================================================================
//    private fun getStatus(result: MethodChannel.Result) {
//        val hasPermission = checkBluetoothPermissions()
//        val isEnabled = bluetoothAdapter?.isEnabled ?: false
//        val isConnected = when (currentConnectionType) {
//            ConnectionType.BLUETOOTH_CLASSIC -> bluetoothSocket?.isConnected ?: false
//            ConnectionType.BLUETOOTH_BLE -> bluetoothGatt != null && writeCharacteristic != null
//            ConnectionType.NETWORK -> networkSocket?.isConnected ?: false
//            else -> false
//        }
//
//        val status = mapOf(
//            "status" to if (hasPermission) "authorized" else "denied",
//            "enabled" to isEnabled,
//            "connected" to isConnected,
//            "connectionType" to currentConnectionType.name.lowercase()
//        )
//
//        result.success(status)
//    }
//
//    private fun checkBluetoothPermission(result: MethodChannel.Result) {
//        result.success(checkBluetoothPermissions())
//    }
//
//    private fun checkBluetoothPermissions(): Boolean {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            return ActivityCompat.checkSelfPermission(
//                context,
//                Manifest.permission.BLUETOOTH_CONNECT
//            ) == PackageManager.PERMISSION_GRANTED &&
//                    ActivityCompat.checkSelfPermission(
//                        context,
//                        Manifest.permission.BLUETOOTH_SCAN
//                    ) == PackageManager.PERMISSION_GRANTED
//        }
//
//        @Suppress("DEPRECATION")
//        return ActivityCompat.checkSelfPermission(
//            context,
//            Manifest.permission.BLUETOOTH
//        ) == PackageManager.PERMISSION_GRANTED &&
//                ActivityCompat.checkSelfPermission(
//                    context,
//                    Manifest.permission.BLUETOOTH_ADMIN
//                ) == PackageManager.PERMISSION_GRANTED
//    }
//}