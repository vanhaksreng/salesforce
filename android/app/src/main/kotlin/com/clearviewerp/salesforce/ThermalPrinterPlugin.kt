package com.clearviewerp.salesforce

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
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
import kotlinx.coroutines.internal.synchronized
import java.net.Socket
import java.util.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

// ====================================================================
// Define ESC/POS Data Class
// ====================================================================

// Data class to hold the output of monochrome conversion
data class MonochromeData(val width: Int, val height: Int, val data: ByteArray)

data class PosColumn(
    val text: String,
    val width: Int,
    val align: String,
    val bold: Boolean
)

class ThermalPrinterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val mainHandler = Handler(Looper.getMainLooper())

    // Bluetooth
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var bluetoothSocket: android.bluetooth.BluetoothSocket? = null
    private var discoveredDevices = mutableListOf<BluetoothDevice>()
    private var discoveryReceiver: BroadcastReceiver? = null

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
    private val printMutex = Mutex()
    private var writeCompleted = false
    private var writeLatch: CountDownLatch? = null

    enum class ImageAlignment(val value: Int) {
        LEFT(0),
        CENTER(1),
        RIGHT(2);

        companion object {
            fun fromInt(value: Int) = values().firstOrNull { it.value == value } ?: CENTER
        }
    }
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

        // Unregister discovery receiver if exists
        discoveryReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                // Already unregistered
            }
        }

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
                    printImage(imageBytes, width,align, result)
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

    // MARK: - Discovery
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

        // Use mutableListOf and addAll
        val allPrinters = discoveredDevices.mapNotNull { device ->
            try {
                val deviceName = device.name
                if (!deviceName.isNullOrBlank() && deviceName != "Unknown Device") {
                    mapOf(
                        "name" to deviceName,
                        "address" to device.address,
                        "type" to "bluetooth"
                    )
                } else {
                    null
                }
            } catch (e: SecurityException) {
                null
            }
        }.toMutableList()

        // Add USB devices
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

        // Add bonded devices first
        try {
            bluetoothAdapter?.bondedDevices?.forEach { device ->
                discoveredDevices.add(device)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
            return
        }

        // Start discovery for unpaired devices
        try {
            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }
            bluetoothAdapter?.startDiscovery()

            // Register broadcast receiver to listen for discovered devices
            registerDiscoveryReceiver(result)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        }
    }

    private fun registerDiscoveryReceiver(result: MethodChannel.Result) {
        // Unregister previous receiver if exists
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
                        val device: BluetoothDevice? =
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        device?.let {
                            if (!discoveredDevices.contains(it)) {
                                discoveredDevices.add(it)
                                println("📱 Found device: ${it.name ?: "Unknown"} (${it.address})")
                            }
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                        println("🔍 Discovery finished. Total devices: ${discoveredDevices.size}")
                        returnDiscoveredDevices(result)
                        try {
                            context?.unregisterReceiver(this)
                            discoveryReceiver = null
                        } catch (e: IllegalArgumentException) {
                            // Receiver already unregistered
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

    // MARK: - Connection Helpers
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

    // MARK: - Connection
    private fun connect(address: String, type: String, result: MethodChannel.Result) {
        currentConnectionType = type
        println("🔵 Connect request: address=$address, type=$type")

        when (type) {
            "bluetooth" -> {
                // Try Classic Bluetooth first (SPP)
                connectClassicBluetooth(address, result)
            }
            "ble" -> {
                // BLE connection
                connectBLE(address, result)
            }
            "usb" -> result.error("NOT_IMPLEMENTED", "USB not yet implemented", null)
            else -> result.error("INVALID_TYPE", "Unknown connection type", null)
        }
    }

    // New method: Classic Bluetooth connection via SPP
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

                // Close existing socket if any
                bluetoothSocket?.close()

                // Cancel discovery to improve connection
                bluetoothAdapter?.cancelDiscovery()

                // Try multiple UUIDs (some printers use different UUIDs)
                val uuids = listOf(
                    "00001101-0000-1000-8000-00805F9B34FB", // SPP (Standard)
                    "00001102-0000-1000-8000-00805F9B34FB", // LAN Access Using PPP
                    "00001103-0000-1000-8000-00805F9B34FB"  // Dialup Networking
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
                // If Classic fails, try BLE as fallback
                println("🔄 Falling back to BLE connection...")
                withContext(Dispatchers.Main) {
                    connectBLE(address, result)
                }
            }
        }
    }

    // Renamed existing method for BLE
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

        // Now attempt BLE connection
        connectBluetoothBLE(address, result)
    }

    // Original BLE connection method renamed
    private fun connectBluetoothBLE(address: String, result: MethodChannel.Result) {
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

                    // Inside your BluetoothGattCallback class (or wherever you handle the result)
                    override fun onCharacteristicWrite(
                        gatt: BluetoothGatt?,
                        characteristic: BluetoothGattCharacteristic?,
                        status: Int
                    ) {
                        if (status == BluetoothGatt.GATT_SUCCESS) {
                            writeCompleted = true
                            writeLatch?.countDown()
                            currentWriteDeferred?.complete(true)
                        } else {
                            writeLatch?.countDown()
                            currentWriteDeferred?.complete(false)
                            println("⚠️ Write failed: status=$status")
                        }
                        currentWriteDeferred = null
                    }

                    // You would need to define this in your main plugin class:
                    private var currentWriteDeferred: CompletableDeferred<Boolean>? = null
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
                    // Close Classic Bluetooth socket
                    bluetoothSocket?.close()
                    bluetoothSocket = null

                    // Close BLE connection
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

    // Add this at the top with other class properties
    private var lastPrintTime = 0L
    private val imageProcessingDelay = 150L  // Wait 150ms after sending image data

    private fun writeDataSmooth(data: ByteArray) {
        val startTime = System.currentTimeMillis()

        // Calculate delay based on data size
        val isLargeData = data.size > 2000

        when (currentConnectionType) {
            "bluetooth" -> {
                val socket = bluetoothSocket
                if (socket != null && socket.isConnected) {
                    try {
                        writeClassicBluetoothSmooth(socket, data)

                        // CRITICAL FIX: Wait after large data
                        if (isLargeData) {
                            val estimatedPrintTime = (data.size / 50).toLong() // ~50 bytes/ms print speed
                            Thread.sleep(minOf(estimatedPrintTime, 200L)) // Max 200ms wait
                            println("⏱️ Waited ${minOf(estimatedPrintTime, 200L)}ms for printer to process")
                        }

                        val writeTime = System.currentTimeMillis() - startTime
                        println("✅ Classic BT: ${data.size} bytes in ${writeTime}ms")
                        return
                    } catch (e: Exception) {
                        println("❌ Classic BT failed: ${e.message}")
                    }
                }
                writeBLEDataSmooth(data, startTime)
            }
            "ble" -> {
                writeBLEDataSmooth(data, startTime)
                if (isLargeData) {
                    val estimatedPrintTime = (data.size / 40).toLong()
                    Thread.sleep(minOf(estimatedPrintTime, 250L))
                    println("⏱️ BLE: Waited ${minOf(estimatedPrintTime, 250L)}ms for printer")
                }
            }
            "network" -> {
                writeNetworkSmooth(data)
                if (isLargeData) {
                    Thread.sleep(150L)
                }
            }
        }
    }

    private fun writeNetworkSmooth(data: ByteArray) {
        try {
            val outputStream = networkSocket?.getOutputStream()
            val chunkSize = if (data.size > 2000) 512 else 1024
            var offset = 0

            while (offset < data.size) {
                val end = minOf(offset + chunkSize, data.size)
                val chunk = data.copyOfRange(offset, end)

                outputStream?.write(chunk)
                outputStream?.flush()
                Thread.sleep(if (data.size > 2000) 15L else 10L)

                offset = end
            }

        } catch (e: Exception) {
            println("❌ Network error: ${e.message}")
        }
    }


    // FIX 2: Classic BT with Proper Chunk Delays
// ============================================
    private fun writeClassicBluetoothSmooth(socket: android.bluetooth.BluetoothSocket, data: ByteArray) {
        // Dynamic chunk size based on data size
        val chunkSize = when {
            data.size > 4000 -> 128  // Very large: tiny chunks
            data.size > 2000 -> 256  // Large images: small chunks
            data.size > 1000 -> 512  // Medium data
            else -> 1024             // Small data: larger chunks
        }

        println("📦 Write ${data.size} bytes, chunk=$chunkSize")

        var offset = 0
        val outputStream = socket.outputStream
        var chunkCount = 0

        while (offset < data.size) {
            val end = minOf(offset + chunkSize, data.size)
            val chunk = data.copyOfRange(offset, end)

            outputStream.write(chunk)
            outputStream.flush()

            // Dynamic delay based on chunk size
            val delay = when {
                data.size > 4000 -> 20L  // Large images need more time
                data.size > 2000 -> 15L
                chunk.size >= 512 -> 12L
                chunk.size >= 256 -> 10L
                else -> 8L
            }

            Thread.sleep(delay)
            offset = end
            chunkCount++
        }

        println("📊 Sent ${chunkCount} chunks with delays")
    }



    private fun writeBLEDataSmooth(data: ByteArray, startTime: Long) {
        val characteristic = writeCharacteristic
        val gatt = bluetoothGatt

        if (characteristic == null || gatt == null) {
            println("❌ No BLE connection")
            return
        }

        try {
            val useNoResponse = (characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0

            if (useNoResponse) {
                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE

                // Smaller chunks for large data
                val chunkSize = if (data.size > 2000) 64 else 128
                println("📝 BLE No-Response: ${data.size} bytes, chunk=$chunkSize")

                var offset = 0
                while (offset < data.size) {
                    val end = minOf(offset + chunkSize, data.size)
                    val chunk = data.copyOfRange(offset, end)

                    characteristic.value = chunk
                    gatt.writeCharacteristic(characteristic)

                    // Longer delay for image data
                    val delay = if (data.size > 2000) 30L else 15L
                    Thread.sleep(delay)

                    offset = end
                }
            } else {
                // WITH_RESPONSE: Must wait for acknowledgment
                characteristic.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
                val chunkSize = 20
                println("📝 BLE With-Response: ${data.size} bytes")

                var offset = 0
                while (offset < data.size) {
                    val end = minOf(offset + chunkSize, data.size)
                    val chunk = data.copyOfRange(offset, end)

                    writeLatch = CountDownLatch(1)
                    writeCompleted = false

                    characteristic.value = chunk
                    gatt.writeCharacteristic(characteristic)

                    // Wait for acknowledgment or timeout
                    writeLatch?.await(100, TimeUnit.MILLISECONDS)

                    offset = end
                }
            }

            val writeTime = System.currentTimeMillis() - startTime
            println(" BLE: ${writeTime}ms total")

        } catch (e: Exception) {
            println(" BLE Error: ${e.message}")
        }
    }
//===============================================new add==========================
// ===== FONT CACHE =====
private val khmerTypefaceCache = mutableMapOf<String, Typeface?>()

    private fun getKhmerTypeface(bold: Boolean): Typeface {
        val fontKey = if (bold) "bold" else "regular"

        if (!khmerTypefaceCache.containsKey(fontKey)) {
            khmerTypefaceCache[fontKey] = try {
                val fontPath = when {
                    bold -> {
                        // Try Bold first, fallback to SemiBold, then Medium, finally Regular
                        when {
                            assetExists("fonts/NotoSansKhmer-Bold.ttf") ->
                                "fonts/NotoSansKhmer-Bold.ttf"
                            assetExists("fonts/NotoSansKhmer-SemiBold.ttf") ->
                                "fonts/NotoSansKhmer-SemiBold.ttf"
                            assetExists("fonts/NotoSansKhmer-Medium.ttf") ->
                                "fonts/NotoSansKhmer-Medium.ttf"
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

        return khmerTypefaceCache[fontKey] ?: Typeface.DEFAULT
    }

    private fun assetExists(path: String): Boolean {
        return try {
            context.assets.open(path).use { true }
        } catch (e: Exception) {
            false
        }
    }

    // Optional: Preload fonts at startup for better performance
    fun preloadFonts() {
        println("🔄 Preloading fonts...")
        getKhmerTypeface(false) // Load regular
        getKhmerTypeface(true)  // Load bold
        println("✅ Fonts preloaded")
    }

    // ===== MAIN PRINT FUNCTION =====
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
                    if (containsComplexUnicode(text)) {
                        println("🖼️ KOTLIN: Rendering Complex text (Image): \"${text.take(30)}...\"")
                        val renderStart = System.currentTimeMillis()

                        val imageData = renderTextToData(text, fontSize, bold, align, maxCharsPerLine)

                        if (imageData == null || imageData.isEmpty()) {
                            withContext(Dispatchers.Main) {
                                result.error("RENDER_ERROR", "Failed to render or returned empty image data", null)
                            }
                            return@withLock
                        }

                        val renderTime = System.currentTimeMillis() - renderStart
                        println("✅ KOTLIN: Rendered in ${renderTime}ms, size: ${imageData.size} bytes")

                        val alignLeftCommand = byteArrayOf(ESC, 0x61.toByte(), 0x00.toByte())
                        val finalData = alignLeftCommand + imageData

                        writeDataSmooth(finalData)

                        val totalTime = System.currentTimeMillis() - startTime
                        println("🖨️ KOTLIN: Sent, total: ${totalTime}ms")

                    } else {
                        printSimpleTextInternal(text, fontSize, bold, align, maxCharsPerLine)

                        val totalTime = System.currentTimeMillis() - startTime
                        println("⚡ KOTLIN: English printed in ${totalTime}ms")
                    }

                    // Optional: Add small delay if printer needs it
                    // delay(50)

                    withContext(Dispatchers.Main) {
                        result.success(true)
                    }

                } catch (e: Exception) {
                    println("❌ PRINT ERROR: ${e.message}")
                    e.printStackTrace()
                    withContext(Dispatchers.Main) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                }
            }
        }
    }

    // ===== OPTIMIZED RENDER FUNCTION =====
    private fun renderTextToData(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int
    ): ByteArray? {
        try {
            // OPTIMIZATION 1: Use cached typeface with proper bold font
            val khmerTypeface = getKhmerTypeface(bold)

            // OPTIMIZATION 2: Scale font conservatively
            val baseFontSize = 24f // Reduced for smaller output
            val scaledFontSize = when {
                fontSize > 30 -> baseFontSize * 2.0f
                fontSize > 24 -> baseFontSize * 1.5f
                else -> baseFontSize
            }

            println("📏 KOTLIN: fontSize=$fontSize -> scaledFontSize=$scaledFontSize, bold=$bold")

            val paint = Paint().apply {
                textSize = scaledFontSize
                typeface = khmerTypeface
                isFakeBoldText = false // Don't fake bold - we have real fonts
                strokeWidth = 0f // No stroke needed with proper fonts
                style = Paint.Style.FILL // OPTIMIZATION 3: FILL only (faster)
                isAntiAlias = false // OPTIMIZATION 4: Sharper for monochrome
                color = Color.BLACK
                textAlign = when (align.lowercase()) {
                    "center" -> Paint.Align.CENTER
                    "right" -> Paint.Align.RIGHT
                    else -> Paint.Align.LEFT
                }
            }

            val maxWidth = printerWidth.toFloat()
            val padding = 2f // Minimal padding
            val LEFT_MARGIN_OFFSET = when (paint.textAlign) {
                Paint.Align.LEFT -> padding
                else -> 0f
            }

            val textToRender = if (maxCharsPerLine > 0) {
                wrapText(text, maxCharsPerLine)
            } else {
                text
            }

            val lines = textToRender.split("\n")

            // OPTIMIZATION 5: Tighter line spacing
            val lineHeight = paint.fontMetrics.let {
                (it.descent - it.ascent) * 0.90f // 15% tighter
            }
            val totalHeight = (lines.size * lineHeight + padding * 2).toInt()

            val bitmap = Bitmap.createBitmap(
                printerWidth,
                totalHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)

            var y = padding - paint.fontMetrics.ascent
            for (line in lines) {
                if (line.isBlank()) {
                    y += lineHeight
                    continue
                }

                val x = when (paint.textAlign) {
                    Paint.Align.CENTER -> maxWidth / 2
                    Paint.Align.RIGHT -> maxWidth - padding
                    else -> LEFT_MARGIN_OFFSET
                }
                canvas.drawText(line, x, y, paint)
                y += lineHeight
            }

            val monoData = convertToMonochromeFast(bitmap)
            bitmap.recycle()

            if (monoData == null) {
                println("❌ Failed to convert bitmap to monochrome")
                return null
            }

            // OPTIMIZATION 6: Pre-allocate exact size (faster than mutableList)
            val widthBytes = (monoData.width + 7) / 8
            val commandSize = 8 + monoData.data.size
            val commands = ByteArray(commandSize)

            var idx = 0
            // ESC/POS raster image command: GS v 0
            commands[idx++] = GS
            commands[idx++] = 0x76
            commands[idx++] = 0x30
            commands[idx++] = 0x00

            // Width in bytes (little-endian)
            commands[idx++] = (widthBytes and 0xFF).toByte()
            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()

            // Height (little-endian)
            commands[idx++] = (monoData.height and 0xFF).toByte()
            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()

            // OPTIMIZATION 7: Use System.arraycopy (much faster than addAll)
            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)

            return commands

        } catch (e: Exception) {
            println("❌ RENDER ERROR: ${e.message}")
            e.printStackTrace()
            return null
        }
    }

    // ===== OPTIMIZED SIMPLE TEXT (Already fast) =====
    private fun printSimpleTextInternal(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int
    ) {
        println("🔵 KOTLIN: Sending ASCII/Simple text via ESC/POS: \"${text.take(30)}...\"")

        val commands = mutableListOf<Byte>()

        // Initialize printer
        commands.addAll(listOf(ESC, 0x40))
        commands.addAll(listOf(ESC, 0x74, 0x01))

        // Bold
        commands.addAll(listOf(ESC, 0x45, if (bold) 0x01 else 0x00))

        // Alignment
        val alignValue = when (align.lowercase()) {
            "center" -> 0x01.toByte()
            "right" -> 0x02.toByte()
            else -> 0x00.toByte()
        }
        commands.addAll(listOf(ESC, 0x61, alignValue))

        // Size
        val sizeCommand: Byte = when {
            fontSize > 30 -> 0x30.toByte()
            fontSize > 24 -> 0x11.toByte()
            else -> 0x00.toByte()
        }
        commands.addAll(listOf(ESC, 0x21, sizeCommand))

        // Text content
        val wrappedText = if (maxCharsPerLine > 0) wrapText(text, maxCharsPerLine) else text
        commands.addAll(wrappedText.toByteArray(charset("CP437")).toList())

        commands.add(0x0A.toByte())

        // Reset formatting
        commands.addAll(listOf(ESC, 0x45, 0x00))
        commands.addAll(listOf(ESC, 0x61, 0x00))

        writeDataSmooth(commands.toByteArray())
    }

    fun printImage(
        imageBytes: ByteArray,
        width: Int = 384,
        align: Int = 1,
        result: MethodChannel.Result
    ) {
        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                result.error("INVALID_IMAGE", "Cannot decode image", null)
                return
            }

            val alignment = ImageAlignment.fromInt(align)
            val scaledBitmap = resizeImage(bitmap, width)
            val monochromeData = convertToMonochromeFast(scaledBitmap)

            if (monochromeData == null) {
                result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
                return
            }

            val commands = mutableListOf<Byte>()

            // Initialize printer
            commands.add(ESC)
            commands.add(0x40)

            // Set alignment using ESC a n command
            commands.add(ESC)
            commands.add(0x61)
            commands.add(alignment.value.toByte())

            // Print image command: GS v 0
            commands.add(GS)
            commands.add(0x76)
            commands.add(0x30)
            commands.add(0x00)

            // Width and height in bytes
            val widthBytes = (monochromeData.width + 7) / 8
            commands.add((widthBytes and 0xFF).toByte())
            commands.add(((widthBytes shr 8) and 0xFF).toByte())
            commands.add((monochromeData.height and 0xFF).toByte())
            commands.add(((monochromeData.height shr 8) and 0xFF).toByte())

            // Image data
            commands.addAll(monochromeData.data.toList())

            // Reset alignment to left after printing
            commands.add(ESC)
            commands.add(0x61)
            commands.add(0x00)

            // Line feeds
            commands.add(0x0A)
            commands.add(0x0A)

            // Send to printer
            writeDataSmooth(commands.toByteArray())
            result.success(true)

        } catch (e: Exception) {
            result.error("PRINT_ERROR", "Failed to print image: ${e.message}", null)
        }
    }

    // MARK: - Print Image with Manual Padding
    fun printImageWithPadding(
        imageBytes: ByteArray,
        width: Int = 384,
        align: Int = 1,
        paperWidth: Int = 576,
        result: MethodChannel.Result
    ) {
        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                result.error("INVALID_IMAGE", "Cannot decode image", null)
                return
            }

            val alignment = ImageAlignment.fromInt(align)
            val scaledBitmap = resizeImage(bitmap, width)
            val originalData = convertToMonochromeFast(scaledBitmap)

            if (originalData == null) {
                result.error("CONVERSION_ERROR", "Cannot convert to monochrome", null)
                return
            }

            // Add padding for alignment if needed
            val monochromeData = if (alignment != ImageAlignment.LEFT) {
                addPaddingToMonochrome(originalData, alignment, paperWidth)
            } else {
                originalData
            }

            val commands = mutableListOf<Byte>()

            // Initialize printer
            commands.add(ESC)
            commands.add(0x40)

            // Print image command
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
            result.success(true)

        } catch (e: Exception) {
            result.error("PRINT_ERROR", "Failed to print image: ${e.message}", null)
        }
    }

    // MARK: - Resize Image
    private fun resizeImage(bitmap: Bitmap, maxWidth: Int): Bitmap {
        if (bitmap.width <= maxWidth) {
            return bitmap
        }

        val ratio = maxWidth.toFloat() / bitmap.width
        val newHeight = (bitmap.height * ratio).toInt()

        return Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
    }

    // MARK: - Add Padding to Monochrome Data
    private fun addPaddingToMonochrome(
        data: MonochromeData,
        alignment: ImageAlignment,
        paperWidth: Int
    ): MonochromeData {
        val currentWidth = data.width

        // No padding needed if image is already full width
        if (currentWidth >= paperWidth) {
            return data
        }

        val paddingTotal = paperWidth - currentWidth
        val leftPadding = when (alignment) {
            ImageAlignment.LEFT -> 0
            ImageAlignment.CENTER -> paddingTotal / 2
            ImageAlignment.RIGHT -> paddingTotal
        }
        val rightPadding = paddingTotal - leftPadding

        val currentWidthBytes = (currentWidth + 7) / 8
        val newWidth = paperWidth
        val newWidthBytes = (newWidth + 7) / 8

        val newData = ByteArray(newWidthBytes * data.height)

        for (y in 0 until data.height) {
            val newRowOffset = y * newWidthBytes
            val oldRowOffset = y * currentWidthBytes

            // Left padding (already zeros)
            val leftPaddingBytes = leftPadding / 8

            // Copy original data
            System.arraycopy(
                data.data,
                oldRowOffset,
                newData,
                newRowOffset + leftPaddingBytes,
                currentWidthBytes
            )

            // Right padding (already zeros)
        }

        return MonochromeData(newWidth, data.height, newData)
    }


//    private fun printImage(imageBytes: ByteArray, width: Int, result: MethodChannel.Result) {
//        scope.launch {
//            printMutex.withLock {
//                try {
//                    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
//
//                    val scaledBitmap = if (bitmap.width != width) {
//                        val ratio = width.toFloat() / bitmap.width.toFloat()
//                        val newHeight = (bitmap.height * ratio).toInt()
//                        Bitmap.createScaledBitmap(bitmap, width, newHeight, true)
//                    } else {
//                        bitmap
//                    }
//
//                    val monoData = convertToMonochromeFast(scaledBitmap)
//                    scaledBitmap.recycle()
//
//                    if (monoData == null) {
//                        withContext(Dispatchers.Main) {
//                            result.error("IMAGE_PROCESS_ERROR", "Failed to convert image to monochrome data", null)
//                        }
//                        return@withLock
//                    }
//
//                    val commands = mutableListOf<Byte>()
//                    commands.addAll(listOf(GS, 0x76, 0x30, 0x00))
//
//                    val widthBytes = (monoData.width + 7) / 8
//                    commands.add((widthBytes and 0xFF).toByte())
//                    commands.add(((widthBytes shr 8) and 0xFF).toByte())
//                    commands.add((monoData.height and 0xFF).toByte())
//                    commands.add(((monoData.height shr 8) and 0xFF).toByte())
//                    commands.addAll(monoData.data.toList())
//                    commands.add(0x0A)
//
//                    writeDataSmooth(commands.toByteArray())
//
//                    // CRITICAL FIX: Add delay after image printing
//                    delay(100)
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//                } catch (e: Exception) {
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_IMAGE_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }



    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
        val commands = mutableListOf<Byte>()
        repeat(lines) {
            commands.add(0x0A.toByte())
        }
        writeDataSmooth(commands.toByteArray())
        result.success(true)
    }

    private fun cutPaper(result: MethodChannel.Result) {
        val commands = mutableListOf<Byte>()
        commands.addAll(listOf(GS, 0x56, 0x00))
        writeDataSmooth(commands.toByteArray())
        result.success(true)
    }

    private fun setPrinterWidth(width: Int, result: MethodChannel.Result) {
        printerWidth = width
        println("✅ Printer width set to $width dots.")
        result.success(true)
    }

    // MARK: - Helper Functions
    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val widthBytes = (width + 7) / 8
        val totalBytes = widthBytes * height
        val data = ByteArray(totalBytes)

        val threshold = -0x5f5f60  // This is approximately 160 in grayscale

        for (y in 0 until height) {
            val bitmapRowOffset = y * widthBytes
            for (x in 0 until width) {
                if (pixels[y * width + x] < threshold) {
                    val byteIndex = bitmapRowOffset + (x / 8)
                    val bitIndex = 7 - (x % 8)
                    data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
                }
            }
        }

        return MonochromeData(width, height, data)
    }
//    private fun convertToMonochromeFast(bitmap: Bitmap): MonochromeData? {
//        val width = bitmap.width
//        val height = bitmap.height
//        val pixels = IntArray(width * height)
//        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
//
//        val widthBytes = (width + 7) / 8
//        val totalBytes = widthBytes * height
//        val data = ByteArray(totalBytes)
//
//        val threshold = -0x5f5f60
//
//        for (y in 0 until height) {
//            val bitmapRowOffset = y * widthBytes
//            for (x in 0 until width) {
//                if (pixels[y * width + x] < threshold) {
//                    val byteIndex = bitmapRowOffset + (x / 8)
//                    val bitIndex = 7 - (x % 8)
//                    data[byteIndex] = (data[byteIndex].toInt() or (1 shl bitIndex)).toByte()
//                }
//            }
//        }
//
//        return MonochromeData(width, height, data)
//    }

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



//    private fun wrapTextToList(text: String, maxCharsPerLine: Int): List<String> {
//        if (maxCharsPerLine <= 0) return listOf(text)
//        if (text.isEmpty()) return listOf("")
//
//        val lines = mutableListOf<String>()
//        val words = text.split(" ")
//        var currentLine = StringBuilder()
//
//        for (word in words) {
//            // Handle words longer than max width
//            if (word.length > maxCharsPerLine) {
//                // Save current line if not empty
//                if (currentLine.isNotEmpty()) {
//                    lines.add(currentLine.toString())
//                    currentLine = StringBuilder()
//                }
//                // Split long word across multiple lines
//                var remainingWord = word
//                while (remainingWord.length > maxCharsPerLine) {
//                    lines.add(remainingWord.take(maxCharsPerLine))
//                    remainingWord = remainingWord.drop(maxCharsPerLine)
//                }
//                if (remainingWord.isNotEmpty()) {
//                    currentLine.append(remainingWord)
//                }
//                continue
//            }
//
//            // Check if adding this word would exceed the limit
//            val testLine = if (currentLine.isEmpty()) {
//                word
//            } else {
//                "$currentLine $word"
//            }
//
//            if (testLine.length <= maxCharsPerLine) {
//                currentLine = StringBuilder(testLine)
//            } else {
//                // Save current line and start new one
//                if (currentLine.isNotEmpty()) {
//                    lines.add(currentLine.toString())
//                }
//                currentLine = StringBuilder(word)
//            }
//        }
//
//        // Add the last line
//        if (currentLine.isNotEmpty()) {
//            lines.add(currentLine.toString())
//        }
//
//        return lines.ifEmpty { listOf("") }
//    }




    private fun getVisualWidth(text: String): Double {
        var width = 0.0
        for (char in text) {
            val code = char.code
            width += when {
                code in 0x1780..0x17FF -> 1.4  // Khmer base characters
                code in 0x17B4..0x17D3 -> 0.0  // Khmer combining marks
                else -> 1.0  // ASCII
            }
        }
        return width
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

    //=============================for multi Row=============

//    ================================================new==========================
private fun printRow(
    columns: List<Map<String, Any>>,
    fontSize: Int,
    result: MethodChannel.Result
) {
    val startTime = System.currentTimeMillis()

    scope.launch {
        printMutex.withLock {
            try {
                // Convert maps to PosColumn objects
                val posColumns = columns.map { col ->
                    PosColumn(
                        text = col["text"] as? String ?: "",
                        width = col["width"] as? Int ?: 6,
                        align = col["align"] as? String ?: "left",
                        bold = col["bold"] as? Boolean ?: false
                    )
                }

                // Validate total width
                val totalWidth = posColumns.sumOf { it.width }
                if (totalWidth > 12) {
                    withContext(Dispatchers.Main) {
                        result.error("ROW_ERROR", "Total column width exceeds 12, got $totalWidth", null)
                    }
                    return@withLock
                }

                // Check if any column contains complex unicode
                val hasComplexUnicode = posColumns.any { containsComplexUnicode(it.text) }

                if (hasComplexUnicode) {
                    println("🖼️ KOTLIN: Rendering Row with Complex text as Image")
                    val renderStart = System.currentTimeMillis()

                    val imageData = renderRowToData(posColumns, fontSize)

                    if (imageData == null || imageData.isEmpty()) {
                        withContext(Dispatchers.Main) {
                            result.error("RENDER_ERROR", "Failed to render row", null)
                        }
                        return@withLock
                    }

                    val renderTime = System.currentTimeMillis() - renderStart
                    println("✅ KOTLIN: Row rendered in ${renderTime}ms, size: ${imageData.size} bytes")

                    writeDataSmooth(imageData)
                } else {
                    // Use text method for simple ASCII text
                    printRowUsingTextMethod(posColumns, fontSize)
                }

                // Optional: Add delay if printer needs it
                // delay(50)

                withContext(Dispatchers.Main) {
                    result.success(true)
                }

                val totalTime = System.currentTimeMillis() - startTime
                println("🖨️ KOTLIN: Row printed in ${totalTime}ms")

            } catch (e: Exception) {
                println("❌ PRINT ROW ERROR: ${e.message}")
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    result.error("PRINT_ROW_ERROR", e.message, null)
                }
            }
        }
    }
}

    // ===== SIMPLE TEXT ROW (ASCII/CP437) =====
    private fun printRowUsingTextMethod(
        columns: List<PosColumn>,
        fontSize: Int
    ) {
        println("🔵 KOTLIN: Printing row with ${columns.size} columns (Simple text)")

        val totalChars = when {
            fontSize > 30 -> 24
            fontSize > 24 -> 32
            else -> 48
        }

        // Prepare all column lines with word wrapping
        val columnTextLists = columns.map { column ->
            val maxCharsPerColumn = (totalChars * column.width) / 12
            val lines = wrapTextToList(column.text, maxCharsPerColumn)
            Triple(lines, maxCharsPerColumn, column.align)
        }

        val maxLines = columnTextLists.maxOfOrNull { it.first.size } ?: 1

        val commands = mutableListOf<Byte>()

        // Initialize printer
        commands.addAll(listOf(ESC, 0x40))
        commands.addAll(listOf(ESC, 0x74, 0x01))

        // Font size
        val sizeCommand: Byte = when {
            fontSize > 30 -> 0x30.toByte()
            fontSize > 24 -> 0x11.toByte()
            else -> 0x00.toByte()
        }
        commands.addAll(listOf(ESC, 0x21, sizeCommand))


        //  INCREASED LINE SPACING for more vertical height
        commands.addAll(listOf(ESC, 0x33, 0x20))
        // Bold if needed
        val hasBold = columns.any { it.bold }
        if (hasBold) {
            commands.addAll(listOf(ESC, 0x45, 0x01))
        }

        // Left align
        commands.addAll(listOf(ESC, 0x61, 0x00))

        // Print all lines
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
        commands.add(0x0A.toByte())
//        // Reset line spacing
//        commands.addAll(listOf(ESC, 0x33, 0x30)) // Reset to default (48/180 inch)

        // Reset bold
        if (hasBold) {
            commands.addAll(listOf(ESC, 0x45, 0x00))
        }

        // Reset alignment
        commands.addAll(listOf(ESC, 0x61, 0x00))

        writeDataSmooth(commands.toByteArray())
    }

    private fun formatColumnText(text: String, width: Int, align: String): String {
        // Handle exact match or overflow
        if (text.length == width) return text
        if (text.length > width) return text.take(width)

        // Padding logic
        return when (align.lowercase()) {
            "center" -> {
                val totalPadding = width - text.length
                val leftPadding = totalPadding / 2
                text.padStart(text.length + leftPadding).padEnd(width)
            }
            "right" -> text.padStart(width)
            else -> text.padEnd(width) // Default is left
        }
    }

    // ===== OPTIMIZED IMAGE ROW RENDERER =====
    private fun renderRowToData(
        columns: List<PosColumn>,
        fontSize: Int
    ): ByteArray? {
        try {
            // OPTIMIZATION 1: Use cached typefaces with proper bold support
            val baseFontSize = 24f // Reduced for smaller output
            val scaledFontSize = when {
                fontSize > 30 -> baseFontSize * 2.0f
                fontSize > 24 -> baseFontSize * 1.5f
                else -> baseFontSize
            }

            println("📏 KOTLIN: Row fontSize=$fontSize -> scaledFontSize=$scaledFontSize")

            val maxWidth = printerWidth.toFloat()
            val columnWidths = columns.map { (maxWidth * it.width) / 12 }

            // Calculate total chars per row based on font size
            val totalChars = when {
                fontSize > 30 -> 20
                fontSize > 24 -> 28
                else -> 42
            }

            // Calculate max lines needed
            var maxLines = 1
            for (column in columns) {
                val colChars = (totalChars * column.width) / 12
                val lineCount = (column.text.length + colChars - 1) / colChars
                if (lineCount > maxLines) maxLines = lineCount
            }

            // OPTIMIZATION 2: Create paint once with base settings
            val basePaint = Paint().apply {
                textSize = scaledFontSize
                isAntiAlias = false // OPTIMIZATION: Sharper for monochrome
                color = Color.BLACK
                style = Paint.Style.FILL // OPTIMIZATION: FILL only
                strokeWidth = 0f
            }

            // Calculate line height
            val metrics = basePaint.fontMetrics
            val lineHeight = (metrics.descent - metrics.ascent) * 0.90f // Tighter spacing

            // OPTIMIZATION 3: Minimal padding
            val verticalPadding = 4f
            val totalHeight = (lineHeight * maxLines + verticalPadding * 2).toInt()

            val bitmap = Bitmap.createBitmap(
                printerWidth,
                totalHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)

            var currentX = 0f
            for (i in columns.indices) {
                val column = columns[i]
                val colWidth = columnWidths[i]
                val colChars = (totalChars * column.width) / 12

                // Word wrap for this column
                val lines = mutableListOf<String>()
                var remaining = column.text
                while (remaining.length > colChars) {
                    lines.add(remaining.take(colChars))
                    remaining = remaining.drop(colChars)
                }
                if (remaining.isNotEmpty()) lines.add(remaining)

                // OPTIMIZATION 4: Get appropriate typeface from cache
                val columnTypeface = getKhmerTypeface(column.bold)

                // Configure paint for this column
                basePaint.apply {
                    typeface = columnTypeface
                    isFakeBoldText = false // Don't fake bold - use real fonts
                    textAlign = when (column.align.lowercase()) {
                        "center" -> Paint.Align.CENTER
                        "right" -> Paint.Align.RIGHT
                        else -> Paint.Align.LEFT
                    }
                }

                // Draw each line
                for (lineIndex in lines.indices) {
                    val line = lines[lineIndex]

                    if (line.isBlank()) continue

                    val x = when (column.align.lowercase()) {
                        "center" -> currentX + colWidth / 2
                        "right" -> currentX + colWidth
                        else -> currentX
                    }

                    val y = verticalPadding - metrics.ascent + (lineHeight * lineIndex)
                    canvas.drawText(line, x, y, basePaint)
                }

                currentX += colWidth
            }

            val monoData = convertToMonochromeFast(bitmap)
            bitmap.recycle()

            if (monoData == null) {
                println("❌ Failed to convert row bitmap to monochrome")
                return null
            }

            // OPTIMIZATION 5: Pre-allocate exact size
            val widthBytes = (monoData.width + 7) / 8
            val commandSize = 8 + monoData.data.size
            val commands = ByteArray(commandSize)

            var idx = 0
            // ESC/POS raster image command: GS v 0
            commands[idx++] = GS
            commands[idx++] = 0x76
            commands[idx++] = 0x30
            commands[idx++] = 0x00

            // Width in bytes (little-endian)
            commands[idx++] = (widthBytes and 0xFF).toByte()
            commands[idx++] = ((widthBytes shr 8) and 0xFF).toByte()

            // Height (little-endian)
            commands[idx++] = (monoData.height and 0xFF).toByte()
            commands[idx++] = ((monoData.height shr 8) and 0xFF).toByte()

            // OPTIMIZATION 6: Use System.arraycopy
            System.arraycopy(monoData.data, 0, commands, idx, monoData.data.size)

            return commands

        } catch (e: Exception) {
            println("❌ ROW RENDER ERROR: ${e.message}")
            e.printStackTrace()
            return null
        }
    }

    // Helper function for word wrapping (if not already defined)
    private fun wrapTextToList(text: String, maxCharsPerLine: Int): List<String> {
        if (maxCharsPerLine <= 0) return listOf(text)

        val lines = mutableListOf<String>()
        var remaining = text

        while (remaining.length > maxCharsPerLine) {
            // Try to break at word boundary
            var breakIndex = maxCharsPerLine
            val lastSpace = remaining.substring(0, maxCharsPerLine).lastIndexOf(' ')

            if (lastSpace > maxCharsPerLine / 2) {
                breakIndex = lastSpace
            }

            lines.add(remaining.substring(0, breakIndex).trim())
            remaining = remaining.substring(breakIndex).trim()
        }

        if (remaining.isNotEmpty()) {
            lines.add(remaining)
        }

        return lines
    }
//===========================================================old=======================
    // Add this new function to print a row with multiple columns
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
//                    // ✅ Convert maps to PosColumn objects
//                    val posColumns = columns.map { col ->
//                        PosColumn(
//                            text = col["text"] as? String ?: "",
//                            width = col["width"] as? Int ?: 6,
//                            align = col["align"] as? String ?: "left",
//                            bold = col["bold"] as? Boolean ?: false
//                        )
//                    }
//
//                    // Calculate total width
//                    val totalWidth = posColumns.sumOf { it.width }
//                    if (totalWidth > 12) {
//                        withContext(Dispatchers.Main) {
//                            result.error("ROW_ERROR", "Total column width exceeds 12, got $totalWidth", null)
//                        }
//                        return@withLock
//                    }
//
//                    // Check if any column contains complex unicode
//                    val hasComplexUnicode = posColumns.any { containsComplexUnicode(it.text) }
//
//                    if (hasComplexUnicode) {
//                        println("🔵 KOTLIN: Rendering Row with Complex text as Image")
//                        val imageData = renderRowToData(posColumns, fontSize)
//
//                        if (imageData == null || imageData.isEmpty()) {
//                            withContext(Dispatchers.Main) {
//                                result.error("RENDER_ERROR", "Failed to render row", null)
//                            }
//                            return@withLock
//                        }
//
////                        val alignLeftCommand = byteArrayOf(ESC, 0x61.toByte(), 0x00.toByte())
////                        val finalData = alignLeftCommand + imageData
//
//                        writeDataSmooth(imageData)
//                    } else {
//                        // Use printText logic for simple text
//                        printRowUsingTextMethod(posColumns, fontSize)
//                    }
//
//                    delay(50)
//
//                    withContext(Dispatchers.Main) {
//                        result.success(true)
//                    }
//
//                    val totalTime = System.currentTimeMillis() - startTime
//                    println("✅ KOTLIN: Row printed in ${totalTime}ms")
//
//                } catch (e: Exception) {
//                    withContext(Dispatchers.Main) {
//                        result.error("PRINT_ROW_ERROR", e.message, null)
//                    }
//                }
//            }
//        }
//    }
//
//
//
//    private fun printRowUsingTextMethod(
//        columns: List<PosColumn>,
//        fontSize: Int
//    ) {
//        println("🔵 KOTLIN: Printing row with ${columns.size} columns")
//
//        val totalChars = when {
//            fontSize > 30 -> 24
//            fontSize > 24 -> 32
//            else -> 48
//        }
//
//        // Prepare all column lines with word wrapping
//        val columnTextLists = columns.map { column ->
//            val maxCharsPerColumn = (totalChars * column.width) / 12
//
//            // ✅ Use word wrapping for better text handling
//            val lines = wrapTextToList(column.text, maxCharsPerColumn)
//
//            Triple(lines, maxCharsPerColumn, column.align)
//        }
//
//        val maxLines = columnTextLists.maxOfOrNull { it.first.size } ?: 1
//
//        val commands = mutableListOf<Byte>()
//
//        // Init once
//        commands.add(ESC)
//        commands.add(0x40)
//        commands.add(ESC)
//        commands.add(0x74)
//        commands.add(0x01)
//
//        // Font size
//        val sizeCommand: Byte = when {
//            fontSize > 30 -> 0x30.toByte()
//            fontSize > 24 -> 0x11.toByte()
//            else -> 0x00.toByte()
//        }
//        commands.add(ESC)
//        commands.add(0x21)
//        commands.add(sizeCommand)
//
//
//        commands.add(ESC)
//        commands.add(0x33)
//        commands.add(0x10)  // 16/180 inch spacing
//
//        // Bold if needed
//        val hasBold = columns.any { it.bold }
//        if (hasBold) {
//            commands.add(ESC)
//            commands.add(0x45)
//            commands.add(0x01)
//        }
//
//        // Left align
//        commands.add(ESC)
//        commands.add(0x61)
//        commands.add(0x00)
//
//        // Print all lines
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
//
//        commands.add(ESC)
//        commands.add(0x33)
//        commands.add(0x30)  // Reset to default (48/180 inch)
//
//        if (hasBold) {
//            commands.add(ESC)
//            commands.add(0x45)
//            commands.add(0x00)
//        }
//
//        commands.add(ESC)
//        commands.add(0x61)
//        commands.add(0x00)
//
//        writeDataSmooth(commands.toByteArray())
//    }
//
//    private fun formatColumnText(text: String, width: Int, align: String): String {
//        // 1. Handle Exact Match or Overflow
//        if (text.length == width) return text
//        if (text.length > width) return text.take(width)
//
//        // 2. Padding Logic
//        return when (align.lowercase()) {
//            "center" -> {
//                val totalPadding = width - text.length
//                val leftPadding = totalPadding / 2
//                text.padStart(text.length + leftPadding).padEnd(width)
//            }
//            "right" -> {
//                text.padStart(width)
//            }
//            else -> { // Default is "left"
//                text.padEnd(width)
//            }
//        }
//    }
//
//    private fun renderRowToData(
//        columns: List<PosColumn>,
//        fontSize: Int
//    ): ByteArray? {
//        try {
//            val baseFontSize = 24f
//            val scaledFontSize = when {
//                fontSize > 30 -> baseFontSize * 2.0f
//                fontSize > 24 -> baseFontSize * 1.5f
//                else -> baseFontSize
//            }
//
//            val khmerTypeface = try {
//                val assetManager = context.assets
//                Typeface.createFromAsset(assetManager, "fonts/NotoSansKhmer-Regular.ttf")
//            } catch (e: Exception) {
//                println("❌ Failed to load Khmer font: $e")
//                Typeface.DEFAULT
//            }
//
//            val maxWidth = printerWidth.toFloat()
//            val columnWidths = columns.map { (maxWidth * it.width) / 12 }
//
//            val paint = Paint().apply {
//                textSize = scaledFontSize
//                typeface = khmerTypeface
//                isAntiAlias = true
//                color = Color.BLACK
//            }
//
//            val metrics = paint.fontMetrics
//            val lineHeight = metrics.descent - metrics.ascent
//
//            val totalChars = when {
//                fontSize > 30 -> 24
//                fontSize > 24 -> 32
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
//            // ✅ Minimal padding (1px top + 1px bottom)
//            val verticalPadding = 1f
//            val totalHeight = (lineHeight * maxLines + verticalPadding * 2).toInt()
//
//            val bitmap = Bitmap.createBitmap(printerWidth, totalHeight, Bitmap.Config.ARGB_8888)
//            val canvas = Canvas(bitmap)
//            canvas.drawColor(Color.WHITE)
//
//            var currentX = 0f
//            for (i in columns.indices) {
//                val column = columns[i]
//                val colWidth = columnWidths[i]
//                val colChars = (totalChars * column.width) / 12
//
//                val lines = mutableListOf<String>()
//                var remaining = column.text
//                while (remaining.length > colChars) {
//                    lines.add(remaining.take(colChars))
//                    remaining = remaining.drop(colChars)
//                }
//                if (remaining.isNotEmpty()) lines.add(remaining)
//
//                paint.apply {
//                    isFakeBoldText = column.bold
//                    strokeWidth = if (column.bold) 1.2f else 0.8f
//                    style = Paint.Style.FILL_AND_STROKE
//                    textAlign = when (column.align.lowercase()) {
//                        "center" -> Paint.Align.CENTER
//                        "right" -> Paint.Align.RIGHT
//                        else -> Paint.Align.LEFT
//                    }
//                }
//
//                for (lineIndex in lines.indices) {
//                    val line = lines[lineIndex]
//
//                    val x = when (column.align.lowercase()) {
//                        "center" -> currentX + colWidth / 2
//                        "right" -> currentX + colWidth
//                        else -> currentX
//                    }
//
//                    // ✅ Minimal vertical padding
//                    val y = verticalPadding - metrics.ascent + (lineHeight * lineIndex)
//                    canvas.drawText(line, x, y, paint)
//                }
//
//                currentX += colWidth
//            }
//
//            val monoData = convertToMonochromeFast(bitmap)
//            bitmap.recycle()
//
//            if (monoData == null) return null
//
//            val commands = mutableListOf<Byte>()
//            commands.addAll(listOf(GS, 0x76, 0x30, 0x00))
//
//            val widthBytes = (monoData.width + 7) / 8
//            commands.add((widthBytes and 0xFF).toByte())
//            commands.add(((widthBytes shr 8) and 0xFF).toByte())
//            commands.add((monoData.height and 0xFF).toByte())
//            commands.add(((monoData.height shr 8) and 0xFF).toByte())
//
//            commands.addAll(monoData.data.toList())
//            commands.add(0x0A)
//
//            return commands.toByteArray()
//        } catch (e: Exception) {
//            println("❌ ROW RENDER ERROR: $e")
//            return null
//        }
//    }
}
