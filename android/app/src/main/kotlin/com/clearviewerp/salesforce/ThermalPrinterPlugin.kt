package com.clearviewerp.salesforce

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
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
import java.net.Socket
import java.util.*
import kotlinx.coroutines.sync.Mutex // <-- ADDED
import kotlinx.coroutines.sync.withLock // <-- ADDED

// ====================================================================
// Define ESC/POS Data Class
// ====================================================================

// Data class to hold the output of monochrome conversion
data class MonochromeData(val width: Int, val height: Int, val data: ByteArray)

class ThermalPrinterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())

    // Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var discoveredDevices = mutableListOf<BluetoothDevice>()

    // USB
    private var usbManager: UsbManager? = null

    // Network
    private var networkSocket: Socket? = null

    // Connection state
    private var currentConnectionType = "bluetooth"
    private var printerWidth = 576 // 80mm default (576px)

    // ESC/POS Commands
    private val ESC: Byte = 0x1B
    private val GS: Byte = 0x1D

    // Coroutine scope for async operations
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private val printMute = Mutex()
    // Pending result for async operations
    private var connectionResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "thermal_printer")
        channel.setMethodCallHandler(this)

        val bluetoothManager =
            context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
        usbManager = context.getSystemService(Context.USB_SERVICE) as? UsbManager

        println("🔵 ThermalPrinterPlugin initialized")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
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

            "printImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val width = call.argument<Int>("width") ?: printerWidth
                if (imageBytes != null) {
                    printImage(imageBytes, width, result)
                } else {
                    result.error("INVALID_ARGS", "Missing imageBytes", null)
                }
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

    // MARK: - Discovery (Simplified/Existing)
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
                allPrinters.add(
                    mapOf(
                        "name" to (device.name ?: "Unknown Device"),
                        "address" to device.address,
                        "type" to "ble"
                    )
                )
            } catch (e: SecurityException) {
                // Skip if we can't access device info
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

            val printers = discoveredDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unknown Device"),
                    "address" to device.address,
                    "type" to "ble"
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

    // MARK: - Connection Helpers (Existing)
    private fun cleanupBeforeConnect() {
        try {
            bluetoothGatt?.let { gatt ->
                println("🧹 Cleaning up existing connection...")
                try {
                    gatt.disconnect()
                    Thread.sleep(300)
                    gatt.close()
                    Thread.sleep(300)
                } catch (e: SecurityException) {
                    println("⚠️ Security exception during cleanup: ${e.message}")
                }
            }
        } catch (e: Exception) {
            println("⚠️ Cleanup error: ${e.message}")
        }
        bluetoothGatt = null
        writeCharacteristic = null
    }

    private fun isDeviceAlreadyConnected(address: String): Boolean {
        try {
            val bluetoothManager =
                context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            val connectedDevices = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT)
            return connectedDevices.any { it.address == address }
        } catch (e: SecurityException) {
            println("⚠️ Can't check connected devices: ${e.message}")
            return false
        } catch (e: Exception) {
            println("⚠️ Error checking connected devices: ${e.message}")
            return false
        }
    }

    private fun checkDeviceBondState(device: BluetoothDevice): String {
        return try {
            when (device.bondState) {
                BluetoothDevice.BOND_BONDED -> {
                    println("✅ Device is paired")
                    "bonded"
                }

                BluetoothDevice.BOND_BONDING -> {
                    println("⏳ Device is pairing...")
                    "bonding"
                }

                BluetoothDevice.BOND_NONE -> {
                    println("⚠️ Device is NOT paired!")
                    "not_bonded"
                }

                else -> "unknown"
            }
        } catch (e: SecurityException) {
            println("⚠️ Can't check bond state: ${e.message}")
            "unknown"
        }
    }

    // MARK: - Connection (Existing)
    private fun connect(address: String, type: String, result: MethodChannel.Result) {
        currentConnectionType = type
        println("🔵 Connect request: address=$address, type=$type")

        when (type) {
            "bluetooth", "ble" -> {
                // Pre-connection checks
                try {
                    val device = bluetoothAdapter?.getRemoteDevice(address)
                    if (device == null) {
                        result.error("NOT_FOUND", "Device not found", null)
                        return
                    }

                    // Check bond state
                    val bondState = checkDeviceBondState(device)
                    if (bondState == "not_bonded") {
                        result.error(
                            "NOT_PAIRED",
                            "Device is not paired. Please pair in Bluetooth settings first.",
                            null
                        )
                        return
                    }

                    // Check if already connected elsewhere
                    if (isDeviceAlreadyConnected(address)) {
                        println("⚠️ Device appears to be connected already, will try to disconnect first")
                        cleanupBeforeConnect()
                        Thread.sleep(1000)
                    }

                } catch (e: SecurityException) {
                    result.error("PERMISSION_DENIED", e.message, null)
                    return
                }

                // Clean up before new connection
                cleanupBeforeConnect()

                // Now attempt connection
                connectBluetooth(address, result)
            }

            "usb" -> result.error("NOT_IMPLEMENTED", "USB not yet implemented", null)
            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
        }
    }

    private fun connectBluetooth(address: String, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
            return
        }

        if (bluetoothAdapter?.isEnabled != true) {
            result.error("BLUETOOTH_OFF", "Bluetooth is turned off", null)
            return
        }

        connectionResult = result

        try {
            val device = bluetoothAdapter?.getRemoteDevice(address)
            if (device == null) {
                result.error("NOT_FOUND", "Device not found", null)
                connectionResult = null
                return
            }

            println("🔵 Connecting to: ${device.name} ($address)")

            bluetoothGatt = device.connectGatt(
                context,
                false,
                object : BluetoothGattCallback() {
                    override fun onConnectionStateChange(
                        gatt: BluetoothGatt,
                        status: Int,
                        newState: Int
                    ) {
                        println("🔵 BLE State Change: status=$status, newState=$newState")

                        when (newState) {
                            BluetoothProfile.STATE_CONNECTED -> {
                                println("✅ BLE Connected! Status: $status")

                                if (status == BluetoothGatt.GATT_SUCCESS) {
                                    try {
                                        Thread.sleep(600)
                                        val discovered = gatt.discoverServices()
                                        println("🔍 Service discovery started: $discovered")

                                        if (!discovered) {
                                            mainHandler.post {
                                                connectionResult?.error(
                                                    "DISCOVER_FAILED",
                                                    "Failed to start service discovery",
                                                    null
                                                )
                                                connectionResult = null
                                                gatt.disconnect()
                                                gatt.close()
                                            }
                                        }
                                    } catch (e: SecurityException) {
                                        println("❌ Security exception: ${e.message}")
                                        mainHandler.post {
                                            connectionResult?.error(
                                                "PERMISSION_DENIED",
                                                e.message,
                                                null
                                            )
                                            connectionResult = null
                                            gatt.disconnect()
                                            gatt.close()
                                        }
                                    } catch (e: Exception) {
                                        println("❌ Error: ${e.message}")
                                        mainHandler.post {
                                            connectionResult?.error("ERROR", e.message, null)
                                            connectionResult = null
                                            gatt.disconnect()
                                            gatt.close()
                                        }
                                    }
                                } else {
                                    println("⚠️ Connected with error status: $status")
                                    mainHandler.post {
                                        connectionResult?.error(
                                            "CONNECTION_ERROR",
                                            "Connected but status=$status",
                                            null
                                        )
                                        connectionResult = null
                                        gatt.disconnect()
                                        gatt.close()
                                    }
                                }
                            }

                            BluetoothProfile.STATE_DISCONNECTED -> {
                                val errorMsg = when (status) {
                                    0 -> "Disconnected normally"
                                    8 -> "Connection timeout - device not responding"
                                    19 -> "Connection terminated by peer device"
                                    22 -> "Connection failed - device busy or unavailable"
                                    133 -> "GATT error 133 - Device out of range or not ready"
                                    else -> "Disconnected with status: $status"
                                }
                                println("❌ Disconnected: $errorMsg")

                                mainHandler.post {
                                    if (connectionResult != null) {
                                        connectionResult?.error("DISCONNECTED", errorMsg, null)
                                        connectionResult = null
                                    }
                                }
                                gatt.close()
                            }

                            BluetoothProfile.STATE_CONNECTING -> {
                                println("🔵 BLE Connecting... (status=$status)")
                            }

                            BluetoothProfile.STATE_DISCONNECTING -> {
                                println("🔵 BLE Disconnecting...")
                            }
                        }
                    }

                    override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
                        println("🔍 Services discovered callback: status=$status")

                        if (status != BluetoothGatt.GATT_SUCCESS) {
                            println("❌ Service discovery failed: status=$status")
                            mainHandler.post {
                                connectionResult?.error(
                                    "DISCOVER_FAILED",
                                    "Service discovery failed: $status",
                                    null
                                )
                                connectionResult = null
                                gatt.disconnect()
                                gatt.close()
                            }
                            return
                        }

                        println("📋 Found ${gatt.services.size} services")

                        // Log all services and characteristics
                        for (service in gatt.services) {
                            println("  📦 Service: ${service.uuid}")
                            for (char in service.characteristics) {
                                val props = char.properties
                                val propsStr = StringBuilder()
                                if (props and BluetoothGattCharacteristic.PROPERTY_WRITE != 0) propsStr.append(
                                    "WRITE "
                                )
                                if (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0) propsStr.append(
                                    "WRITE_NO_RESP "
                                )
                                if (props and BluetoothGattCharacteristic.PROPERTY_READ != 0) propsStr.append(
                                    "READ "
                                )
                                if (props and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) propsStr.append(
                                    "NOTIFY "
                                )
                                println("    📝 Char: ${char.uuid} [${propsStr.toString().trim()}]")
                            }
                        }

                        // Search for writable characteristic
                        var foundCharacteristic: BluetoothGattCharacteristic? = null

                        // Common thermal printer service UUIDs
                        val printerServiceUUIDs = listOf(
                            "000018f0-0000-1000-8000-00805f9b34fb",
                            "49535343-fe7d-4ae5-8fa9-9fafd205e455",
                            "0000ffe0-0000-1000-8000-00805f9b34fb",
                            "0000fff0-0000-1000-8000-00805f9b34fb"
                        )

                        for (serviceUuidStr in printerServiceUUIDs) {
                            try {
                                val service =
                                    gatt.getService(java.util.UUID.fromString(serviceUuidStr))
                                if (service != null) {
                                    println("✅ Found known service: $serviceUuidStr")
                                    for (char in service.characteristics) {
                                        val props = char.properties
                                        if ((props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
                                            (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
                                        ) {
                                            foundCharacteristic = char
                                            println("✅ Using characteristic: ${char.uuid}")
                                            break
                                        }
                                    }
                                    if (foundCharacteristic != null) break
                                }
                            } catch (e: Exception) {
                                println("⚠️ Error checking service $serviceUuidStr: ${e.message}")
                            }
                        }

                        // Search all services if not found
                        if (foundCharacteristic == null) {
                            println("🔍 No known service found, searching all characteristics...")
                            for (service in gatt.services) {
                                for (char in service.characteristics) {
                                    val props = char.properties
                                    if ((props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
                                        (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
                                    ) {
                                        foundCharacteristic = char
                                        println("✅ Found writable char: ${char.uuid} in service ${service.uuid}")
                                        break
                                    }
                                }
                                if (foundCharacteristic != null) break
                            }
                        }

                        if (foundCharacteristic != null) {
                            writeCharacteristic = foundCharacteristic
                            println("✅ CONNECTION SUCCESS! Using: ${foundCharacteristic.uuid}")

                            mainHandler.post {
                                connectionResult?.success(true)
                                connectionResult = null
                            }
                        } else {
                            println("❌ NO WRITABLE CHARACTERISTIC FOUND!")

                            mainHandler.post {
                                connectionResult?.error(
                                    "NO_CHARACTERISTIC",
                                    "No writable characteristic found. This device may not be a thermal printer.",
                                    null
                                )
                                connectionResult = null
                                gatt.disconnect()
                                gatt.close()
                            }
                        }
                    }

                    override fun onCharacteristicWrite(
                        gatt: BluetoothGatt,
                        characteristic: BluetoothGattCharacteristic,
                        status: Int
                    ) {
                        if (status != BluetoothGatt.GATT_SUCCESS) {
                            // This is the callback that tells us if the write was successful
                            println("⚠️ Write failed in callback: status=$status")
                        }
                    }
                },
                BluetoothDevice.TRANSPORT_LE
            )

            mainHandler.postDelayed({
                if (connectionResult != null) {
                    println("⏱️ BLE Connection timeout (15s)")
                    connectionResult?.error(
                        "TIMEOUT",
                        "Connection timeout. Please ensure:\n1. Printer is ON and nearby\n2. Not connected to another device\n3. Printer is in pairing mode",
                        null
                    )
                    connectionResult = null
                    try {
                        bluetoothGatt?.disconnect()
                        bluetoothGatt?.close()
                        bluetoothGatt = null
                    } catch (e: Exception) {
                        println("⚠️ Cleanup error: ${e.message}")
                    }
                }
            }, 15000)

        } catch (e: SecurityException) {
            println("❌ Security exception: ${e.message}")
            result.error("PERMISSION_DENIED", e.message, null)
            connectionResult = null
        } catch (e: Exception) {
            println("❌ Connection error: ${e.message}")
            result.error("CONNECTION_ERROR", e.message, null)
            connectionResult = null
        }
    }

    private fun connectNetwork(ipAddress: String, port: Int, result: MethodChannel.Result) {
        scope.launch {
            try {
                networkSocket = Socket(ipAddress, port)
                currentConnectionType = "network"
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
        try {
            when (currentConnectionType) {
                "bluetooth", "ble" -> {
                    bluetoothGatt?.disconnect()
                    bluetoothGatt?.close()
                    bluetoothGatt = null
                    writeCharacteristic = null
                }

                "network" -> {
                    networkSocket?.close()
                    networkSocket = null
                }
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }

    // MARK: - Core Printing Logic

    // 1. CORE FUNCTION: Ultra-Fast Data Transfer (Optimized BLE/Network)
    // FIXED: Proper BLE Write Implementation
    private fun writeDataUltraFast(data: ByteArray) {
        val startTime = System.currentTimeMillis()

        when (currentConnectionType) {
            "bluetooth", "ble" -> {
                val characteristic = writeCharacteristic
                val gatt = bluetoothGatt

                if (characteristic == null || gatt == null) {
                    println("❌ WRITE: No characteristic or GATT connection")
                    return
                }

                try {
                    // 🚀 CRITICAL FIX: Use proper BLE write approach
                    val chunkSize = 20 // Keep small for reliability
                    var offset = 0
                    var chunkCount = 0
                    var successCount = 0
                    var failCount = 0

                    println("📝 Starting BLE write (FIXED): ${data.size} bytes")

                    while (offset < data.size) {
                        val end = minOf(offset + chunkSize, data.size)
                        val chunk = data.copyOfRange(offset, end)

                        characteristic.value = chunk

                        // 🚀 CRITICAL: Check if characteristic supports WRITE_NO_RESPONSE
                        val writeType = if ((characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0) {
                            BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
                        } else if ((characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0) {
                            BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
                        } else {
                            println("❌ CHARACTERISTIC DOESN'T SUPPORT WRITE!")
                            break
                        }

                        characteristic.writeType = writeType

                        val writeSuccess = gatt.writeCharacteristic(characteristic)

                        if (writeSuccess) {
                            successCount++
                            // 🚀 Add small delay to prevent BLE buffer overflow
                            Thread.sleep(2) // 2ms delay between successful writes
                        } else {
                            failCount++
                            println("⚠️ Write failed at offset $offset - Adding delay and continuing...")
                            Thread.sleep(10) // Longer delay on failure
                        }

                        offset = end
                        chunkCount++
                    }

                    val writeTime = System.currentTimeMillis() - startTime
                    println("✅ BLE WRITE COMPLETE: $successCount/$chunkCount chunks successful, ${failCount} failed, took ${writeTime}ms")

                } catch (e: SecurityException) {
                    println("❌ WRITE: Permission denied - $e")
                } catch (e: Exception) {
                    println("❌ WRITE: Error - $e")
                }
            }
            "network" -> {
                try {
                    networkSocket?.getOutputStream()?.write(data)
                    networkSocket?.getOutputStream()?.flush()
                    val writeTime = System.currentTimeMillis() - startTime
                    println("📡 NET WRITE: ${data.size} bytes, took ${writeTime}ms")
                } catch (e: Exception) {
                    println("❌ NETWORK WRITE: Network error - $e")
                }
            }
        }
    }

    // In ThermalPrinterPlugin.kt
    private fun printText(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int,
        result: MethodChannel.Result
    ) {
        val startTime = System.currentTimeMillis()

        // 🔑 FIX: Launch an async job that uses a Mutex to serialize all printing.
        scope.launch {
            printMute.withLock {
                try {
                    if (containsComplexUnicode(text)) {
                        println("🔵 KOTLIN: Rendering Complex text (Image): \"${text.take(30)}...\"")
                        val renderStart = System.currentTimeMillis()

                        // renderTextToData is now called directly within the locked coroutine
                        val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)

                        if (imageData == null || imageData.isEmpty()) {
                            withContext(Dispatchers.Main) {
                                result.error("RENDER_ERROR", "Failed to render or returned empty image data", null)
                            }
                            return@withLock
                        }

                        val renderTime = System.currentTimeMillis() - renderStart
                        println("⏱️ KOTLIN: Rendered in ${renderTime}ms, size: ${imageData.size} bytes")

                        // Robust Framing for Complex Text
                        val resetToEnglishCommands = mutableListOf<Byte>()
                        resetToEnglishCommands.add(ESC)
                        resetToEnglishCommands.add(0x40.toByte())        // 1. Initialize Printer (ESC @)
                        resetToEnglishCommands.add(ESC)
                        resetToEnglishCommands.add(0x74.toByte())
                        resetToEnglishCommands.add(0x01.toByte())        // 2. Set Code Page PC437 (ESC t 0x01)

                        // Send: [RESET] + [IMAGE DATA] + [RESET]
                        val finalData = resetToEnglishCommands.toByteArray() + imageData + resetToEnglishCommands.toByteArray()

                        writeDataUltraFast(finalData)

                        val totalTime = System.currentTimeMillis() - startTime
                        println("📤 KOTLIN: Sent, total: ${totalTime}ms")

                    } else {
                        // Fast path for pure ASCII/Simple text
                        printSimpleTextInternal(text, fontSize, bold, align, maxCharsPerLine) // Internal call, no result

                        val totalTime = System.currentTimeMillis() - startTime
                        println("✅ KOTLIN: English printed in ${totalTime}ms")
                    }

                    // SUCCESS is only called ONCE, after the entire print job is done and the lock is about to be released
                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }

                } catch (e: Exception) {
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    // 3. Helper for Simple Text (Must not handle the result)
// Since the result is now handled in the locked block, we create a non-result-handling version
    private fun printSimpleTextInternal(text: String, fontSize: Int, bold: Boolean, align: String, maxCharsPerLine: Int) {
        println("🔵 KOTLIN: Sending ASCII/Simple text via ESC/POS: \"${text.take(30)}...\"")

        val commands = mutableListOf<Byte>()
        commands.addAll(listOf(ESC, 0x40))       // Initialize Printer
        commands.addAll(listOf(ESC, 0x74, 0x01)) // Set code page PC437 (English)

        // Set Bold
        if (bold) { commands.addAll(listOf(ESC, 0x45, 0x01)) } else { commands.addAll(listOf(ESC, 0x45, 0x00)) }

        // Set Alignment
        val alignValue = when (align.lowercase()) {
            "center" -> 0x01.toByte()
            "right" -> 0x02.toByte()
            else -> 0x00.toByte()
        }
        commands.addAll(listOf(ESC, 0x61, alignValue))

        // Set Font Size
        val sizeCommand: Byte = when {
            fontSize > 30 -> 0x30.toByte() // Double height/width
            fontSize > 24 -> 0x10.toByte() // Double height
            else -> 0x00.toByte() // Default
        }
        commands.addAll(listOf(ESC, 0x21, sizeCommand))

        val wrappedText = if (maxCharsPerLine > 0) wrapText(text, maxCharsPerLine) else text

        commands.addAll(wrappedText.toByteArray(charset("CP437")).toList())

        commands.add(0x0A.toByte()) // Line feed

        // Reset formatting (Best Practice)
        if (bold) { commands.addAll(listOf(ESC, 0x45, 0x00)) }
        commands.addAll(listOf(ESC, 0x61, 0x00)) // Reset alignment to left

        writeDataUltraFast(commands.toByteArray())
    }


//     2. CORE FUNCTION: Dynamic Print Text (Handles Complex/English Mix)
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
//        // If complex unicode (like Khmer, CJK, etc.) is detected, render as image
//        if (containsComplexUnicode(text)) {
//            println("🔵 KOTLIN: Rendering Complex text (Image): \"${text.take(30)}...\"")
//            scope.launch {
//                val renderStart = System.currentTimeMillis()
//
//                // renderTextToData returns the GS v 0 0... raster data
//                val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)
//
//                if (imageData == null || imageData.isEmpty()) {
//                    withContext(Dispatchers.Main) {
//                        result.error("RENDER_ERROR", "Failed to render or returned empty image data", null)
//                    }
//                    return@launch
//                }
//
//                val renderTime = System.currentTimeMillis() - renderStart
//                println("⏱️ KOTLIN: Rendered in ${renderTime}ms, size: ${imageData.size} bytes")
//
//                withContext(Dispatchers.Main) {
//                    // 🔑 FIX: Robust Framing for Complex Text (prevents state corruption)
//                    val resetToEnglishCommands = mutableListOf<Byte>()
//                    resetToEnglishCommands.add(ESC)
//                    resetToEnglishCommands.add(0x40.toByte())        // 1. Initialize Printer (ESC @)
//                    resetToEnglishCommands.add(ESC)
//                    resetToEnglishCommands.add(0x74.toByte())
//                    resetToEnglishCommands.add(0x01.toByte())        // 2. Set Code Page PC437 (ESC t 0x01)
//
//                    // Send: [RESET] + [IMAGE DATA] + [RESET]
//                    val finalData = resetToEnglishCommands.toByteArray() + imageData + resetToEnglishCommands.toByteArray()
//
//                    writeDataUltraFast(finalData)
//
//                    val totalTime = System.currentTimeMillis() - startTime
//                    println("📤 KOTLIN: Sent, total: ${totalTime}ms")
//                    result.success(true)
//                }
//            }
//        } else {
//
//            val totalTime = System.currentTimeMillis() - startTime
//            println("✅ KOTLIN: English printed in ${totalTime}ms")
//        }
//    }


    // 4. Print Raw Image Data (From Flutter)
    private fun printImage(imageBytes: ByteArray, width: Int, result: MethodChannel.Result) {
        scope.launch {
            try {
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

                // Rescale to printer width if necessary
                val scaledBitmap = if (bitmap.width != width) {
                    val ratio = width.toFloat() / bitmap.width.toFloat()
                    val newHeight = (bitmap.height * ratio).toInt()
                    Bitmap.createScaledBitmap(bitmap, width, newHeight, true)
                } else {
                    bitmap
                }

                val monoData = convertToMonochromeFast(scaledBitmap)
                scaledBitmap.recycle()

                if (monoData == null) {
                    withContext(Dispatchers.Main) {
                        result.error("IMAGE_PROCESS_ERROR", "Failed to convert image to monochrome data", null)
                    }
                    return@launch
                }

                // Generate GS v 0 0 raster command
                val commands = mutableListOf<Byte>()
                commands.addAll(listOf(GS, 0x76, 0x30, 0x00))

                val widthBytes = (monoData.width + 7) / 8
                commands.add((widthBytes and 0xFF).toByte())
                commands.add(((widthBytes shr 8) and 0xFF).toByte())
                commands.add((monoData.height and 0xFF).toByte())
                commands.add(((monoData.height shr 8) and 0xFF).toByte())
                commands.addAll(monoData.data.toList())
                commands.add(0x0A) // Line feed/Printer processing trigger

                withContext(Dispatchers.Main) {
                    writeDataUltraFast(commands.toByteArray())
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("PRINT_IMAGE_ERROR", e.message, null)
                }
            }
        }
    }

    // 5. Image Rendering (Khmer/Complex Text)
    private fun renderTextToData(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int
    ): ByteArray? {
        try {
            val paint = Paint().apply {
                textSize = fontSize.toFloat()
                typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                isAntiAlias = true
                color = Color.BLACK
                textAlign = when (align.lowercase()) {
                    "center" -> Paint.Align.CENTER
                    "right" -> Paint.Align.RIGHT
                    else -> Paint.Align.LEFT
                }
            }

            val maxWidth = printerWidth.toFloat()
            val padding = 8f

            val textToRender = if (maxCharsPerLine > 0) {
                wrapText(text, maxCharsPerLine)
            } else {
                text
            }

            val lines = textToRender.split("\n")
            val lineHeight = paint.fontMetrics.let { it.descent - it.ascent }
            val totalHeight = (lines.size * lineHeight + padding * 2).toInt()

            val bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)

            var y = padding - paint.fontMetrics.ascent
            for (line in lines) {
                val x = when (paint.textAlign) {
                    Paint.Align.CENTER -> maxWidth / 2
                    Paint.Align.RIGHT -> maxWidth - padding
                    else -> padding
                }
                canvas.drawText(line, x, y, paint)
                y += lineHeight
            }

            // Convert to 1-bit monochrome data
            val monoData = convertToMonochromeFast(bitmap)
            bitmap.recycle()

            if (monoData == null) return null

            val commands = mutableListOf<Byte>()

            // GS v 0 0 raster command
            commands.addAll(listOf(GS, 0x76, 0x30, 0x00))

            val widthBytes = (monoData.width + 7) / 8
            commands.add((widthBytes and 0xFF).toByte())
            commands.add(((widthBytes shr 8) and 0xFF).toByte())
            commands.add((monoData.height and 0xFF).toByte())
            commands.add(((monoData.height shr 8) and 0xFF).toByte())
            commands.addAll(monoData.data.toList())
            commands.add(0x0A) // Line feed/Printer processing trigger

            return commands.toByteArray()
        } catch (e: Exception) {
            println("❌ RENDER ERROR: $e")
            return null
        }
    }

    // 6. Paper and Control Commands
    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
        val commands = mutableListOf<Byte>()
        repeat(lines) {
            commands.add(0x0A.toByte()) // Line Feed (LF)
        }
        writeDataUltraFast(commands.toByteArray())
        result.success(true)
    }

    private fun cutPaper(result: MethodChannel.Result) {
        val commands = mutableListOf<Byte>()
        commands.addAll(listOf(GS, 0x56, 0x00)) // GS V 0 (Full Cut)
        writeDataUltraFast(commands.toByteArray())
        result.success(true)
    }

    private fun setPrinterWidth(width: Int, result: MethodChannel.Result) {
        printerWidth = width
        println("✅ Printer width set to $width dots.")
        result.success(true)
    }

    // MARK: - Helper Functions

    // CRITICAL: Converts Bitmap to printer-ready 1-bit data (Thresholding)
    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val widthBytes = (width + 7) / 8
        val totalBytes = widthBytes * height
        val data = ByteArray(totalBytes)

        // Threshold: 160 (0xA0) converted to ARGB int representation (darker is lower)
        val threshold = -0x5f5f60 // ARGB equivalent of 160 gray value (approx. R=96, G=96, B=96)

        for (y in 0 until height) {
            val bitmapRowOffset = y * widthBytes
            for (x in 0 until width) {
                // If pixel is darker than the threshold, set the corresponding bit.
                if (pixels[y * width + x] < threshold) {
                    val byteIndex = bitmapRowOffset + (x / 8)
                    val bitIndex = 7 - (x % 8)
                    data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
                }
            }
        }

        return MonochromeData(width, height, data)
    }

    private fun containsComplexUnicode(text: String): Boolean {
        for (char in text) {
            val code = char.code
            if (code in 0x1780..0x17FF || // Khmer
                code in 0x0E00..0x0E7F || // Thai
                code in 0x4E00..0x9FFF || // CJK (Chinese/Japanese/Korean)
                code in 0xAC00..0xD7AF    // Hangul
            ) {
                return true
            }
        }
        return false
    }

    private fun wrapText(text: String, maxCharsPerLine: Int): String {
        var result = ""
        var currentLine = ""
        val words = text.split(" ")

        for (word in words) {
            if (currentLine.isEmpty()) {
                currentLine = word
            } else if ((currentLine.length + 1 + word.length) <= maxCharsPerLine) {
                currentLine += " $word"
            } else {
                result += "$currentLine\n"
                currentLine = word
            }
        }

        if (currentLine.isNotEmpty()) {
            result += currentLine
        }

        return result
    }

    // MARK: - Status and Permission

    private fun getStatus(result: MethodChannel.Result) {
        val hasPermission = checkBluetoothPermissions()
        val isEnabled = bluetoothAdapter?.isEnabled ?: false
        val isConnected = bluetoothGatt != null && writeCharacteristic != null

        val status = mapOf(
            "status" to if (hasPermission) "authorized" else "denied",
            "enabled" to isEnabled,
            "connected" to isConnected,
            "connectionType" to if (isConnected) currentConnectionType else "none"
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
}



//=============================sfd===============================
//package com.clearviewerp.salesforce
//
//import android.Manifest
//import android.bluetooth.BluetoothAdapter
//import android.bluetooth.BluetoothDevice
//import android.bluetooth.BluetoothGatt
//import android.bluetooth.BluetoothGattCallback
//import android.bluetooth.BluetoothGattCharacteristic
//import android.bluetooth.BluetoothManager
//import android.bluetooth.BluetoothProfile
//import android.content.Context
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
//import java.net.Socket
//
//class ThermalPrinterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
//    private lateinit var channel: MethodChannel
//    private lateinit var context: Context
//    private val mainHandler = Handler(Looper.getMainLooper())
//
//    // Bluetooth
//    private var bluetoothAdapter: BluetoothAdapter? = null
//    private var bluetoothGatt: BluetoothGatt? = null
//    private var writeCharacteristic: BluetoothGattCharacteristic? = null
//    private var discoveredDevices = mutableListOf<BluetoothDevice>()
//
//    // USB
//    private var usbManager: UsbManager? = null
//
//    // Network
//    private var networkSocket: Socket? = null
//
//    // Connection state
//    private var currentConnectionType = "bluetooth"
//    private var printerWidth = 576 // 80mm default (576px)
//
//    // ESC/POS Commands
//    private val ESC: Byte = 0x1B
//    private val GS: Byte = 0x1D
//
//    // Coroutine scope for async operations
//    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
//
//    // Pending result for async operations
//    private var connectionResult: MethodChannel.Result? = null
//
//    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        context = binding.applicationContext
//        channel = MethodChannel(binding.binaryMessenger, "thermal_printer")
//        channel.setMethodCallHandler(this)
//
//        val bluetoothManager =
//            context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
//        bluetoothAdapter = bluetoothManager?.adapter
//        usbManager = context.getSystemService(Context.USB_SERVICE) as? UsbManager
//
//        println("🔵 ThermalPrinterPlugin initialized")
//    }
//
//    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        channel.setMethodCallHandler(null)
//        scope.cancel()
//    }
//
//    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        when (call.method) {
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
//            "printImage" -> {
//                val imageBytes = call.argument<ByteArray>("imageBytes")
//                val width = call.argument<Int>("width") ?: 384
//                if (imageBytes != null) {
//                    printImage(imageBytes, width, result)
//                } else {
//                    result.error("INVALID_ARGS", "Missing imageBytes", null)
//                }
//            }
//
//            "feedPaper" -> {
//                val lines = call.argument<Int>("lines") ?: 1
//                feedPaper(lines, result)
//            }
//
//            "cutPaper" -> cutPaper(result)
//            "getStatus" -> getStatus(result)
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
//            else -> result.notImplemented()
//        }
//    }
//
//    // MARK: - Discovery
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
//        discoveredDevices.forEach { device ->
//            try {
//                allPrinters.add(
//                    mapOf(
//                        "name" to (device.name ?: "Unknown Device"),
//                        "address" to device.address,
//                        "type" to "ble"
//                    )
//                )
//            } catch (e: SecurityException) {
//                // Skip if we can't access device info
//            }
//        }
//
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
//        try {
//            bluetoothAdapter?.bondedDevices?.forEach { device ->
//                discoveredDevices.add(device)
//            }
//
//            val printers = discoveredDevices.map { device ->
//                mapOf(
//                    "name" to (device.name ?: "Unknown Device"),
//                    "address" to device.address,
//                    "type" to "ble"
//                )
//            }
//
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
//    // MARK: - Connection Helpers
//    private fun cleanupBeforeConnect() {
//        try {
//            bluetoothGatt?.let { gatt ->
//                println("🧹 Cleaning up existing connection...")
//                try {
//                    gatt.disconnect()
//                    Thread.sleep(300)
//                    gatt.close()
//                    Thread.sleep(300)
//                } catch (e: SecurityException) {
//                    println("⚠️ Security exception during cleanup: ${e.message}")
//                }
//            }
//        } catch (e: Exception) {
//            println("⚠️ Cleanup error: ${e.message}")
//        }
//        bluetoothGatt = null
//        writeCharacteristic = null
//    }
//
//    private fun isDeviceAlreadyConnected(address: String): Boolean {
//        try {
//            val bluetoothManager =
//                context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
//            val connectedDevices = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT)
//            return connectedDevices.any { it.address == address }
//        } catch (e: SecurityException) {
//            println("⚠️ Can't check connected devices: ${e.message}")
//            return false
//        } catch (e: Exception) {
//            println("⚠️ Error checking connected devices: ${e.message}")
//            return false
//        }
//    }
//
//    private fun checkDeviceBondState(device: BluetoothDevice): String {
//        return try {
//            when (device.bondState) {
//                BluetoothDevice.BOND_BONDED -> {
//                    println("✅ Device is paired")
//                    "bonded"
//                }
//
//                BluetoothDevice.BOND_BONDING -> {
//                    println("⏳ Device is pairing...")
//                    "bonding"
//                }
//
//                BluetoothDevice.BOND_NONE -> {
//                    println("⚠️ Device is NOT paired!")
//                    "not_bonded"
//                }
//
//                else -> "unknown"
//            }
//        } catch (e: SecurityException) {
//            println("⚠️ Can't check bond state: ${e.message}")
//            "unknown"
//        }
//    }
//
//    // MARK: - Connection
//    private fun connect(address: String, type: String, result: MethodChannel.Result) {
//        currentConnectionType = type
//        println("🔵 Connect request: address=$address, type=$type")
//
//        when (type) {
//            "bluetooth", "ble" -> {
//                // Pre-connection checks
//                try {
//                    val device = bluetoothAdapter?.getRemoteDevice(address)
//                    if (device == null) {
//                        result.error("NOT_FOUND", "Device not found", null)
//                        return
//                    }
//
//                    // Check bond state
//                    val bondState = checkDeviceBondState(device)
//                    if (bondState == "not_bonded") {
//                        result.error(
//                            "NOT_PAIRED",
//                            "Device is not paired. Please pair in Bluetooth settings first.",
//                            null
//                        )
//                        return
//                    }
//
//                    // Check if already connected elsewhere
//                    if (isDeviceAlreadyConnected(address)) {
//                        println("⚠️ Device appears to be connected already, will try to disconnect first")
//                        cleanupBeforeConnect()
//                        Thread.sleep(1000)
//                    }
//
//                } catch (e: SecurityException) {
//                    result.error("PERMISSION_DENIED", e.message, null)
//                    return
//                }
//
//                // Clean up before new connection
//                cleanupBeforeConnect()
//
//                // Now attempt connection
//                connectBluetooth(address, result)
//            }
//
//            "usb" -> result.error("NOT_IMPLEMENTED", "USB not yet implemented", null)
//            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
//        }
//    }
//
//    private fun connectBluetooth(address: String, result: MethodChannel.Result) {
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
//        connectionResult = result
//
//        try {
//            val device = bluetoothAdapter?.getRemoteDevice(address)
//            if (device == null) {
//                result.error("NOT_FOUND", "Device not found", null)
//                connectionResult = null
//                return
//            }
//
//            println("🔵 Connecting to: ${device.name} ($address)")
//
//            bluetoothGatt = device.connectGatt(
//                context,
//                false,
//                object : BluetoothGattCallback() {
//                    override fun onConnectionStateChange(
//                        gatt: BluetoothGatt,
//                        status: Int,
//                        newState: Int
//                    ) {
//                        println("🔵 BLE State Change: status=$status, newState=$newState")
//
//                        when (newState) {
//                            BluetoothProfile.STATE_CONNECTED -> {
//                                println("✅ BLE Connected! Status: $status")
//
//                                if (status == BluetoothGatt.GATT_SUCCESS) {
//                                    try {
//                                        Thread.sleep(600)
//                                        val discovered = gatt.discoverServices()
//                                        println("🔍 Service discovery started: $discovered")
//
//                                        if (!discovered) {
//                                            mainHandler.post {
//                                                connectionResult?.error(
//                                                    "DISCOVER_FAILED",
//                                                    "Failed to start service discovery",
//                                                    null
//                                                )
//                                                connectionResult = null
//                                                gatt.disconnect()
//                                                gatt.close()
//                                            }
//                                        }
//                                    } catch (e: SecurityException) {
//                                        println("❌ Security exception: ${e.message}")
//                                        mainHandler.post {
//                                            connectionResult?.error(
//                                                "PERMISSION_DENIED",
//                                                e.message,
//                                                null
//                                            )
//                                            connectionResult = null
//                                            gatt.disconnect()
//                                            gatt.close()
//                                        }
//                                    } catch (e: Exception) {
//                                        println("❌ Error: ${e.message}")
//                                        mainHandler.post {
//                                            connectionResult?.error("ERROR", e.message, null)
//                                            connectionResult = null
//                                            gatt.disconnect()
//                                            gatt.close()
//                                        }
//                                    }
//                                } else {
//                                    println("⚠️ Connected with error status: $status")
//                                    mainHandler.post {
//                                        connectionResult?.error(
//                                            "CONNECTION_ERROR",
//                                            "Connected but status=$status",
//                                            null
//                                        )
//                                        connectionResult = null
//                                        gatt.disconnect()
//                                        gatt.close()
//                                    }
//                                }
//                            }
//
//                            BluetoothProfile.STATE_DISCONNECTED -> {
//                                val errorMsg = when (status) {
//                                    0 -> "Disconnected normally"
//                                    8 -> "Connection timeout - device not responding"
//                                    19 -> "Connection terminated by peer device"
//                                    22 -> "Connection failed - device busy or unavailable"
//                                    133 -> "GATT error 133 - Device out of range or not ready"
//                                    else -> "Disconnected with status: $status"
//                                }
//                                println("❌ Disconnected: $errorMsg")
//
//                                mainHandler.post {
//                                    if (connectionResult != null) {
//                                        connectionResult?.error("DISCONNECTED", errorMsg, null)
//                                        connectionResult = null
//                                    }
//                                }
//                                gatt.close()
//                            }
//
//                            BluetoothProfile.STATE_CONNECTING -> {
//                                println("🔵 BLE Connecting... (status=$status)")
//                            }
//
//                            BluetoothProfile.STATE_DISCONNECTING -> {
//                                println("🔵 BLE Disconnecting...")
//                            }
//                        }
//                    }
//
//                    override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
//                        println("🔍 Services discovered callback: status=$status")
//
//                        if (status != BluetoothGatt.GATT_SUCCESS) {
//                            println("❌ Service discovery failed: status=$status")
//                            mainHandler.post {
//                                connectionResult?.error(
//                                    "DISCOVER_FAILED",
//                                    "Service discovery failed: $status",
//                                    null
//                                )
//                                connectionResult = null
//                                gatt.disconnect()
//                                gatt.close()
//                            }
//                            return
//                        }
//
//                        println("📋 Found ${gatt.services.size} services")
//
//                        // Log all services and characteristics
//                        for (service in gatt.services) {
//                            println("  📦 Service: ${service.uuid}")
//                            for (char in service.characteristics) {
//                                val props = char.properties
//                                val propsStr = StringBuilder()
//                                if (props and BluetoothGattCharacteristic.PROPERTY_WRITE != 0) propsStr.append(
//                                    "WRITE "
//                                )
//                                if (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0) propsStr.append(
//                                    "WRITE_NO_RESP "
//                                )
//                                if (props and BluetoothGattCharacteristic.PROPERTY_READ != 0) propsStr.append(
//                                    "READ "
//                                )
//                                if (props and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) propsStr.append(
//                                    "NOTIFY "
//                                )
//                                println("    📝 Char: ${char.uuid} [${propsStr.toString().trim()}]")
//                            }
//                        }
//
//                        // Search for writable characteristic
//                        var foundCharacteristic: BluetoothGattCharacteristic? = null
//
//                        // Common thermal printer service UUIDs
//                        val printerServiceUUIDs = listOf(
//                            "000018f0-0000-1000-8000-00805f9b34fb",
//                            "49535343-fe7d-4ae5-8fa9-9fafd205e455",
//                            "0000ffe0-0000-1000-8000-00805f9b34fb",
//                            "0000fff0-0000-1000-8000-00805f9b34fb"
//                        )
//
//                        for (serviceUuidStr in printerServiceUUIDs) {
//                            try {
//                                val service =
//                                    gatt.getService(java.util.UUID.fromString(serviceUuidStr))
//                                if (service != null) {
//                                    println("✅ Found known service: $serviceUuidStr")
//                                    for (char in service.characteristics) {
//                                        val props = char.properties
//                                        if ((props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
//                                            (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
//                                        ) {
//                                            foundCharacteristic = char
//                                            println("✅ Using characteristic: ${char.uuid}")
//                                            break
//                                        }
//                                    }
//                                    if (foundCharacteristic != null) break
//                                }
//                            } catch (e: Exception) {
//                                println("⚠️ Error checking service $serviceUuidStr: ${e.message}")
//                            }
//                        }
//
//                        // Search all services if not found
//                        if (foundCharacteristic == null) {
//                            println("🔍 No known service found, searching all characteristics...")
//                            for (service in gatt.services) {
//                                for (char in service.characteristics) {
//                                    val props = char.properties
//                                    if ((props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
//                                        (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
//                                    ) {
//                                        foundCharacteristic = char
//                                        println("✅ Found writable char: ${char.uuid} in service ${service.uuid}")
//                                        break
//                                    }
//                                }
//                                if (foundCharacteristic != null) break
//                            }
//                        }
//
//                        if (foundCharacteristic != null) {
//                            writeCharacteristic = foundCharacteristic
//                            println("✅ CONNECTION SUCCESS! Using: ${foundCharacteristic.uuid}")
//
//                            mainHandler.post {
//                                connectionResult?.success(true)
//                                connectionResult = null
//                            }
//                        } else {
//                            println("❌ NO WRITABLE CHARACTERISTIC FOUND!")
//
//                            mainHandler.post {
//                                connectionResult?.error(
//                                    "NO_CHARACTERISTIC",
//                                    "No writable characteristic found. This device may not be a thermal printer.",
//                                    null
//                                )
//                                connectionResult = null
//                                gatt.disconnect()
//                                gatt.close()
//                            }
//                        }
//                    }
//
//                    override fun onCharacteristicWrite(
//                        gatt: BluetoothGatt,
//                        characteristic: BluetoothGattCharacteristic,
//                        status: Int
//                    ) {
//                        if (status != BluetoothGatt.GATT_SUCCESS) {
//                            // This is the callback that tells us if the write was successful
//                            println("⚠️ Write failed in callback: status=$status")
//                        }
//                    }
//                },
//                BluetoothDevice.TRANSPORT_LE
//            )
//
//            mainHandler.postDelayed({
//                if (connectionResult != null) {
//                    println("⏱️ BLE Connection timeout (15s)")
//                    connectionResult?.error(
//                        "TIMEOUT",
//                        "Connection timeout. Please ensure:\n1. Printer is ON and nearby\n2. Not connected to another device\n3. Printer is in pairing mode",
//                        null
//                    )
//                    connectionResult = null
//                    try {
//                        bluetoothGatt?.disconnect()
//                        bluetoothGatt?.close()
//                        bluetoothGatt = null
//                    } catch (e: Exception) {
//                        println("⚠️ Cleanup error: ${e.message}")
//                    }
//                }
//            }, 15000)
//
//        } catch (e: SecurityException) {
//            println("❌ Security exception: ${e.message}")
//            result.error("PERMISSION_DENIED", e.message, null)
//            connectionResult = null
//        } catch (e: Exception) {
//            println("❌ Connection error: ${e.message}")
//            result.error("CONNECTION_ERROR", e.message, null)
//            connectionResult = null
//        }
//    }
//
//    private fun connectNetwork(ipAddress: String, port: Int, result: MethodChannel.Result) {
//        scope.launch {
//            try {
//                networkSocket = Socket(ipAddress, port)
//                currentConnectionType = "network"
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
//    private fun disconnect(result: MethodChannel.Result) {
//        try {
//            when (currentConnectionType) {
//                "bluetooth", "ble" -> {
//                    bluetoothGatt?.disconnect()
//                    bluetoothGatt?.close()
//                    bluetoothGatt = null
//                    writeCharacteristic = null
//                }
//
//                "network" -> {
//                    networkSocket?.close()
//                    networkSocket = null
//                }
//            }
//            result.success(true)
//        } catch (e: Exception) {
//            result.error("DISCONNECT_ERROR", e.message, null)
//        }
//    }
//
//    private fun writeDataUltraFast(data: ByteArray) {
//        val startTime = System.currentTimeMillis()
//        when (currentConnectionType) {
//            "bluetooth", "ble" -> {
//                val characteristic = writeCharacteristic
//                val gatt = bluetoothGatt
//                if (characteristic == null || gatt == null) {
//                    println("❌ WRITE: No characteristic/gatt")
//                    return
//                }
//                try {
//                    // Using a safe chunk size (20 bytes) for stability.
//                    val chunkSize = 20
//                    var offset = 0
//                    var chunkCount = 0
//
//                    println("📝 Starting BLE write (stable mode): ${data.size} bytes. Chunk size: $chunkSize.")
//
//                    while (offset < data.size) {
//                        val end = minOf(offset + chunkSize, data.size)
//                        val chunk = data.copyOfRange(offset, end)
//
//                        characteristic.value = chunk
//                        characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
//
//                        val writeSuccess = gatt.writeCharacteristic(characteristic)
//                        if (!writeSuccess) {
//                            println("⚠️ Write failed at offset $offset - Re-attempting/Ignoring...")
//                        }
//
//                        offset = end
//                        chunkCount++
//
//                        // Add a minimal 1ms delay for flow control
//                        Thread.sleep(3)
//                    }
//
//                    // Keep a small final delay to ensure all data is processed by the printer's buffer.
//                    Thread.sleep(40)
//
//                    val writeTime = System.currentTimeMillis() - startTime
//                    println("📡 BLE WRITE: ${data.size} bytes in $chunkCount chunks, took ${writeTime}ms")
//                } catch (e: SecurityException) {
//                    println("❌ WRITE: Permission denied - $e")
//                } catch (e: InterruptedException) {
//                    println("⚠️ WRITE: Interrupted - $e")
//                }
//            }
//            "network" -> {
//                try {
//                    networkSocket?.getOutputStream()?.write(data)
//                    networkSocket?.getOutputStream()?.flush()
//                    val writeTime = System.currentTimeMillis() - startTime
//                    println("📡 NET WRITE: ${data.size} bytes, took ${writeTime}ms")
//                } catch (e: Exception) {
//                    println("❌ WRITE: Network error - $e")
//                }
//            }
//        }
//    }
//
//
//    // MARK: - Printing Functions
//    private fun printText(
//        text: String,
//        fontSize: Int,
//        bold: Boolean,
//        align: String,
//        maxCharsPerLine: Int,
//        result: MethodChannel.Result
//    ) {
//        val startTime = System.currentTimeMillis()
//        val preview = text.take(30)
//
//        // Only render complex unicode (CJK, Thai, etc.) as an image
//        if (containsComplexUnicode(text)) {
//            println("🔵 KOTLIN: Rendering Complex text: \"$preview...\"")
//            scope.launch {
//                val renderStart = System.currentTimeMillis()
//                val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)
//                if (imageData == null) {
//                    withContext(Dispatchers.Main) {
//                        result.error("RENDER_ERROR", "Failed to render", null)
//                    }
//                    return@launch
//                }
//                val renderTime = System.currentTimeMillis() - renderStart
//                println("⏱️ KOTLIN: Rendered in ${renderTime}ms, size: ${imageData.size} bytes")
//
//                withContext(Dispatchers.Main) {
//                    val sendStart = System.currentTimeMillis()
//                    writeDataUltraFast(imageData)
//                    val sendTime = System.currentTimeMillis() - sendStart
//                    val totalTime = System.currentTimeMillis() - startTime
//                    println("📤 KOTLIN: Sent in ${sendTime}ms, total: ${totalTime}ms")
//                    result.success(true)
//                }
//            }
//        } else {
//            // Placeholder: For pure ASCII text, this should be replaced with direct ESC/POS command generation for speed.
//            println("⚠️ KOTLIN: Simple text printing is a STUB. No data sent for: \"$preview...\"")
//            val totalTime = System.currentTimeMillis() - startTime
//            println("✅ KOTLIN: Simple text path stub executed in ${totalTime}ms")
//            result.success(true)
//        }
//    }
//
//    private fun containsComplexUnicode(text: String): Boolean {
//        for (char in text) {
//            val code = char.code
//            if (code in 0x1780..0x17FF || // Khmer
//                code in 0x0E00..0x0E7F || // Thai
//                code in 0x4E00..0x9FFF || // CJK (Chinese/Japanese/Korean)
//                code in 0xAC00..0xD7AF
//            ) { // Hangul
//                return true
//            }
//        }
//        return false
//    }
//
//
//    private fun wrapText(text: String, maxCharsPerLine: Int): String {
//        val result = StringBuilder()
//        var currentLine = StringBuilder()
//        val lines = text.split('\n')
//
//        for (line in lines) {
//            val words = line.split(" ")
//            currentLine = StringBuilder()
//
//            for (word in words) {
//                if (currentLine.isEmpty()) {
//                    currentLine.append(word)
//                } else if (currentLine.length + 1 + word.length <= maxCharsPerLine) {
//                    currentLine.append(" ").append(word)
//                } else {
//                    result.append(currentLine).append("\n")
//                    currentLine = StringBuilder(word)
//                }
//            }
//            // Append the last line segment
//            if (currentLine.isNotEmpty()) {
//                result.append(currentLine)
//            }
//            // Add a final newline only if the original line had one (unless it was the last line)
//            if (lines.indexOf(line) < lines.size - 1) {
//                result.append("\n")
//            }
//        }
//        return result.toString()
//    }
//
//
//    private fun renderTextToData(
//        text: String,
//        fontSize: Int,
//        bold: Boolean,
//        align: String,
//        maxCharsPerLine: Int
//    ): ByteArray? {
//        try {
//            val paint = Paint().apply {
//                textSize = fontSize.toFloat()
//                typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
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
//            val padding = 8f
//
//            val textToRender = if (maxCharsPerLine > 0) {
//                wrapText(text, maxCharsPerLine)
//            } else {
//                text
//            }
//
//            val lines = textToRender.split("\n")
//            val lineHeight = paint.fontMetrics.let { it.descent - it.ascent }
//            val totalHeight = (lines.size * lineHeight + padding * 2).toInt()
//
//            val bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
//            val canvas = Canvas(bitmap)
//            canvas.drawColor(Color.WHITE)
//
//            // FIX: Corrected typo from 'asent' to 'ascent'
//            var y = padding - paint.fontMetrics.ascent
//            for (line in lines) {
//                val x = when (paint.textAlign) {
//                    Paint.Align.CENTER -> maxWidth / 2
//                    Paint.Align.RIGHT -> maxWidth - padding
//                    else -> padding
//                }
//                canvas.drawText(line, x, y, paint)
//                y += lineHeight
//            }
//
//            val monoData = convertToMonochromeFast(bitmap)
//            if (monoData == null) {
//                bitmap.recycle()
//                return null
//            }
//
//            val commands = mutableListOf<Byte>()
//            commands.addAll(listOf(ESC, 0x40))          // Initialize Printer
//            commands.addAll(listOf(ESC, 0x74, 0x01))    // FIX: Select Code Page PC437 (Standard English/Western)
//            commands.addAll(listOf(GS, 0x76, 0x30, 0x00))
//
//            val widthBytes = (monoData.width + 7) / 8
//            commands.add((widthBytes and 0xFF).toByte())
//            commands.add(((widthBytes shr 8) and 0xFF).toByte())
//            commands.add((monoData.height and 0xFF).toByte())
//            commands.add(((monoData.height shr 8) and 0xFF).toByte())
//            commands.addAll(monoData.data.toList())
//            commands.add(0x0A)
//
//            bitmap.recycle()
//            return commands.toByteArray()
//        } catch (e: Exception) {
//            println("❌ RENDER ERROR: $e")
//            return null
//        }
//    }
//
//    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
//        val width = bitmap.width
//        val height = bitmap.height
//        val widthBytes = (width + 7) / 8
//        val data = ByteArray(widthBytes * height)
//
//        val threshold = 160
//
//        // Copy all pixels in one fast operation
//        val pixels = IntArray(width * height)
//        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
//
//        for (y in 0 until height) {
//            for (x in 0 until width) {
//                // Use the pre-fetched pixel array for faster access
//                val pixel = pixels[y * width + x]
//                val gray = (Color.red(pixel) + Color.green(pixel) + Color.blue(pixel)) / 3
//                if (gray < threshold) {
//                    val byteIndex = y * widthBytes + (x / 8)
//                    val bitIndex = 7 - (x % 8)
//                    data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
//                }
//            }
//        }
//
//        return MonochromeData(width, height, data)
//    }
//
//    private data class MonochromeData(val width: Int, val height: Int, val data: ByteArray)
//
//    private fun printImage(imageBytes: ByteArray, width: Int, result: MethodChannel.Result) {
//        scope.launch {
//            try {
//                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
//                if (bitmap == null) {
//                    withContext(Dispatchers.Main) {
//                        result.error("INVALID_IMAGE", "Cannot decode image", null)
//                    }
//                    return@launch
//                }
//
//                val scaledBitmap = resizeImage(bitmap, 576)
//                val monoData = convertToMonochromeFast(scaledBitmap)
//                if (monoData == null) {
//                    bitmap.recycle()
//                    scaledBitmap.recycle()
//                    withContext(Dispatchers.Main) {
//                        result.error("CONVERSION_ERROR", "Cannot convert", null)
//                    }
//                    return@launch
//                }
//
//                val commands = mutableListOf<Byte>()
//                commands.addAll(listOf(ESC, 0x40))
//                commands.addAll(listOf(ESC, 0x74, 0x01)) // Select Code Page PC437
//                commands.addAll(listOf(GS, 0x76, 0x30, 0x00))
//
//                val widthBytes = (monoData.width + 7) / 8
//                commands.add((widthBytes and 0xFF).toByte())
//                commands.add(((widthBytes shr 8) and 0xFF).toByte())
//                commands.add((monoData.height and 0xFF).toByte())
//                commands.add(((monoData.height shr 8) and 0xFF).toByte())
//                commands.addAll(monoData.data.toList())
//                commands.addAll(listOf(0x0A, 0x0A))
//
//                bitmap.recycle()
//                scaledBitmap.recycle()
//
//                withContext(Dispatchers.Main) {
//                    writeDataUltraFast(commands.toByteArray())
//                    result.success(true)
//                }
//            } catch (e: Exception) {
//                withContext(Dispatchers.Main) {
//                    result.error("PRINT_ERROR", e.message, null)
//                }
//            }
//        }
//    }
//
//    private fun resizeImage(bitmap: Bitmap, maxWidth: Int): Bitmap {
//        if (bitmap.width <= maxWidth) return bitmap
//        val ratio = maxWidth.toFloat() / bitmap.width
//        val newHeight = (bitmap.height * ratio).toInt()
//        return Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
//    }
//
//    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
//        val commands = ByteArray(lines) { 0x0A }
//        writeDataUltraFast(commands)
//        result.success(true)
//    }
//
//    private fun cutPaper(result: MethodChannel.Result) {
//        val commands = byteArrayOf(GS, 0x56, 0x00)
//        writeDataUltraFast(commands)
//        result.success(true)
//    }
//
//    private fun getStatus(result: MethodChannel.Result) {
//        val connected = when (currentConnectionType) {
//            "bluetooth", "ble" -> bluetoothGatt != null && writeCharacteristic != null
//            "network" -> networkSocket?.isConnected == true
//            else -> false
//        }
//        result.success(
//            mapOf(
//                "connected" to connected,
//                "paperStatus" to "ok",
//                "connectionType" to currentConnectionType,
//                "printerWidth" to printerWidth
//            )
//        )
//    }
//
//    private fun setPrinterWidth(width: Int, result: MethodChannel.Result) {
//        if (width == 384 || width == 576) {
//            printerWidth = width
//            result.success(true)
//        } else {
//            result.error("INVALID_WIDTH", "Width must be 384 or 576", null)
//        }
//    }
//
//    private fun checkBluetoothPermission(result: MethodChannel.Result) {
//        val hasPermission = checkBluetoothPermissions()
//        val isEnabled = bluetoothAdapter?.isEnabled == true
//        val status = when {
//            !hasPermission -> mapOf(
//                "status" to "denied",
//                "enabled" to false,
//                "message" to "Bluetooth permission denied"
//            )
//
//            !isEnabled -> mapOf(
//                "status" to "authorized",
//                "enabled" to false,
//                "message" to "Bluetooth is turned off"
//            )
//
//            else -> mapOf(
//                "status" to "authorized",
//                "enabled" to true,
//                "message" to "Bluetooth is ready"
//            )
//        }
//        result.success(status)
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
