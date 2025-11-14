import Foundation
import Flutter
import CoreBluetooth
import UIKit  // Added for image rendering
import WebKit  // Optional: For future full HTML rendering; not used yet

@objc class BluetoothPrinterPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    private var centralManager: CBCentralManager?
    private var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var connectResultCallback: FlutterResult?
    
    // MARK: - FlutterPlugin Protocol
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BluetoothPrinterPlugin()
        let messenger = registrar.messenger()
        instance.setup(with: messenger)
    }
    
    // MARK: - Setup
    private func setup(with binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.clearviewerp.salesforce/bluetoothprinter",
            binaryMessenger: binaryMessenger
        )
        
        // Direct reference to public handle func (syntactic sugar)
        methodChannel?.setMethodCallHandler(handle)
        
        // Initialize Bluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        print("Init BluetoothPrinterHandler")
    }
    
    // MARK: - Method Call Handler (Public for direct reference)
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scanDevices":
            scanDevices(result: result)
            
        case "connectDevice":
            if let args = call.arguments as? [String: Any],
               let address = args["address"] as? String {
                connectDevice(address: address, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Address is required",
                    details: nil
                ))
            }
            
        case "printText":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String {
                printText(text: text, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Text is required",
                    details: nil
                ))
            }
        case "printRaw":
            if let args = call.arguments as? [String: Any],
               let rawBytes = args["rawBytes"] as? FlutterStandardTypedData {
                printRaw(rawBytes.data, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Raw bytes required",
                    details: nil
                ))
            }
        case "disconnect":
            disconnect(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Bluetooth Operations
    private func scanDevices(result: @escaping FlutterResult) {
        
        print("Bluetooth scanDevices....");
        
        discoveredPeripherals.removeAll()
        
        guard let centralManager = centralManager else {
            result(FlutterError(
                code: "BLUETOOTH_ERROR",
                message: "Bluetooth manager not initialized",
                details: nil
            ))
            
            print("BLUETOOTH_ERROR - Bluetooth manager not initialized");
            return
        }
        
        // Check Bluetooth state
        if centralManager.state != .poweredOn {
            result(FlutterError(
                code: "BLUETOOTH_ERROR",
                message: "Bluetooth is not available or turned off",
                details: nil
            ))
            
            print("BLUETOOTH_ERROR - Bluetooth is not available or turned off");
            return
        }
        
        // Start scanning
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
        
        result(true)
    }
    
    private func connectDevice(address: String, result: @escaping FlutterResult) {
        // Stop scanning
        centralManager?.stopScan()
        
        // Find peripheral by identifier or name
        let peripheral = discoveredPeripherals.first { p in
            p.identifier.uuidString == address || p.name == address
        }
        
        guard let peripheral = peripheral else {
            result(FlutterError(
                code: "DEVICE_NOT_FOUND",
                message: "Device not found in discovered list",
                details: nil
            ))
            return
        }
        
        // Store the result callback
        connectResultCallback = result
        
        // Connect to peripheral
        connectedPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
        
        // Set a timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self else { return }
            
            if self.connectedPeripheral?.state != .connected {
                self.connectResultCallback?(FlutterError(
                    code: "CONNECTION_TIMEOUT",
                    message: "Failed to connect to device within timeout",
                    details: nil
                ))
                self.connectResultCallback = nil
            }
        }
    }
    
    private func printText(text: String, result: @escaping FlutterResult) {
        
        print("Text to print: \(text)")
        
        guard let peripheral = connectedPeripheral,
              peripheral.state == .connected else {
            result(FlutterError(
                code: "NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        
        guard let characteristic = writeCharacteristic else {
            result(FlutterError(
                code: "NO_CHARACTERISTIC",
                message: "Write characteristic not found",
                details: nil
            ))
            return
        }
        
        // Build print data with ESC/POS commands
        var data = Data()
        
        // Initialize printer
        data.append(contentsOf: [0x1B, 0x40])
        
        // Set font A, normal size (ESC ! 0)
        data.append(contentsOf: [0x1B, 0x21, 0x00])
        
        // Add text as UTF-8
        if let textData = text.data(using: .utf8) {
            data.append(textData)
        }
        
        // Reduced footer: Single LF only, no extra feed
        data.append(0x0A)  // Line feed
        
        // Cut paper immediately
        data.append(contentsOf: [0x1D, 0x56, 0x42, 0x00])  // Partial cut
        
        print("📄 Sending print data (\(data.count) bytes)")  // Debug log
        
        // Write data
        if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
        
        result(true)
    }
    
    private func printRaw(_ rawData: Data, result: @escaping FlutterResult) {
        guard let peripheral = connectedPeripheral,
              peripheral.state == .connected,
              let characteristic = writeCharacteristic else {
            result(FlutterError(
                code: "NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        
        var printData = Data([0x1B, 0x40])  // ESC @ init printer
        printData.append(rawData)
        printData.append(0x0A)  // Line feed
        printData.append(contentsOf: [0x1D, 0x56, 0x42, 0x00])  // Partial cut
        
        print("📄 Sending raw print data (\(printData.count) bytes)")
        
        if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(printData, for: characteristic, type: .withoutResponse)
        } else {
            peripheral.writeValue(printData, for: characteristic, type: .withResponse)
        }
        
        result(true)
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        connectedPeripheral = nil
        writeCharacteristic = nil
        connectResultCallback = nil
        
        result(true)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is not supported on this device")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        // Avoid duplicates
        if discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            return
        }
        
        if(peripheral.name == nil) {
            return;
        }
        
        discoveredPeripherals.append(peripheral)
        
        let deviceInfo: [String: String] = [
            "code" : "OK",
            "name": peripheral.name ?? "Unknown Device",
            "address": peripheral.identifier.uuidString
        ]
        
        methodChannel?.invokeMethod("onDeviceFound", arguments: deviceInfo)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        // Don't call result here yet - wait for characteristic discovery
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        
        connectResultCallback?(FlutterError(
            code: "CONNECTION_FAILED",
            message: error?.localizedDescription ?? "Failed to connect",
            details: nil
        ))
        connectResultCallback = nil
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("🔌 Disconnected from \(peripheral.name ?? "Unknown")")
        
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
            writeCharacteristic = nil
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        
        print("📡 Found \(services.count) services")
        
        for service in services {
            print("  Service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        print("📝 Found \(characteristics.count) characteristics for service \(service.uuid)")
        
        // Find writable characteristic
        for characteristic in characteristics {
            print("  Characteristic: \(characteristic.uuid)")
            print("    Properties: \(characteristic.properties)")
            
            if characteristic.properties.contains(.write) ||
               characteristic.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = characteristic
                print("✅ Found write characteristic: \(characteristic.uuid)")
                
                // Now we can report successful connection
                if let callback = connectResultCallback {
                    callback(true)
                    connectResultCallback = nil
                }
                
                break
            }
        }
        
        // If we've checked all services and still no write characteristic
        if writeCharacteristic == nil &&
           peripheral.services?.allSatisfy({ $0.characteristics != nil }) == true {
            connectResultCallback?(FlutterError(
                code: "NO_WRITE_CHARACTERISTIC",
                message: "Could not find a writable characteristic on this device",
                details: nil
            ))
            connectResultCallback = nil
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("❌ Write error: \(error.localizedDescription)")
        } else {
            print("✅ Data written successfully to \(characteristic.uuid)")
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("❌ Update error: \(error.localizedDescription)")
        }
    }
}
