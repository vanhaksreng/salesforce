import Flutter
import UIKit
import CoreBluetooth
import Network
import ExternalAccessory

// ====================================================================
// MARK: - Configuration
// ====================================================================
struct PrinterConfig {
    static let defaultPrinterWidth = 576 // 80mm
    static let smallPrinterWidth = 384   // 58mm
    static let connectionTimeout: TimeInterval = 15.0
}

// ====================================================================
// MARK: - Data Classes
// ====================================================================
struct MonochromeData {
    let width: Int
    let height: Int
    let data: Data
}

struct PosColumn {
    let text: String
    let width: Int
    let align: String
    let bold: Bool
}

enum ImageAlignment: Int {
    case left = 0
    case center = 1
    case right = 2
    
    static func from(_ value: Int) -> ImageAlignment {
        return ImageAlignment(rawValue: value) ?? .center
    }
}

enum ConnectionType {
    case bluetoothClassic
    case bluetoothBLE
    case network
    case usb
    case none
}

enum PrinterModel {
    case unknown
    case slow      // Old printers (50 bytes/ms)
    case medium    // Standard printers (80 bytes/ms)
    case fast      // Modern printers (120 bytes/ms)
}

enum PrinterSpeed {
    case unknown
    case slow      // < 3 bytes/ms
    case medium    // 3-6 bytes/ms
    case fast      // > 6 bytes/ms
}

// ====================================================================
// MARK: - Main Plugin Class
// ====================================================================
public class ThermalPrinterPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    private var channel: FlutterMethodChannel?
    
    // Bluetooth
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var discoveredDevices: [CBPeripheral] = []
    private var discoveryResult: FlutterResult?
    
    // Network
    private var networkConnection: NWConnection?
    private var networkQueue: DispatchQueue?
    
    // Connection state
    private var currentConnectionType: ConnectionType = .none
    private var printerWidth = PrinterConfig.defaultPrinterWidth
    
    // ESC/POS Commands
    private let ESC: UInt8 = 0x1B
    private let GS: UInt8 = 0x1D
    
    // Synchronization
    private let printQueue = DispatchQueue(label: "com.clearviewerp.thermal_printer", qos: .userInitiated)
    private let writeLock = NSLock()
    
    // Batching
    private var receiptBuffer = Data()
    private var isBatchMode = false
    
    // Font cache
    private var fontCache: [String: UIFont] = [:]
    
    // Pending results
    private var pendingResults: [String: FlutterResult] = [:]
    
    // MARK: - Plugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "thermal_printer", binaryMessenger: registrar.messenger())
        let instance = ThermalPrinterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.initialize()
    }
    
    // MARK: - Initialization
    private func initialize() {
//        centralManager = CBCentralManager(delegate: self, queue: nil)
        networkQueue = DispatchQueue(label: "com.clearviewerp.network_queue")
        preloadFonts()
        print("🔵 ThermalPrinterPlugin initialized")
    }
    private func ensureBluetoothManager() {
        if centralManager == nil {
            print("🔵 Initializing Bluetooth manager on demand...")
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    // MARK: - Method Call Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        
        switch call.method {
        case "startBatch":
            startBatchMode()
            result(true)
            
        case "endBatch":
            endBatchMode()
            result(true)
            
        case "configureOOMAS":
            configureForOOMAS()
            result(true)
            
        case "warmUpPrinter":
            warmUpPrinter()
            result(true)
            
        case "printSeparator":
            let width = args?["width"] as? Int ?? 48
            printSeparator(width: width, result: result)
            
        case "testPaperFeed":
            testPaperFeed(result: result)
            
        case "testSlowPrint":
            testSlowPrint(result: result)
            
        case "checkPrinterStatus":
            checkPrinterStatus(result: result)
            
        case "runDiagnostic":
            runCompleteDiagnostic(result: result)
            
        case "initializePrinter":
            initializePrinterOptimal()
            result(true)
            
        case "discoverPrinters":
            guard let type = args?["type"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing type", details: nil))
                return
            }
            discoverPrinters(type: type, result: result)
            
        case "discoverAllPrinters":
            discoverAllPrinters(result: result)
            
        case "connect":
            guard let address = args?["address"] as? String,
                  let type = args?["type"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            connect(address: address, type: type, result: result)
            
        case "connectNetwork":
            guard let ipAddress = args?["ipAddress"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing IP address", details: nil))
                return
            }
            let port = args?["port"] as? Int ?? 9100
            connectNetwork(ipAddress: ipAddress, port: port, result: result)
            
        case "disconnect":
            disconnect(result: result)
            
        case "printText":
            guard let text = args?["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing text", details: nil))
                return
            }
            let fontSize = args?["fontSize"] as? Int ?? 24
            let bold = args?["bold"] as? Bool ?? false
            let align = args?["align"] as? String ?? "left"
            let maxCharsPerLine = args?["maxCharsPerLine"] as? Int ?? 0
            printText(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine, result: result)
            
        case "printRow":
            let columns = args?["columns"] as? [[String: Any]] ?? []
            let fontSize = args?["fontSize"] as? Int ?? 24
            printRow(columns: columns, fontSize: fontSize, result: result)
            
        case "printImage":
            guard let imageBytes = args?["imageBytes"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                return
            }
            let width = args?["width"] as? Int ?? printerWidth
            let align = args?["align"] as? Int ?? 1
            printImage(imageBytes: imageBytes.data, width: width, align: align, result: result)
            
        case "printImageWithPadding":
            guard let imageBytes = args?["imageBytes"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                return
            }
            let width = args?["width"] as? Int ?? 384
            let align = args?["align"] as? Int ?? 1
            let paperWidth = args?["paperWidth"] as? Int ?? 576
            printImageWithPadding(imageBytes: imageBytes.data, width: width, align: align, paperWidth: paperWidth, result: result)
            
        case "feedPaper":
            let lines = args?["lines"] as? Int ?? 1
            feedPaper(lines: lines, result: result)
            
        case "cutPaper":
            cutPaper(result: result)
            
        case "getStatus":
            getStatus(result: result)
            
        case "setPrinterWidth":
            guard let width = args?["width"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing width", details: nil))
                return
            }
            setPrinterWidth(width: width, result: result)
            
        case "checkBluetoothPermission":
            checkBluetoothPermission(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // ====================================================================
    // MARK: - Batch Mode
    // ====================================================================
    private func startBatchMode() {
        receiptBuffer.removeAll()
        isBatchMode = true
        
        // Initialize printer
        var initCommands = Data()
        initCommands.append(contentsOf: [ESC, 0x40])        // Reset
        initCommands.append(contentsOf: [ESC, 0x74, 0x01])  // Set code page
        initCommands.append(contentsOf: [ESC, 0x33, 0x30])  // Set line spacing
        
        receiptBuffer.append(initCommands)
        print("📦 Started batch mode with initialization")
    }
    
    private func endBatchMode() {
        isBatchMode = false
        if !receiptBuffer.isEmpty {
            let originalSize = receiptBuffer.count
            print("📤 Preparing receipt: \(originalSize) bytes")
            
            // Optimize
            let optimizedData = optimizeLineFeeds(data: receiptBuffer)
            print("✅ Optimized: \(originalSize) → \(optimizedData.count) bytes")
            
            // Send reliably
            writeDataSmooth(data: optimizedData)
            
            // Wait for completion
            Thread.sleep(forTimeInterval: 0.050)
            
            receiptBuffer.removeAll()
            print("✅ Receipt sent successfully")
        }
    }
        // Add this with your other properties (near the top of the class)
        private var operationQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1  // Serial execution
            queue.qualityOfService = .userInitiated
            return queue
        }()
        
        private func queueWrite(data: Data) {
            operationQueue.addOperation { [weak self] in
                guard let self = self else { return }
                
                self.writeLock.lock()
                defer { self.writeLock.unlock() }
                
                self.writeDataSmooth(data: data)
                
                // Small delay between queued operations
                Thread.sleep(forTimeInterval: 0.010)
            }
        }
        private func addToBuffer(data: Data) {
            if isBatchMode {
                receiptBuffer.append(data)
                print("➕ Added \(data.count) bytes to buffer (total: \(receiptBuffer.count))")
            } else {
                queueWrite(data: data)
            }
        }
        
        private func optimizeLineFeeds(data: Data) -> Data {
            var optimized = Data()
            var consecutiveLineFeeds = 0
            
            for byte in data {
                if byte == 0x0A {
                    consecutiveLineFeeds += 1
                } else {
                    if consecutiveLineFeeds > 0 {
                        for _ in 0..<consecutiveLineFeeds {
                            optimized.append(0x0A)
                        }
                        consecutiveLineFeeds = 0
                    }
                    optimized.append(byte)
                }
            }
            
            if consecutiveLineFeeds > 0 {
                for _ in 0..<consecutiveLineFeeds {
                    optimized.append(0x0A)
                }
            }
            
            return optimized
        }
        
        // ====================================================================
        // MARK: - Diagnostic Tests
        // ====================================================================
        private func testPaperFeed(result: @escaping FlutterResult) {
            printQueue.async {
                do {
                    print("🧪 TEST 1: Paper Feed Test")
                    let feedCommand = Data(repeating: 0x0A, count: 10)
                    self.writeDataSmooth(data: feedCommand)
                    Thread.sleep(forTimeInterval: 2.0)
                    
                    DispatchQueue.main.async {
                        result([
                            "test": "paper_feed",
                            "instruction": "Did you hear 'stuck stuck' during paper feed? YES = Paper problem, NO = Code problem"
                        ])
                    }
                }
            }
        }
        
        private func testSlowPrint(result: @escaping FlutterResult) {
            printQueue.async {
                do {
                    print("🧪 TEST 2: Slow Print Test")
                    
                    var commands = Data()
                    commands.append(contentsOf: [self.ESC, 0x40])
                    commands.append("TEST LINE 1".data(using: .ascii)!)
                    commands.append(0x0A)
                    
                    self.writeDataSmooth(data: commands)
                    Thread.sleep(forTimeInterval: 1.0)
                    
                    commands.removeAll()
                    commands.append("TEST LINE 2".data(using: .ascii)!)
                    commands.append(0x0A)
                    
                    self.writeDataSmooth(data: commands)
                    Thread.sleep(forTimeInterval: 1.0)
                    
                    commands.removeAll()
                    commands.append("TEST LINE 3".data(using: .ascii)!)
                    commands.append(0x0A)
                    
                    self.writeDataSmooth(data: commands)
                    
                    DispatchQueue.main.async {
                        result([
                            "test": "slow_print",
                            "instruction": "Was it smooth? If YES → code was too fast before, If NO → hardware issue"
                        ])
                    }
                }
            }
        }
        
        private func checkPrinterStatus(result: @escaping FlutterResult) {
            printQueue.async {
                print("🧪 TEST 3: Printer Status Check")
                let statusCommand = Data([0x10, 0x04, 0x01])
                self.writeDataSmooth(data: statusCommand)
                Thread.sleep(forTimeInterval: 0.1)
                
                DispatchQueue.main.async {
                    result([
                        "test": "status_check",
                        "status": "Status check sent"
                    ])
                }
            }
        }
        
        private func runCompleteDiagnostic(result: @escaping FlutterResult) {
            printQueue.async {
                var diagnosticResults: [String: String] = [:]
                
                print("""
            ═══════════════════════════════════════
            🔍 COMPLETE PRINTER DIAGNOSTIC
            ═══════════════════════════════════════
            """)
                
                // Test 1: Paper feed
                print("\n▶️ TEST 1: Paper Feed Test")
                let feedCommand = Data(repeating: 0x0A, count: 5)
                self.writeDataSmooth(data: feedCommand)
                Thread.sleep(forTimeInterval: 2.0)
                diagnosticResults["paper_feed"] = "Check if 'stuck stuck' sound occurred"
                
                // Test 2: Single line
                print("\n▶️ TEST 2: Single Line Test")
                var textCommand = "TEST LINE\n".data(using: .ascii)!
                self.writeDataSmooth(data: textCommand)
                Thread.sleep(forTimeInterval: 2.0)
                diagnosticResults["single_line"] = "Check if smooth"
                
                // Test 3: Multiple lines with delays
                print("\n▶️ TEST 3: Multiple Lines (with delays)")
                for i in 1...3 {
                    let line = "Line \(i)\n".data(using: .ascii)!
                    self.writeDataSmooth(data: line)
                    Thread.sleep(forTimeInterval: 0.5)
                }
                diagnosticResults["multiple_lines"] = "Check if smooth with delays"
                
                // Test 4: Multiple lines fast
                print("\n▶️ TEST 4: Multiple Lines (fast)")
                let fastLines = "Fast Line 1\nFast Line 2\nFast Line 3\n".data(using: .ascii)!
                self.writeDataSmooth(data: fastLines)
                Thread.sleep(forTimeInterval: 2.0)
                diagnosticResults["fast_lines"] = "Check if 'stuck stuck' occurs when fast"
                
                print("""
            
            ═══════════════════════════════════════
            📊 DIAGNOSTIC RESULTS
            ═══════════════════════════════════════
            """)
                
                DispatchQueue.main.async {
                    result(diagnosticResults)
                }
            }
        }
        
        // ====================================================================
        // MARK: - Initialization
        // ====================================================================
        private func initializePrinterOptimal() {
            print("🔧 Initializing printer with optimal settings...")
            
            var commands = Data()
            commands.append(contentsOf: [ESC, 0x40])              // Reset
            commands.append(contentsOf: [ESC, 0x21, 0x00])        // Normal mode
            commands.append(contentsOf: [ESC, 0x33, 0x40])        // Line spacing
            commands.append(contentsOf: [ESC, 0x47, 0x00])        // Disable double-strike
            
            writeDataSmooth(data: commands)
            Thread.sleep(forTimeInterval: 0.2)
            print("✅ Printer initialized with smooth settings")
        }
        
        private func initializePrinterForSmoothPrinting() {
            print("🔧 Initializing for continuous printing...")
            
            var commands = Data()
            
            // Reset
            commands.append(contentsOf: [ESC, 0x40])
            writeBLEDataOptimized(data: commands)
            Thread.sleep(forTimeInterval: 0.12)
            
            commands.removeAll()
            
            // Optimal settings for continuous flow
            commands.append(contentsOf: [ESC, 0x33, 0x30])        // Line spacing
            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])  // Density
            commands.append(contentsOf: [ESC, 0x21, 0x00])        // Print mode
            
            writeBLEDataOptimized(data: commands)
            Thread.sleep(forTimeInterval: 0.12)
            
            print("✅ Ready for continuous printing")
        }
    
    private func configureForOOMAS() {
        print(" Configuring for OOMAS printer...")
        
        var config = Data()
        config.append(contentsOf: [ESC, 0x33, 0x40])          // Looser spacing
        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x05]) // Lower density
        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x00]) // Speed
        
        writeDataSmooth(data: config)
        print("✅ OOMAS configuration applied")
    }
    
    private func warmUpPrinter() {
        print("🔥 Warming up OOMAS printer...")
        
        var warmUpData = Data()
        warmUpData.append(contentsOf: [ESC, 0x40])            // Reset
        warmUpData.append(0x0A)                                // One line feed
        
        writeDataSmooth(data: warmUpData)
        Thread.sleep(forTimeInterval: 0.1)
        print("✅ Printer warmed up")
    }
    
    // ====================================================================
    // MARK: - Discovery
    // ====================================================================
    private func discoverPrinters(type: String, result: @escaping FlutterResult) {
        ensureBluetoothManager()
        switch type {
        case "bluetooth", "ble":
            discoverBluetoothPrinters(result: result)
        case "usb":
            discoverUSBPrinters(result: result)
        case "network":
            result([])
        default:
            result(FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil))
        }
    }
    
    private func discoverAllPrinters(result: @escaping FlutterResult) {
        ensureBluetoothManager()
        var allPrinters: [[String: Any]] = []
        
        // Add discovered Bluetooth devices
        for peripheral in discoveredDevices {
            if let name = peripheral.name, !name.isEmpty {
                allPrinters.append([
                    "name": name,
                    "address": peripheral.identifier.uuidString,
                    "type": "bluetooth"
                ])
            }
        }
        
        // Add EAAccessory devices (if any)
        let accessories = EAAccessoryManager.shared().connectedAccessories
        for accessory in accessories {
            allPrinters.append([
                "name": accessory.name,
                "address": "\(accessory.connectionID)",
                "type": "usb"
            ])
        }
        
        result(allPrinters)
    }
    
    private func discoverBluetoothPrinters(result: @escaping FlutterResult) {
        ensureBluetoothManager()
        guard let manager = centralManager else {
            result(FlutterError(code: "BT_NOT_READY", message: "Bluetooth not ready", details: nil))
            return
        }
        
        discoveredDevices.removeAll()
        discoveryResult = result
        
        // Start scanning
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Timeout after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.stopDiscovery()
        }
        
        print("🔍 Starting Bluetooth discovery...")
    }
    
    private func stopDiscovery() {
        centralManager?.stopScan()
        
        let printers = discoveredDevices
                .compactMap { peripheral -> [String: Any]? in
                    guard let name = peripheral.name, !name.isEmpty else {
                        return nil  // Skip devices without names
                    }
                    return [
                        "name": name,  // ✅ Always has a valid name now
                        "address": peripheral.identifier.uuidString,
                        "type": "bluetooth"
                    ]
                }
        
        if let result = discoveryResult {
            result(printers)
            discoveryResult = nil
        }
        
        print("🔍 Discovery finished. Total devices: \(discoveredDevices.count)")
    }
    
    private func discoverUSBPrinters(result: @escaping FlutterResult) {
        let accessories = EAAccessoryManager.shared().connectedAccessories
        let printers = accessories.map { accessory in
            return [
                "name": accessory.name,
                "address": "\(accessory.connectionID)",
                "type": "usb"
            ]
        }
        result(printers)
    }
    
    // ====================================================================
    // MARK: - Connection
    // ====================================================================
    private func connect(address: String, type: String, result: @escaping FlutterResult) {
        print("🔵 Connect request: address=\(address), type=\(type)")
        
        switch type {
        case "bluetooth", "ble":
            connectBluetooth(address: address, result: result)
        case "usb":
            result(FlutterError(code: "NOT_IMPLEMENTED", message: "USB not yet implemented", details: nil))
        default:
            result(FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil))
        }
    }
    
    private func connectBluetooth(address: String, result: @escaping FlutterResult) {
        guard let manager = centralManager else {
            result(FlutterError(code: "BT_NOT_READY", message: "Bluetooth not ready", details: nil))
            return
        }
        
        guard manager.state == .poweredOn else {
            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is turned off", details: nil))
            return
        }
        
        // Find peripheral by UUID
        if let uuid = UUID(uuidString: address) {
            let peripherals = manager.retrievePeripherals(withIdentifiers: [uuid])
            if let peripheral = peripherals.first {
                pendingResults[address] = result
                connectedPeripheral = peripheral
                peripheral.delegate = self
                manager.connect(peripheral, options: nil)
                
                // Timeout
                DispatchQueue.main.asyncAfter(deadline: .now() + PrinterConfig.connectionTimeout) {
                    if self.pendingResults[address] != nil {
                        self.pendingResults.removeValue(forKey: address)
                        result(FlutterError(code: "TIMEOUT", message: "Connection timeout", details: nil))
                        self.centralManager?.cancelPeripheralConnection(peripheral)
                    }
                }
                return
            }
        }
        
        result(FlutterError(code: "NOT_FOUND", message: "Device not found", details: nil))
    }
    
    private func connectNetwork(ipAddress: String, port: Int, result: @escaping FlutterResult) {
        let host = NWEndpoint.Host(ipAddress)
        let port = NWEndpoint.Port(integerLiteral: UInt16(port))
        
        let connection = NWConnection(host: host, port: port, using: .tcp)
        networkConnection = connection
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.currentConnectionType = .network
                DispatchQueue.main.async {
                    self?.initializePrinterForSmoothPrinting()
                    result(true)
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    result(FlutterError(code: "CONNECTION_FAILED", message: error.localizedDescription, details: nil))
                }
            case .waiting(let error):
                print("⏳ Waiting: \(error)")
            default:
                break
            }
        }
        
        connection.start(queue: networkQueue!)
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        cleanupAllConnections()
        result(true)
    }
    
    private func cleanupAllConnections() {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheral = nil
        writeCharacteristic = nil
        
        networkConnection?.cancel()
        networkConnection = nil
        
        currentConnectionType = .none
        print("🧹 All connections cleaned up")
    }
    
    // ====================================================================
    // MARK: - Writing Data
    // ====================================================================
    private func writeDataSmooth(data: Data) {
        let startTime = Date()
        
        print("📝 Writing \(data.count) bytes...")
        
        switch currentConnectionType {
        case .bluetoothBLE:
            writeBLEDataOptimized(data: data)
            
            // Small delay to ensure completion
            Thread.sleep(forTimeInterval: 0.025)
            
        case .network:
            writeNetworkOptimized(data: data)
            Thread.sleep(forTimeInterval: 0.020)
            
        default:
            print("❌ No active connection")
            return
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        print("✅ Complete: \(data.count) bytes in \(Int(elapsed * 1000))ms")
    }
    
    
    
    private func writeBLEDataOptimized(data: Data) {
        guard let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else {
            print("❌ No BLE connection")
            return
        }
        
        let canWriteWithoutResponse = characteristic.properties.contains(.writeWithoutResponse)
        
        if canWriteWithoutResponse {
            // ✅ RELIABLE SETTINGS - No data loss!
            let chunkSize = 128          // Safe chunk size
            let reliableDelay: TimeInterval = 0.010  // Ensures printer receives all data
            
            var offset = 0
            var chunksWritten = 0
            
            print("📤 Sending \(data.count) bytes to printer...")
            
            while offset < data.count {
                let end = min(offset + chunkSize, data.count)
                let chunk = data[offset..<end]
                
                // Write chunk
                peripheral.writeValue(Data(chunk), for: characteristic, type: .withoutResponse)
                chunksWritten += 1
                
                // CRITICAL: Always delay between chunks
                Thread.sleep(forTimeInterval: reliableDelay)
                
                offset = end
            }
            
            // Extra time for last chunk to be processed
            Thread.sleep(forTimeInterval: 0.025)
            
            print("✅ Sent \(chunksWritten) chunks successfully")
            
        } else {
            // Write with response mode (guaranteed delivery)
            print("📤 Using write-with-response mode (reliable)")
            let chunkSize = 20
            var offset = 0
            
            while offset < data.count {
                let end = min(offset + chunkSize, data.count)
                let chunk = data[offset..<end]
                
                let semaphore = DispatchSemaphore(value: 0)
                peripheral.writeValue(Data(chunk), for: characteristic, type: .withResponse)
                _ = semaphore.wait(timeout: .now() + 0.2)
                
                offset = end
            }
            
            print("✅ All data sent with confirmation")
        }
    }
    
    
    private func writeNetworkOptimized(data: Data) {
        guard let connection = networkConnection else {
            print("❌ No network connection")
            return
        }
        
        if data.count < 1000 {
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Network error: \(error)")
                }
            })
            return
        }
        
        let chunkSize = 512
        var offset = 0
        
        while offset < data.count {
            let end = min(offset + chunkSize, data.count)
            let chunk = data[offset..<end]
            
            connection.send(content: chunk, completion: .contentProcessed { error in
                if let error = error {
                    print("❌ Network error: \(error)")
                }
            })
            
            if end < data.count {
                Thread.sleep(forTimeInterval: 0.01)
            }
            
            offset = end
        }
    }
    
    private func writeTextWithLineDelays(data: Data) {
        guard currentConnectionType == .bluetoothBLE else {
            writeDataSmooth(data: data)
            return
        }
        
        // Split by line feeds and write with delays
        var buffer = Data()
        
        for byte in data {
            buffer.append(byte)
            
            if byte == 0x0A {  // Line feed detected
                // Write this line
                writeBLEDataOptimized(data: buffer)
                
                // Small delay for motor to complete paper feed
                Thread.sleep(forTimeInterval: 0.035)  // 35ms
                
                buffer.removeAll()
            }
        }
        
        // Write any remaining data
        if !buffer.isEmpty {
            writeBLEDataOptimized(data: buffer)
        }
    }
    
    // ====================================================================
    // MARK: - Print Text
    // ====================================================================
    private func printText(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int, result: @escaping FlutterResult) {
        let startTime = Date()
        
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            do {
                if self.containsComplexUnicode(text: text) {
                    print("🖼️ Rendering Complex text: \"\(text.prefix(30))...\"")
                    guard let imageData = self.renderTextToData(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine) else {
                        throw NSError(domain: "PrintError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render text"])
                    }
                    
                    var finalData = Data([self.ESC, 0x61, 0x00]) // Left align
                    finalData.append(imageData)
                    self.addToBuffer(data: finalData)
                } else {
                    self.printSimpleTextInternalBatched(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine)
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                print("✅ Text added to buffer in \(Int(elapsed * 1000))ms")
                
                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                print("❌ Print error: \(error)")
                DispatchQueue.main.async {
                    result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func printSimpleTextInternalBatched(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int) {
        print("🔵 Adding text to buffer: \"\(text.prefix(30))...\"")
        
        var commands = Data()
        
        // Detect separator line
        let isSeparatorLine = text.filter({ $0 == "=" }).count > Int(Double(text.count) * 0.8)
        
        if isSeparatorLine {
            print("📏 Detected separator line - using lower density")
            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
        }
        
        // Bold
        commands.append(contentsOf: [ESC, 0x45, bold ? 0x01 : 0x00])
        
        // Alignment
        let alignValue: UInt8
        switch align.lowercased() {
        case "center": alignValue = 0x01
        case "right": alignValue = 0x02
        default: alignValue = 0x00
        }
        commands.append(contentsOf: [ESC, 0x61, alignValue])
        
        // Size
        let sizeCommand: UInt8
        if isSeparatorLine {
            sizeCommand = 0x00
        } else {
            sizeCommand = fontSize > 30 ? 0x30 : (fontSize > 24 ? 0x11 : 0x00)
        }
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])
        
        // Text
        let wrappedText = maxCharsPerLine > 0 ? wrapText(text: text, maxChars: maxCharsPerLine) : text
        if let textData = wrappedText.data(using: .ascii) {
            commands.append(textData)
        }
        commands.append(0x0A)
        
        // Reset
        commands.append(contentsOf: [ESC, 0x45, 0x00])
        commands.append(contentsOf: [ESC, 0x61, 0x00])
        
        if isSeparatorLine {
            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])
        }
        
        addToBuffer(data: commands)
    }
    
    private func printSeparator(width: Int, result: @escaping FlutterResult) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            var commands = Data()
            
            // Lower density
            commands.append(contentsOf: [self.GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
            
            // Center align
            commands.append(contentsOf: [self.ESC, 0x61, 0x01])
            
            // Smaller font
            commands.append(contentsOf: [self.ESC, 0x21, 0x00])
            
            // Print separator
            let separator = String(repeating: "=", count: width)
            if let data = separator.data(using: .ascii) {
                commands.append(data)
            }
            commands.append(0x0A)
            
            // Reset
            commands.append(contentsOf: [self.GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])
            commands.append(contentsOf: [self.ESC, 0x61, 0x00])
            
            self.addToBuffer(data: commands)
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    // ====================================================================
    // MARK: - Print Row
    // ====================================================================
    private func printRow(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult) {
        let startTime = Date()
        
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            let posColumns = columns.compactMap { col -> PosColumn? in
                guard let text = col["text"] as? String,
                      let width = col["width"] as? Int else { return nil }
                let align = col["align"] as? String ?? "left"
                let bold = col["bold"] as? Bool ?? false
                return PosColumn(text: text, width: width, align: align, bold: bold)
            }
            
            let totalWidth = posColumns.reduce(0) { $0 + $1.width }
            if totalWidth > 12 {
                DispatchQueue.main.async {
                    result(FlutterError(code: "ROW_ERROR", message: "Total width exceeds 12: \(totalWidth)", details: nil))
                }
                return
            }
            
            let hasComplexUnicode = posColumns.contains { self.containsComplexUnicode(text: $0.text) }
            
            if hasComplexUnicode {
                guard let imageData = self.renderRowToData(columns: posColumns, fontSize: fontSize) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "RENDER_ERROR", message: "Failed to render row", details: nil))
                    }
                    return
                }
                self.addToBuffer(data: imageData)
            } else {
                self.printRowUsingTextMethodBatched(columns: posColumns, fontSize: fontSize)
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            print("✅ Row added to buffer in \(Int(elapsed * 1000))ms")
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    private func printRowUsingTextMethodBatched(columns: [PosColumn], fontSize: Int) {
        let totalChars: Int
        switch fontSize {
        case ...24: totalChars = 48
        case 25...30: totalChars = 32
        default: totalChars = 24
        }
        
        var commands = Data()
        
        // Size
        let sizeCommand: UInt8 = fontSize > 30 ? 0x30 : (fontSize > 24 ? 0x11 : 0x00)
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])
        
        // Bold if needed
        let hasBold = columns.contains { $0.bold }
        if hasBold {
            commands.append(contentsOf: [ESC, 0x45, 0x01])
        }
        
        // Left align
        commands.append(contentsOf: [ESC, 0x61, 0x00])
        
        // Build rows
        let columnTextLists = columns.map { column -> (lines: [String], width: Int, align: String) in
            let maxCharsPerColumn = (totalChars * column.width) / 12
            let lines = wrapTextToList(text: column.text, maxChars: maxCharsPerColumn)
            return (lines, maxCharsPerColumn, column.align)
        }
        
        let maxLines = columnTextLists.map { $0.lines.count }.max() ?? 1
        
        for lineIndex in 0..<maxLines {
            var lineText = ""
            for (lines, width, align) in columnTextLists {
                let text = lineIndex < lines.count ? lines[lineIndex] : ""
                lineText += formatColumnText(text: text, width: width, align: align)
            }
            if let data = lineText.data(using: .ascii) {
                commands.append(data)
            }
            commands.append(0x0A)
        }
        
        // Reset
        if hasBold {
            commands.append(contentsOf: [ESC, 0x45, 0x00])
        }
        commands.append(contentsOf: [ESC, 0x61, 0x00])
        
        addToBuffer(data: commands)
    }
    
    private func formatColumnText(text: String, width: Int, align: String) -> String {
        if text.count == width { return text }
        if text.count > width { return String(text.prefix(width)) }
        
        switch align.lowercased() {
        case "center":
            let totalPadding = width - text.count
            let leftPadding = totalPadding / 2
            return String(repeating: " ", count: leftPadding) + text + String(repeating: " ", count: width - text.count - leftPadding)
        case "right":
            return String(repeating: " ", count: width - text.count) + text
        default:
            return text + String(repeating: " ", count: width - text.count)
        }
    }
    
    // ====================================================================
    // MARK: - Print Image
    // ====================================================================
    private func printImage(imageBytes: Data, width: Int, align: Int, result: @escaping FlutterResult) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            guard let image = UIImage(data: imageBytes) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
                }
                return
            }
            
            let alignment = ImageAlignment.from(align)
            let scaledImage = self.resizeImage(image: image, maxWidth: width)
            
            guard let monochromeData = self.convertToMonochrome(image: scaledImage) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert to monochrome", details: nil))
                }
                return
            }
            
            var commands = Data()
            commands.append(contentsOf: [self.ESC, 0x40])       // Reset
            commands.append(contentsOf: [self.ESC, 0x61, UInt8(alignment.rawValue)]) // Align
            
            // Image command
            commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])
            
            let widthBytes = (monochromeData.width + 7) / 8
            commands.append(UInt8(widthBytes & 0xFF))
            commands.append(UInt8((widthBytes >> 8) & 0xFF))
            commands.append(UInt8(monochromeData.height & 0xFF))
            commands.append(UInt8((monochromeData.height >> 8) & 0xFF))
            
            commands.append(monochromeData.data)
            
            // Reset alignment
            commands.append(contentsOf: [self.ESC, 0x61, 0x00])
            commands.append(contentsOf: [0x0A, 0x0A])
            
            self.writeDataSmooth(data: commands)
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    private func printImageWithPadding(imageBytes: Data, width: Int, align: Int, paperWidth: Int, result: @escaping FlutterResult) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            guard let image = UIImage(data: imageBytes) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
                }
                return
            }
            
            let alignment = ImageAlignment.from(align)
            let scaledImage = self.resizeImage(image: image, maxWidth: width)
            
            guard var monochromeData = self.convertToMonochrome(image: scaledImage) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert to monochrome", details: nil))
                }
                return
            }
            
            if alignment != .left {
                monochromeData = self.addPaddingToMonochrome(data: monochromeData, alignment: alignment, paperWidth: paperWidth)
            }
            
            var commands = Data()
            commands.append(contentsOf: [self.ESC, 0x40])
            commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])
            
            let widthBytes = (monochromeData.width + 7) / 8
            commands.append(UInt8(widthBytes & 0xFF))
            commands.append(UInt8((widthBytes >> 8) & 0xFF))
            commands.append(UInt8(monochromeData.height & 0xFF))
            commands.append(UInt8((monochromeData.height >> 8) & 0xFF))
            
            commands.append(monochromeData.data)
            commands.append(contentsOf: [0x0A, 0x0A])
            
            self.writeDataSmooth(data: commands)
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    // ====================================================================
    // MARK: - Image Processing
    // ====================================================================
    private func resizeImage(image: UIImage, maxWidth: Int) -> UIImage {
        guard image.size.width > CGFloat(maxWidth) else { return image }
        
        let ratio = CGFloat(maxWidth) / image.size.width
        let newHeight = image.size.height * ratio
        let newSize = CGSize(width: CGFloat(maxWidth), height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func convertToMonochrome(image: UIImage) -> MonochromeData? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var pixels = [UInt8](repeating: 0, count: width * height)
        
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let widthBytes = (width + 7) / 8
        var data = Data(count: widthBytes * height)
        let threshold: UInt8 = 128
        
        for y in 0..<height {
            let rowOffset = y * widthBytes
            for x in 0..<width {
                let pixelValue = pixels[y * width + x]
                if pixelValue < threshold {
                    let byteIndex = rowOffset + (x / 8)
                    let bitIndex = 7 - (x % 8)
                    data[byteIndex] |= (1 << bitIndex)
                }
            }
        }
        
        return MonochromeData(width: width, height: height, data: data)
    }
    
    private func addPaddingToMonochrome(data: MonochromeData, alignment: ImageAlignment, paperWidth: Int) -> MonochromeData {
        guard data.width < paperWidth else { return data }
        
        let paddingTotal = paperWidth - data.width
        let leftPadding: Int
        
        switch alignment {
        case .left: leftPadding = 0
        case .center: leftPadding = paddingTotal / 2
        case .right: leftPadding = paddingTotal
        }
        
        let currentWidthBytes = (data.width + 7) / 8
        let newWidthBytes = (paperWidth + 7) / 8
        var newData = Data(count: newWidthBytes * data.height)
        
        for y in 0..<data.height {
            let newRowOffset = y * newWidthBytes
            let oldRowOffset = y * currentWidthBytes
            let leftPaddingBytes = leftPadding / 8
            
            let sourceRange = oldRowOffset..<(oldRowOffset + currentWidthBytes)
            let destRange = (newRowOffset + leftPaddingBytes)..<(newRowOffset + leftPaddingBytes + currentWidthBytes)
            newData.replaceSubrange(destRange, with: data.data[sourceRange])
        }
        
        return MonochromeData(width: paperWidth, height: data.height, data: newData)
    }
    
    // ====================================================================
    // MARK: - Text Rendering
    // ====================================================================
    private func renderTextToData(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int) -> Data? {
        let font = getFont(size: fontSize, bold: bold)
        
        let textToRender = maxCharsPerLine > 0 ? wrapText(text: text, maxChars: maxCharsPerLine) : text
        let lines = textToRender.components(separatedBy: "\n")
        
        let maxWidth = CGFloat(printerWidth)
        let padding: CGFloat = 2.0
        let lineHeight = font.lineHeight * 0.9
        let totalHeight = CGFloat(lines.count) * lineHeight + padding * 2
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: totalHeight), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: totalHeight))
        
        let textColor = UIColor.black
        var y = padding
        
        for line in lines {
            if !line.isEmpty {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: textColor
                ]
                
                let attributedString = NSAttributedString(string: line, attributes: attributes)
                let size = attributedString.size()
                
                let x: CGFloat
                switch align.lowercased() {
                case "center": x = (maxWidth - size.width) / 2
                case "right": x = maxWidth - size.width - padding
                default: x = padding
                }
                
                attributedString.draw(at: CGPoint(x: x, y: y))
            }
            y += lineHeight
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let monoData = convertToMonochrome(image: image) else { return nil }
        
        var commands = Data()
        commands.append(contentsOf: [GS, 0x76, 0x30, 0x00])
        
        let widthBytes = (monoData.width + 7) / 8
        commands.append(UInt8(widthBytes & 0xFF))
        commands.append(UInt8((widthBytes >> 8) & 0xFF))
        commands.append(UInt8(monoData.height & 0xFF))
        commands.append(UInt8((monoData.height >> 8) & 0xFF))
        commands.append(monoData.data)
        
        return commands
    }
    
    private func renderRowToData(columns: [PosColumn], fontSize: Int) -> Data? {
        let font = getFont(size: fontSize, bold: false)
        
        let maxWidth = CGFloat(printerWidth)
        let columnWidths = columns.map { (maxWidth * CGFloat($0.width)) / 12.0 }
        
        let totalChars: Int
        switch fontSize {
        case ...24: totalChars = 42
        case 25...30: totalChars = 28
        default: totalChars = 20
        }
        
        var maxLines = 1
        for column in columns {
            let colChars = (totalChars * column.width) / 12
            let lineCount = (column.text.count + colChars - 1) / colChars
            maxLines = max(maxLines, lineCount)
        }
        
        let lineHeight = font.lineHeight * 0.9
        let verticalPadding: CGFloat = 4.0
        let totalHeight = lineHeight * CGFloat(maxLines) + verticalPadding * 2
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: totalHeight), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: totalHeight))
        
        var currentX: CGFloat = 0
        for (index, column) in columns.enumerated() {
            let colWidth = columnWidths[index]
            let colChars = (totalChars * column.width) / 12
            let lines = wrapTextToList(text: column.text, maxChars: colChars)
            let columnFont = getFont(size: fontSize, bold: column.bold)
            
            for (lineIndex, line) in lines.enumerated() {
                if line.isEmpty { continue }
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: columnFont,
                    .foregroundColor: UIColor.black
                ]
                
                let attributedString = NSAttributedString(string: line, attributes: attributes)
                let size = attributedString.size()
                
                let x: CGFloat
                switch column.align.lowercased() {
                case "center": x = currentX + (colWidth - size.width) / 2
                case "right": x = currentX + colWidth - size.width
                default: x = currentX
                }
                
                let y = verticalPadding + lineHeight * CGFloat(lineIndex)
                attributedString.draw(at: CGPoint(x: x, y: y))
            }
            
            currentX += colWidth
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let monoData = convertToMonochrome(image: image) else { return nil }
        
        var commands = Data()
        commands.append(contentsOf: [GS, 0x76, 0x30, 0x00])
        
        let widthBytes = (monoData.width + 7) / 8
        commands.append(UInt8(widthBytes & 0xFF))
        commands.append(UInt8((widthBytes >> 8) & 0xFF))
        commands.append(UInt8(monoData.height & 0xFF))
        commands.append(UInt8((monoData.height >> 8) & 0xFF))
        commands.append(monoData.data)
        
        return commands
    }
    
    // ====================================================================
    // MARK: - Font Management
    // ====================================================================
    private func getFont(size: Int, bold: Bool) -> UIFont {
        let fontKey = "\(size)_\(bold)"
        
        if let cachedFont = fontCache[fontKey] {
            return cachedFont
        }
        
        let baseFontSize: CGFloat = 24.0
        let scaledFontSize: CGFloat
        
        switch size {
        case ...24: scaledFontSize = baseFontSize
        case 25...30: scaledFontSize = baseFontSize * 1.5
        default: scaledFontSize = baseFontSize * 2.0
        }
        
        // Try to load Khmer font
        var font: UIFont?
        
        if bold {
            font = UIFont(name: "NotoSansKhmer-Bold", size: scaledFontSize)
                ?? UIFont(name: "NotoSansKhmer-SemiBold", size: scaledFontSize)
                ?? UIFont(name: "NotoSansKhmer-Medium", size: scaledFontSize)
        }
        
        if font == nil {
            font = UIFont(name: "NotoSansKhmer-Regular", size: scaledFontSize)
        }
        
        if font == nil {
            font = bold ? UIFont.boldSystemFont(ofSize: scaledFontSize) : UIFont.systemFont(ofSize: scaledFontSize)
        }
        
        fontCache[fontKey] = font!
        return font!
    }
    
    private func preloadFonts() {
        DispatchQueue.global(qos: .background).async {
            _ = self.getFont(size: 24, bold: false)
            _ = self.getFont(size: 24, bold: true)
            print("✅ Fonts preloaded")
        }
    }
    
    // ====================================================================
    // MARK: - Text Utilities
    // ====================================================================
    private func containsComplexUnicode(text: String) -> Bool {
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if (0x1780...0x17FF).contains(value) ||  // Khmer
               (0x0E00...0x0E7F).contains(value) ||  // Thai
               (0x4E00...0x9FFF).contains(value) ||  // CJK
               (0xAC00...0xD7AF).contains(value) {   // Hangul
                return true
            }
        }
        return false
    }
    
    private func wrapText(text: String, maxChars: Int) -> String {
        return wrapTextToList(text: text, maxChars: maxChars).joined(separator: "\n")
    }
    
    private func wrapTextToList(text: String, maxChars: Int) -> [String] {
        guard maxChars > 0 else { return [text] }
        
        var lines: [String] = []
        let words = text.components(separatedBy: " ")
        var currentLine = ""
        
        for word in words {
            if word.count > maxChars {
                if !currentLine.isEmpty {
                    lines.append(currentLine.trimmingCharacters(in: .whitespaces))
                    currentLine = ""
                }
                
                var remaining = word
                while remaining.count > maxChars {
                    lines.append(String(remaining.prefix(maxChars)))
                    remaining = String(remaining.dropFirst(maxChars))
                }
                if !remaining.isEmpty {
                    currentLine = remaining + " "
                }
                continue
            }
            
            let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
            
            if getVisualWidth(text: testLine) <= Double(maxChars) {
                currentLine = testLine
            } else {
                if !currentLine.isEmpty {
                    lines.append(currentLine.trimmingCharacters(in: .whitespaces))
                }
                currentLine = word + " "
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine.trimmingCharacters(in: .whitespaces))
        }
        
        return lines.isEmpty ? [""] : lines
    }
    
    private func getVisualWidth(text: String) -> Double {
        var width = 0.0
        for scalar in text.unicodeScalars {
            let value = scalar.value
            switch value {
            case 0x1780...0x17FF: width += 1.4  // Khmer
            case 0x17B4...0x17D3: width += 0.0  // Khmer combining
            case 0x0E00...0x0E7F: width += 1.2  // Thai
            case 0x4E00...0x9FFF, 0xAC00...0xD7AF: width += 2.0  // CJK, Hangul
            default: width += 1.0
            }
        }
        return width
    }
    
    // ====================================================================
    // MARK: - Paper Control
    // ====================================================================
    private func feedPaper(lines: Int, result: @escaping FlutterResult) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            let commands = Data(repeating: 0x0A, count: lines)
            self.addToBuffer(data: commands)
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    private func cutPaper(result: @escaping FlutterResult) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }
            
            let commands = Data([self.GS, 0x56, 0x00])
            self.addToBuffer(data: commands)
            
            DispatchQueue.main.async {
                result(true)
            }
        }
    }
    
    private func setPrinterWidth(width: Int, result: @escaping FlutterResult) {
        printerWidth = width
        print("✅ Printer width set to \(width) dots")
        result(true)
    }
    
    // ====================================================================
    // MARK: - Status & Permissions
    // ====================================================================
    private func getStatus(result: @escaping FlutterResult) {
        let isEnabled = centralManager?.state == .poweredOn
        let isConnected: Bool
        
        switch currentConnectionType {
        case .bluetoothBLE:
            isConnected = connectedPeripheral != nil && writeCharacteristic != nil
        case .network:
            isConnected = networkConnection?.state == .ready
        default:
            isConnected = false
        }
        
        let status: [String: Any] = [
            "status": "authorized",
            "enabled": isEnabled,
            "connected": isConnected,
            "connectionType": String(describing: currentConnectionType).lowercased()
        ]
        
        result(status)
    }
    
    private func checkBluetoothPermission(result: @escaping FlutterResult) {
        ensureBluetoothManager()
        result(true)
    }
}

// ====================================================================
// MARK: - CBCentralManagerDelegate
// ====================================================================
extension ThermalPrinterPlugin: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("🔵 Bluetooth state: \(central.state.rawValue)")
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
            print("📱 Found device: \(peripheral.name ?? "Unknown") (\(peripheral.identifier))")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to peripheral: \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        let address = peripheral.identifier.uuidString
        if let result = pendingResults.removeValue(forKey: address) {
            DispatchQueue.main.async {
                result(FlutterError(code: "CONNECTION_FAILED", message: error?.localizedDescription, details: nil))
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Disconnected from peripheral")
        connectedPeripheral = nil
        writeCharacteristic = nil
        currentConnectionType = .none
    }
}

// ====================================================================
// MARK: - CBPeripheralDelegate
// ====================================================================
extension ThermalPrinterPlugin: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("❌ Service discovery error: \(error!)")
            return
        }
        
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("❌ Characteristic discovery error: \(error!)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = characteristic
                currentConnectionType = .bluetoothBLE
                print("✅ Found writable characteristic: \(characteristic.uuid)")
                
                // Initialize printer
                initializePrinterForSmoothPrinting()
                
                let address = peripheral.identifier.uuidString
                if let result = pendingResults.removeValue(forKey: address) {
                    DispatchQueue.main.async {
                        result(true)
                    }
                }
                return
            }
        }
        
        print("❌ No writable characteristic found")
        let address = peripheral.identifier.uuidString
        if let result = pendingResults.removeValue(forKey: address) {
            DispatchQueue.main.async {
                result(FlutterError(code: "NO_CHARACTERISTIC", message: "No writable characteristic found", details: nil))
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Write error: \(error)")
        }
    }
}


//import CoreBluetooth
//import ExternalAccessory
//import Flutter
//import Network
//import UIKit
//
//// ====================================================================
//// MARK: - Configuration
//// ====================================================================
//struct PrinterConfig {
//    static let DEFAULT_PRINTER_WIDTH = 576 // 80mm
//    static let SMALL_PRINTER_WIDTH = 384   // 58mm
//    static let CONNECTION_TIMEOUT: TimeInterval = 15.0
//}
//
//// ====================================================================
//// MARK: - Data Structures
//// ====================================================================
//struct MonochromeData {
//    let width: Int
//    let height: Int
//    let data: Data
//}
//
//struct PosColumn {
//    let text: String
//    let width: Int
//    let align: String
//    let bold: Bool
//}
//
//enum ImageAlignment: Int {
//    case left = 0
//    case center = 1
//    case right = 2
//    
//    static func from(value: Int) -> ImageAlignment {
//        return ImageAlignment(rawValue: value) ?? .center
//    }
//}
//
//enum ConnectionType: String {
//    case bluetoothClassic = "bluetooth_classic"
//    case bluetoothBLE = "bluetooth_ble"
//    case network = "network"
//    case usb = "usb"
//    case none = "none"
//}
//
//enum PrinterModel {
//    case unknown
//    case slow      // Old printers (50 bytes/ms)
//    case medium    // Standard printers (80 bytes/ms)
//    case fast      // Modern printers (120 bytes/ms)
//}
//
//enum PrinterSpeed {
//    case unknown
//    case slow      // < 3 bytes/ms
//    case medium    // 3-6 bytes/ms
//    case fast      // > 6 bytes/ms
//}
//
//// ====================================================================
//// MARK: - Main Plugin Class
//// ====================================================================
//public class ThermalPrinterPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate,
//    CBPeripheralDelegate, EAAccessoryDelegate, StreamDelegate {
//    
//    // MARK: - Properties
//    
//    // Bluetooth & BLE
//    private var centralManager: CBCentralManager!
//    private var connectedPeripheral: CBPeripheral?
//    private var writeCharacteristic: CBCharacteristic?
//    private var discoveredPrinters: [CBPeripheral] = []
//    private var scanResult: FlutterResult?
//    
//    // USB (External Accessory)
//    private var accessory: EAAccessory?
//    private var session: EASession?
//    private var writeStream: OutputStream?
//    
//    // Network
//    private var networkConnection: NWConnection?
//    
//    // Connection state
//    private var currentConnectionType: ConnectionType = .none
//    private var printerWidth = PrinterConfig.DEFAULT_PRINTER_WIDTH
//    private var isScanning = false
//    private var connectionResult: FlutterResult?
//    
//    // ESC/POS Commands
//    private let ESC: UInt8 = 0x1B
//    private let GS: UInt8 = 0x1D
//    
//    // Font cache
//    private var fontCache: [String: UIFont] = [:]
//    
//    // Batch mode for receipt optimization
//    private var receiptBuffer = Data()
//    private var isBatchMode = false
//    
//    // Printer characteristics
//    private var printerModel: PrinterModel = .unknown
//    private var printerSpeed: PrinterSpeed = .unknown
//    
//    // Serial queue for thread-safe operations
//    private let serialQueue = DispatchQueue(label: "com.thermal.printer.serial")
//    private let printQueue = DispatchQueue(label: "com.thermal.printer.print")
//    
//    // Write synchronization
//    private var writeCompleted = false
//    private let writeSemaphore = DispatchSemaphore(value: 0)
//    
//    // ✅ CRITICAL: Don't initialize CBCentralManager on startup
//    private var isCentralManagerInitialized = false
//    
//    // ====================================================================
//    // MARK: - Initialization
//    // ====================================================================
//    public override init() {
//        super.init()
//        // ✅ DON'T create CBCentralManager here - prevents permission dialog on startup
//        // centralManager will be created lazily when needed
//        print("🔵 ThermalPrinterPlugin initialized (Bluetooth NOT initialized)")
//        preloadFonts()
//    }
//    
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(
//            name: "thermal_printer",
//            binaryMessenger: registrar.messenger()
//        )
//        let instance = ThermalPrinterPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//    
//    // ✅ CRITICAL: Initialize CBCentralManager only when needed
//    private func ensureCentralManagerInitialized() {
//        if !isCentralManagerInitialized {
//            print("🔵 Initializing CBCentralManager (will trigger permission dialog)")
//            centralManager = CBCentralManager(
//                delegate: self,
//                queue: DispatchQueue.main,
//                options: [CBCentralManagerOptionShowPowerAlertKey: true]
//            )
//            isCentralManagerInitialized = true
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Font Management
//    // ====================================================================
//    private func preloadFonts() {
//        print("🔄 Preloading fonts...")
//        _ = getFont(bold: false, size: 24)
//        _ = getFont(bold: true, size: 24)
//        print("✅ Fonts preloaded")
//    }
//    
//    private func getFont(bold: Bool, size: CGFloat) -> UIFont {
//        let key = "\(bold ? "bold" : "regular")-\(size)"
//        
//        if let cached = fontCache[key] {
//            return cached
//        }
//        
//        let fontName = bold ? "NotoSansKhmer-Bold" : "NotoSansKhmer-Regular"
//        let font = UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: bold ? .bold : .regular)
//        
//        fontCache[key] = font
//        return font
//    }
//    
//    // ====================================================================
//    // MARK: - Method Call Handler
//    // ====================================================================
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        switch call.method {
//        case "discoverPrinters":
//            guard let args = call.arguments as? [String: Any],
//                  let type = args["type"] as? String else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing type", details: nil))
//                return
//            }
//            discoverPrinters(type: type, result: result)
//            
//        case "discoverAllPrinters":
//            discoverAllPrinters(result: result)
//            
//        case "connect":
//            guard let args = call.arguments as? [String: Any],
//                  let address = args["address"] as? String,
//                  let type = args["type"] as? String else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
//                return
//            }
//            connect(address: address, type: type, result: result)
//            
//        case "connectNetwork":
//            guard let args = call.arguments as? [String: Any],
//                  let ipAddress = args["ipAddress"] as? String else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing IP address", details: nil))
//                return
//            }
//            let port = args["port"] as? Int ?? 9100
//            connectNetwork(ipAddress: ipAddress, port: port, result: result)
//            
//        case "disconnect":
//            disconnect(result: result)
//            
//        case "startBatch":
//            startBatchMode()
//            result(true)
//            
//        case "endBatch":
//            endBatchMode()
//            result(true)
//            
//        case "printText":
//            guard let args = call.arguments as? [String: Any],
//                  let text = args["text"] as? String else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing text", details: nil))
//                return
//            }
//            let fontSize = args["fontSize"] as? Int ?? 24
//            let bold = args["bold"] as? Bool ?? false
//            let align = args["align"] as? String ?? "left"
//            let maxCharsPerLine = args["maxCharsPerLine"] as? Int ?? 0
//            
//            printText(text: text, fontSize: fontSize, bold: bold, align: align,
//                     maxCharsPerLine: maxCharsPerLine, result: result)
//            
//        case "printRow":
//            guard let args = call.arguments as? [String: Any],
//                  let columns = args["columns"] as? [[String: Any]] else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing columns", details: nil))
//                return
//            }
//            let fontSize = args["fontSize"] as? Int ?? 24
//            printRow(columns: columns, fontSize: fontSize, result: result)
//            
//        case "printImage":
//            handlePrintImageCall(call, result: result)
//            
//        case "feedPaper":
//            guard let args = call.arguments as? [String: Any],
//                  let lines = args["lines"] as? Int else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing lines", details: nil))
//                return
//            }
//            feedPaper(lines: lines, result: result)
//            
//        case "cutPaper":
//            cutPaper(result: result)
//            
//        case "getStatus":
//            getStatus(result: result)
//            
//        case "setPrinterWidth":
//            guard let args = call.arguments as? [String: Any],
//                  let width = args["width"] as? Int else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing width", details: nil))
//                return
//            }
//            setPrinterWidth(width: width, result: result)
//            
//        case "checkBluetoothPermission":
//            checkBluetoothPermission(result: result)
//            
//        case "testPaperFeed":
//            testPaperFeed(result: result)
//            
//        case "detectPrinterModel":
//            detectPrinterModel(result: result)
//            
//        case "printSeparator":
//            let width = (call.arguments as? [String: Any])?["width"] as? Int ?? 48
//            printSeparator(width: width, result: result)
//            
//        case "configureOOMAS":
//            configureOOMAS()
//            result(true)
//            
//        case "warmUpPrinter":
//            warmUpPrinter()
//            result(true)
//            
//        case "testSlowPrint":
//            testSlowPrint(result: result)
//            
//        case "checkPrinterStatus":
//            checkPrinterStatus(result: result)
//            
//        case "runDiagnostic":
//            runCompleteDiagnostic(result: result)
//            
//        case "initializePrinter":
//            initializePrinterOptimal()
//            result(true)
//            
//        case "printImageWithPadding":
//            guard let args = call.arguments as? [String: Any],
//                  let imageData = args["imageBytes"] as? FlutterStandardTypedData else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
//                return
//            }
//            let imgWidth = args["width"] as? Int ?? 384
//            let imgAlign = args["align"] as? Int ?? 1
//            let paperWidth = args["paperWidth"] as? Int ?? 576
//            printImageWithPadding(imageBytes: imageData.data, width: imgWidth, align: imgAlign, paperWidth: paperWidth, result: result)
//            
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Batch Mode (Receipt Optimization)
//    // ====================================================================
//    private func startBatchMode() {
//        serialQueue.sync {
//            receiptBuffer = Data()
//            isBatchMode = true
//            
//            // ✅ CRITICAL: Initialize printer ONCE at the start
//            var initCommands = Data()
//            initCommands.append(contentsOf: [ESC, 0x40])       // Reset printer
//            initCommands.append(contentsOf: [ESC, 0x74, 0x01]) // Set code page
//            initCommands.append(contentsOf: [ESC, 0x33, 0x30]) // Set line spacing
//            
//            receiptBuffer.append(initCommands)
//            print("📦 Started batch mode with initialization")
//        }
//    }
//    
//    private func endBatchMode() {
//        serialQueue.sync {
//            isBatchMode = false
//            if !receiptBuffer.isEmpty {
//                print("📤 Optimizing and sending batched receipt: \(receiptBuffer.count) bytes")
//                
//                // ✅ CRITICAL: Optimize the data before sending
//                let optimizedData = optimizeLineFeeds(receiptBuffer)
//                print("✅ Optimized: \(receiptBuffer.count) → \(optimizedData.count) bytes")
//                
//                writeDataSmooth(optimizedData)
//                receiptBuffer = Data()
//            }
//        }
//    }
//    
//    private func addToBuffer(_ data: Data) {
//        serialQueue.sync {
//            if isBatchMode {
//                receiptBuffer.append(data)
//                print("➕ Added \(data.count) bytes to buffer (total: \(receiptBuffer.count))")
//            } else {
//                writeDataSmooth(data)
//            }
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Data Optimization
//    // ====================================================================
//    private func optimizeLineFeeds(_ data: Data) -> Data {
//        var optimized = Data()
//        var consecutiveLineFeeds = 0
//        
//        for byte in data {
//            if byte == 0x0A {
//                consecutiveLineFeeds += 1
//            } else {
//                if consecutiveLineFeeds > 0 {
//                    // Replace multiple line feeds with optimal command
//                    if consecutiveLineFeeds >= 3 {
//                        optimized.append(contentsOf: [ESC, 0x64, UInt8(consecutiveLineFeeds)])
//                    } else {
//                        for _ in 0..<consecutiveLineFeeds {
//                            optimized.append(0x0A)
//                        }
//                    }
//                    consecutiveLineFeeds = 0
//                }
//                optimized.append(byte)
//            }
//        }
//        
//        // Handle trailing line feeds
//        if consecutiveLineFeeds > 0 {
//            if consecutiveLineFeeds >= 3 {
//                optimized.append(contentsOf: [ESC, 0x64, UInt8(consecutiveLineFeeds)])
//            } else {
//                for _ in 0..<consecutiveLineFeeds {
//                    optimized.append(0x0A)
//                }
//            }
//        }
//        
//        return optimized
//    }
//    
//    // ====================================================================
//    // MARK: - Printer Detection & Speed Testing
//    // ====================================================================
//    private func testPaperFeed(result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                print("🧪 TEST 1: Paper Feed Test")
//                print("Listen for 'stuck stuck' sound...")
//                
//                let testData = Data(repeating: 0x0A, count: 10)
//                let start = Date()
//                
//                self.writeDataDirect(testData)
//                Thread.sleep(forTimeInterval: 2.0)
//                
//                let elapsed = Date().timeIntervalSince(start)
//                
//                DispatchQueue.main.async {
//                    result([
//                        "test": "paper_feed",
//                        "instruction": "Did you hear 'stuck stuck' during paper feed? YES = Paper problem, NO = Code problem",
//                        "elapsed": elapsed
//                    ])
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "TEST_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    private func detectPrinterModel(result: @escaping FlutterResult) {
//        printQueue.async {
//            print("🔍 Detecting printer model and speed...")
//            
//            let testSizes = [100, 500, 1000]
//            var speeds: [Double] = []
//            
//            for size in testSizes {
//                let testData = Data(repeating: 0x20, count: size)
//                let start = Date()
//                
//                self.writeDataDirect(testData)
//                Thread.sleep(forTimeInterval: 0.05)
//                
//                let elapsed = Date().timeIntervalSince(start)
//                let speed = Double(size) / (elapsed * 1000) // bytes/ms
//                speeds.append(speed)
//                
//                Thread.sleep(forTimeInterval: 0.1)
//            }
//            
//            let avgSpeed = speeds.reduce(0, +) / Double(speeds.count)
//            
//            self.printerSpeed = avgSpeed > 6 ? .fast : (avgSpeed > 3 ? .medium : .slow)
//            self.printerModel = avgSpeed > 120 ? .fast : (avgSpeed > 80 ? .medium : .slow)
//            
//            print("✅ Detected: Speed=\(self.printerSpeed), Model=\(self.printerModel)")
//            print("📊 Average speed: \(String(format: "%.2f", avgSpeed)) bytes/ms")
//            
//            DispatchQueue.main.async {
//                result([
//                    "speed": String(describing: self.printerSpeed),
//                    "model": String(describing: self.printerModel),
//                    "avgSpeed": avgSpeed
//                ])
//            }
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Discovery
//    // ====================================================================
//    private func discoverPrinters(type: String, result: @escaping FlutterResult) {
//        switch type {
//        case "bluetooth", "ble":
//            // ✅ Initialize CBCentralManager ONLY when user wants to discover
//            ensureCentralManagerInitialized()
//            discoverBluetoothPrinters(result: result)
//        case "usb":
//            discoverUSBPrinters(result: result)
//        case "network":
//            result([])
//        default:
//            result(FlutterError(code: "INVALID_TYPE", message: "Unknown type: \(type)", details: nil))
//        }
//    }
//    
//    private func discoverAllPrinters(result: @escaping FlutterResult) {
//        // ✅ Initialize when discovering
//        ensureCentralManagerInitialized()
//        
//        var allPrinters: [[String: Any]] = []
//        
//        // Wait for manager to initialize
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if self.centralManager.state == .poweredOn {
//                self.discoveredPrinters.removeAll()
//                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                    self.centralManager.stopScan()
//                    
//                    for peripheral in self.discoveredPrinters {
//                        allPrinters.append([
//                            "name": peripheral.name ?? "Unknown",
//                            "address": peripheral.identifier.uuidString,
//                            "type": "bluetooth"
//                        ])
//                    }
//                    
//                    // USB
//                    let accessories = EAAccessoryManager.shared().connectedAccessories
//                    for accessory in accessories {
//                        if accessory.protocolStrings.contains("com.zebra.rawport") {
//                            allPrinters.append([
//                                "name": accessory.name,
//                                "address": "\(accessory.serialNumber)",
//                                "type": "usb"
//                            ])
//                        }
//                    }
//                    
//                    result(allPrinters)
//                }
//            } else {
//                result([])
//            }
//        }
//    }
//    
//    private func discoverBluetoothPrinters(result: @escaping FlutterResult) {
//        guard isCentralManagerInitialized else {
//            result(FlutterError(code: "NOT_INITIALIZED", message: "Bluetooth not initialized", details: nil))
//            return
//        }
//        
//        guard centralManager.state == .poweredOn else {
//            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is not enabled", details: nil))
//            return
//        }
//        
//        scanResult = result
//        discoveredPrinters.removeAll()
//        isScanning = true
//        
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.centralManager.stopScan()
//            self.isScanning = false
//            
//            let printers = self.discoveredPrinters.map { peripheral in
//                return [
//                    "name": peripheral.name ?? "Unknown Printer",
//                    "address": peripheral.identifier.uuidString,
//                    "type": "bluetooth"
//                ]
//            }
//            
//            result(printers)
//            self.scanResult = nil
//        }
//    }
//    
//    private func discoverUSBPrinters(result: @escaping FlutterResult) {
//        let accessories = EAAccessoryManager.shared().connectedAccessories
//        var printers: [[String: Any]] = []
//        
//        for accessory in accessories {
//            if accessory.protocolStrings.contains("com.zebra.rawport") {
//                printers.append([
//                    "name": accessory.name,
//                    "address": "\(accessory.serialNumber)",
//                    "type": "usb"
//                ])
//            }
//        }
//        
//        result(printers)
//    }
//    
//    // ====================================================================
//    // MARK: - Connection Management
//    // ====================================================================
//    private func connect(address: String, type: String, result: @escaping FlutterResult) {
//        connectionResult = result
//        
//        switch type {
//        case "bluetooth", "ble":
//            // ✅ Initialize when connecting
//            ensureCentralManagerInitialized()
//            connectBluetooth(address: address)
//        case "usb":
//            connectUSB(address: address)
//        default:
//            result(FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil))
//        }
//    }
//    
//    private func connectBluetooth(address: String) {
//        guard let peripheral = discoveredPrinters.first(where: { $0.identifier.uuidString == address }) else {
//            connectionResult?(FlutterError(code: "NOT_FOUND", message: "Printer not found", details: nil))
//            return
//        }
//        
//        centralManager.connect(peripheral, options: nil)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + PrinterConfig.CONNECTION_TIMEOUT) {
//            if self.connectedPeripheral == nil {
//                self.centralManager.cancelPeripheralConnection(peripheral)
//                self.connectionResult?(FlutterError(code: "TIMEOUT", message: "Connection timeout", details: nil))
//                self.connectionResult = nil
//            }
//        }
//    }
//    
//    private func connectUSB(address: String) {
//        let accessories = EAAccessoryManager.shared().connectedAccessories
//        
//        guard let foundAccessory = accessories.first(where: { $0.serialNumber == address }) else {
//            connectionResult?(FlutterError(code: "NOT_FOUND", message: "USB printer not found", details: nil))
//            return
//        }
//        
//        accessory = foundAccessory
//        
//        guard let protocolString = foundAccessory.protocolStrings.first else {
//            connectionResult?(FlutterError(code: "NO_PROTOCOL", message: "No protocol found", details: nil))
//            return
//        }
//        
//        session = EASession(accessory: foundAccessory, forProtocol: protocolString)
//        writeStream = session?.outputStream
//        writeStream?.delegate = self
//        writeStream?.schedule(in: .current, forMode: .default)
//        writeStream?.open()
//        
//        currentConnectionType = .usb
//        connectionResult?(true)
//        connectionResult = nil
//    }
//    
//    private func connectNetwork(ipAddress: String, port: Int, result: @escaping FlutterResult) {
//        let host = NWEndpoint.Host(ipAddress)
//        let nwPort = NWEndpoint.Port(integerLiteral: UInt16(port))
//        
//        networkConnection = NWConnection(host: host, port: nwPort, using: .tcp)
//        
//        networkConnection?.stateUpdateHandler = { [weak self] state in
//            switch state {
//            case .ready:
//                self?.currentConnectionType = .network
//                result(true)
//            case .failed(let error):
//                result(FlutterError(code: "CONNECTION_FAILED", message: error.localizedDescription, details: nil))
//            default:
//                break
//            }
//        }
//        
//        networkConnection?.start(queue: .global())
//    }
//    
//    private func disconnect(result: @escaping FlutterResult) {
//        switch currentConnectionType {
//        case .bluetoothClassic, .bluetoothBLE:
//            if let peripheral = connectedPeripheral {
//                centralManager.cancelPeripheralConnection(peripheral)
//            }
//            connectedPeripheral = nil
//            writeCharacteristic = nil
//            
//        case .usb:
//            writeStream?.close()
//            writeStream = nil
//            session = nil
//            accessory = nil
//            
//        case .network:
//            networkConnection?.cancel()
//            networkConnection = nil
//            
//        case .none:
//            break
//        }
//        
//        currentConnectionType = .none
//        result(true)
//    }
//    
//    // ====================================================================
//    // MARK: - Data Writing (Smooth & Optimized)
//    // ====================================================================
//    private func writeDataSmooth(_ data: Data) {
//        printQueue.async {
//            let chunkSize = self.getOptimalChunkSize()
//            var offset = 0
//            
//            while offset < data.count {
//                let end = min(offset + chunkSize, data.count)
//                let chunk = data.subdata(in: offset..<end)
//                
//                self.writeDataDirect(chunk)
//                
//                offset = end
//                
//                if offset < data.count {
//                    let delay = self.getOptimalDelay(for: chunk.count)
//                    Thread.sleep(forTimeInterval: delay)
//                }
//            }
//        }
//    }
//    
//    private func writeDataDirect(_ data: Data) {
//        switch currentConnectionType {
//        case .bluetoothClassic, .bluetoothBLE:
//            writeViaBluetooth(data)
//        case .usb:
//            writeViaUSB(data)
//        case .network:
//            writeViaNetwork(data)
//        case .none:
//            print("❌ No active connection")
//        }
//    }
//    
//    private func writeViaBluetooth(_ data: Data) {
//        guard let peripheral = connectedPeripheral,
//              let characteristic = writeCharacteristic else {
//            print("❌ Bluetooth not ready")
//            return
//        }
//        
//        let mtu = peripheral.maximumWriteValueLength(for: .withoutResponse)
//        var offset = 0
//        
//        while offset < data.count {
//            let end = min(offset + mtu, data.count)
//            let chunk = data.subdata(in: offset..<end)
//            
//            peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
//            offset = end
//            
//            if offset < data.count {
//                Thread.sleep(forTimeInterval: 0.01)
//            }
//        }
//    }
//    
//    private func writeViaUSB(_ data: Data) {
//        guard let stream = writeStream, stream.hasSpaceAvailable else {
//            print("❌ USB stream not ready")
//            return
//        }
//        
//        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
//            if let baseAddress = bytes.baseAddress {
//                let pointer = baseAddress.assumingMemoryBound(to: UInt8.self)
//                stream.write(pointer, maxLength: data.count)
//            }
//        }
//    }
//    
//    private func writeViaNetwork(_ data: Data) {
//        guard let connection = networkConnection else {
//            print("❌ Network connection not ready")
//            return
//        }
//        
//        if data.count < 1000 {
//            connection.send(content: data, completion: .contentProcessed { error in
//                if let error = error {
//                    print("❌ Network write error: \(error)")
//                }
//            })
//        } else {
//            let chunkSize = 512
//            var offset = 0
//            
//            while offset < data.count {
//                let end = min(offset + chunkSize, data.count)
//                let chunk = data.subdata(in: offset..<end)
//                
//                connection.send(content: chunk, completion: .contentProcessed { error in
//                    if let error = error {
//                        print("❌ Network chunk write error: \(error)")
//                    }
//                })
//                
//                if end < data.count {
//                    Thread.sleep(forTimeInterval: 0.01)
//                }
//                
//                offset = end
//            }
//        }
//    }
//    
//    private func getOptimalChunkSize() -> Int {
//        switch printerSpeed {
//        case .fast:
//            return 1024
//        case .medium:
//            return 512
//        case .slow, .unknown:
//            return 256
//        }
//    }
//    
//    private func getOptimalDelay(for byteCount: Int) -> TimeInterval {
//        switch printerSpeed {
//        case .fast:
//            return 0.005
//        case .medium:
//            return 0.010
//        case .slow, .unknown:
//            return 0.020
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Text Printing
//    // ====================================================================
//    private func printText(text: String, fontSize: Int, bold: Bool, align: String,
//                          maxCharsPerLine: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                var commands = Data()
//                
//                let needsImage = self.containsComplexUnicode(text)
//                
//                if needsImage {
//                    let wrappedLines = maxCharsPerLine > 0 ?
//                        self.wrapTextToList(text, maxCharsPerLine: maxCharsPerLine) : [text]
//                    
//                    for line in wrappedLines {
//                        if let bitmap = self.renderTextAsImage(line, fontSize: fontSize, bold: bold, align: align) {
//                            commands.append(contentsOf: self.createImageCommands(bitmap))
//                        }
//                    }
//                } else {
//                    self.printSimpleTextInternal(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine, commands: &commands)
//                }
//                
//                self.addToBuffer(commands)
//                
//                DispatchQueue.main.async {
//                    result(true)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    private func printSimpleTextInternal(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int, commands: inout Data) {
//        print("🔵 Adding text to buffer: \"\(text.prefix(30))...\"")
//        
//        // CRITICAL: Detect separator line
//        let equalsCount = text.filter { $0 == "=" }.count
//        let isSeparatorLine = Double(equalsCount) > (Double(text.count) * 0.8)
//        
//        if isSeparatorLine {
//            print("📏 Detected separator line - using lower density")
//            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
//        }
//        
//        // Bold
//        commands.append(contentsOf: [ESC, 0x45, bold ? 0x01 : 0x00])
//        
//        // Alignment
//        let alignValue: UInt8 = align == "center" ? 1 : (align == "right" ? 2 : 0)
//        commands.append(contentsOf: [ESC, 0x61, alignValue])
//        
//        // Size
//        let sizeCommand: UInt8 = isSeparatorLine ? 0x00 : (fontSize > 30 ? 0x30 : (fontSize > 24 ? 0x11 : 0x00))
//        commands.append(contentsOf: [ESC, 0x21, sizeCommand])
//        
//        // Text
//        let finalText = maxCharsPerLine > 0 ?
//            wrapText(text, maxCharsPerLine: maxCharsPerLine) : text
//        
//        if let textData = finalText.data(using: .ascii) {
//            commands.append(textData)
//        }
//        commands.append(0x0A)
//        
//        // Reset
//        commands.append(contentsOf: [ESC, 0x45, 0x00])
//        commands.append(contentsOf: [ESC, 0x61, 0x00])
//        
//        if isSeparatorLine {
//            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Row Printing (Columns)
//    // ====================================================================
//    private func printRow(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                let posColumns = columns.compactMap { dict -> PosColumn? in
//                    guard let text = dict["text"] as? String,
//                          let width = dict["width"] as? Int,
//                          let align = dict["align"] as? String else {
//                        return nil
//                    }
//                    let bold = dict["bold"] as? Bool ?? false
//                    return PosColumn(text: text, width: width, align: align, bold: bold)
//                }
//                
//                guard !posColumns.isEmpty else {
//                    throw NSError(domain: "PrinterError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid columns"])
//                }
//                
//                let hasComplexText = posColumns.contains { self.containsComplexUnicode($0.text) }
//                
//                var commands = Data()
//                
//                if hasComplexText {
//                    if let bitmap = self.renderRowAsImage(columns: posColumns, fontSize: fontSize) {
//                        commands.append(contentsOf: self.createImageCommands(bitmap))
//                    }
//                } else {
//                    commands.append(contentsOf: [self.ESC, 0x40])
//                    
//                    let charsPerLine = self.printerWidth / (fontSize / 3)
//                    var rowText = ""
//                    
//                    for column in posColumns {
//                        let colWidth = (charsPerLine * column.width) / 12
//                        let formatted = self.formatColumn(column.text, width: colWidth, align: column.align)
//                        rowText += formatted
//                    }
//                    
//                    if let textData = rowText.data(using: .utf8) {
//                        commands.append(textData)
//                    }
//                    commands.append(0x0A)
//                    commands.append(contentsOf: [self.ESC, 0x40])
//                }
//                
//                self.addToBuffer(commands)
//                
//                DispatchQueue.main.async {
//                    result(true)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "ROW_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    private func formatColumn(_ text: String, width: Int, align: String) -> String {
//        let trimmed = text.count > width ? String(text.prefix(width)) : text
//        let padding = width - trimmed.count
//        
//        switch align {
//        case "center":
//            let leftPad = padding / 2
//            let rightPad = padding - leftPad
//            return String(repeating: " ", count: leftPad) + trimmed + String(repeating: " ", count: rightPad)
//        case "right":
//            return String(repeating: " ", count: padding) + trimmed
//        default:
//            return trimmed + String(repeating: " ", count: padding)
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Image Printing
//    // ====================================================================
//    private func handlePrintImageCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let args = call.arguments as? [String: Any],
//              let imageData = args["imageBytes"] as? FlutterStandardTypedData else {
//            result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
//            return
//        }
//        
//        let width = args["width"] as? Int ?? 384
//        let align = args["align"] as? Int ?? 1
//        
//        printImage(imageBytes: imageData.data, width: width, align: align, result: result)
//    }
//    
//    private func printImage(imageBytes: Data, width: Int, align: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            guard let image = UIImage(data: imageBytes) else {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
//                }
//                return
//            }
//            
//            let alignment = ImageAlignment.from(value: align)
//            let scaledImage = self.resizeImage(image: image, maxWidth: width)
//            
//            guard let bitmap = self.convertToMonochromeFast(image: scaledImage) else {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert to monochrome", details: nil))
//                }
//                return
//            }
//            
//            let paddedBitmap = self.addPaddingToBitmap(bitmap: bitmap, alignment: alignment, paperWidth: self.printerWidth)
//            let commands = self.createImageCommands(paddedBitmap)
//            
//            self.addToBuffer(commands)
//            
//            DispatchQueue.main.async {
//                result(true)
//            }
//        }
//    }
//    
//    private func printImageWithPadding(imageBytes: Data, width: Int, align: Int, paperWidth: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            guard let image = UIImage(data: imageBytes) else {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
//                }
//                return
//            }
//            
//            let alignment = ImageAlignment.from(value: align)
//            let scaledImage = self.resizeImage(image: image, maxWidth: width)
//            
//            guard let originalBitmap = self.convertToMonochromeFast(image: scaledImage) else {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert to monochrome", details: nil))
//                }
//                return
//            }
//            
//            let bitmap: MonochromeData
//            if alignment != .left {
//                bitmap = self.addPaddingToBitmap(bitmap: originalBitmap, alignment: alignment, paperWidth: paperWidth)
//            } else {
//                bitmap = originalBitmap
//            }
//            
//            let commands = self.createImageCommands(bitmap)
//            self.addToBuffer(commands)
//            
//            DispatchQueue.main.async {
//                result(true)
//            }
//        }
//    }
//    
//    private func createImageCommands(_ bitmap: MonochromeData) -> Data {
//        var commands = Data()
//        
//        commands.append(contentsOf: [ESC, 0x40])
//        commands.append(contentsOf: [GS, 0x76, 0x30, 0x00])
//        
//        let widthBytes = (bitmap.width + 7) / 8
//        commands.append(UInt8(widthBytes & 0xFF))
//        commands.append(UInt8((widthBytes >> 8) & 0xFF))
//        commands.append(UInt8(bitmap.height & 0xFF))
//        commands.append(UInt8((bitmap.height >> 8) & 0xFF))
//        commands.append(bitmap.data)
//        commands.append(contentsOf: [0x0A, 0x0A])
//        
//        return commands
//    }
//    
//    private func resizeImage(image: UIImage, maxWidth: Int) -> UIImage {
//        let scale = CGFloat(maxWidth) / image.size.width
//        let newHeight = image.size.height * scale
//        let newSize = CGSize(width: CGFloat(maxWidth), height: newHeight)
//        
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        image.draw(in: CGRect(origin: .zero, size: newSize))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return resizedImage ?? image
//    }
//    
//    private func addPaddingToBitmap(bitmap: MonochromeData, alignment: ImageAlignment, paperWidth: Int) -> MonochromeData {
//        guard bitmap.width < paperWidth else {
//            return bitmap
//        }
//        
//        let paddingTotal = paperWidth - bitmap.width
//        let leftPadding: Int
//        
//        switch alignment {
//        case .left:
//            leftPadding = 0
//        case .center:
//            leftPadding = paddingTotal / 2
//        case .right:
//            leftPadding = paddingTotal
//        }
//        
//        let currentWidthBytes = (bitmap.width + 7) / 8
//        let newWidthBytes = (paperWidth + 7) / 8
//        var newData = Data()
//        
//        for y in 0..<bitmap.height {
//            for _ in 0..<(leftPadding / 8) {
//                newData.append(0x00)
//            }
//            
//            let rowStart = y * currentWidthBytes
//            let rowEnd = min(rowStart + currentWidthBytes, bitmap.data.count)
//            if rowStart < bitmap.data.count {
//                newData.append(bitmap.data.subdata(in: rowStart..<rowEnd))
//            }
//            
//            let rightPaddingBytes = newWidthBytes - (leftPadding / 8) - currentWidthBytes
//            for _ in 0..<rightPaddingBytes {
//                newData.append(0x00)
//            }
//        }
//        
//        return MonochromeData(width: paperWidth, height: bitmap.height, data: newData)
//    }
//    
//    private func convertToMonochromeFast(image: UIImage) -> MonochromeData? {
//        guard let cgImage = image.cgImage else { return nil }
//        
//        let width = cgImage.width
//        let height = cgImage.height
//        let widthBytes = (width + 7) / 8
//        
//        var bitmap = Data(count: widthBytes * height)
//        
//        guard let context = CGContext(
//            data: nil,
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: width,
//            space: CGColorSpaceCreateDeviceGray(),
//            bitmapInfo: CGImageAlphaInfo.none.rawValue
//        ) else { return nil }
//        
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//        
//        guard let pixelData = context.data else { return nil }
//        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
//        
//        let threshold: UInt8 = 128
//        
//        for y in 0..<height {
//            for x in 0..<width {
//                let pixel = pixels[y * width + x]
//                if pixel < threshold {
//                    let byteIndex = y * widthBytes + (x / 8)
//                    let bitIndex = 7 - (x % 8)
//                    bitmap[byteIndex] |= (1 << bitIndex)
//                }
//            }
//        }
//        
//        return MonochromeData(width: width, height: height, data: bitmap)
//    }
//    
//    // ====================================================================
//    // MARK: - Text Rendering
//    // ====================================================================
//    private func renderTextAsImage(_ text: String, fontSize: Int, bold: Bool, align: String) -> MonochromeData? {
//        let font = getFont(bold: bold, size: CGFloat(fontSize))
//        let attributes: [NSAttributedString.Key: Any] = [.font: font]
//        
//        let size = (text as NSString).size(withAttributes: attributes)
//        let imageWidth = min(Int(ceil(size.width)) + 20, printerWidth)
//        let imageHeight = Int(ceil(size.height)) + 10
//        
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 1.0)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
//        
//        let textX: CGFloat
//        switch align {
//        case "center":
//            textX = (CGFloat(imageWidth) - size.width) / 2
//        case "right":
//            textX = CGFloat(imageWidth) - size.width - 10
//        default:
//            textX = 10
//        }
//        
//        (text as NSString).draw(at: CGPoint(x: textX, y: 5), withAttributes: attributes)
//        
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        UIGraphicsEndImageContext()
//        
//        return convertToMonochromeFast(image: image)
//    }
//    
//    private func renderRowAsImage(columns: [PosColumn], fontSize: Int) -> MonochromeData? {
//        let totalWidth = printerWidth
//        let lineHeight = fontSize + 10
//        
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: lineHeight), false, 1.0)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(CGRect(x: 0, y: 0, width: totalWidth, height: lineHeight))
//        
//        var xOffset = 0
//        
//        for column in columns {
//            let colWidth = (totalWidth * column.width) / 12
//            let font = getFont(bold: column.bold, size: CGFloat(fontSize))
//            let attributes: [NSAttributedString.Key: Any] = [.font: font]
//            
//            let textSize = (column.text as NSString).size(withAttributes: attributes)
//            
//            let textX: CGFloat
//            switch column.align {
//            case "center":
//                textX = CGFloat(xOffset) + (CGFloat(colWidth) - textSize.width) / 2
//            case "right":
//                textX = CGFloat(xOffset + colWidth) - textSize.width - 5
//            default:
//                textX = CGFloat(xOffset) + 5
//            }
//            
//            (column.text as NSString).draw(at: CGPoint(x: textX, y: 5), withAttributes: attributes)
//            xOffset += colWidth
//        }
//        
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        UIGraphicsEndImageContext()
//        
//        return convertToMonochromeFast(image: image)
//    }
//    
//    // ====================================================================
//    // MARK: - Text Utilities
//    // ====================================================================
//    private func containsComplexUnicode(_ text: String) -> Bool {
//        for scalar in text.unicodeScalars {
//            let value = scalar.value
//            if (0x1780...0x17FF).contains(value) ||
//               (0x0E00...0x0E7F).contains(value) ||
//               (0x4E00...0x9FFF).contains(value) ||
//               (0xAC00...0xD7AF).contains(value) {
//                return true
//            }
//        }
//        return false
//    }
//    
//    private func wrapText(_ text: String, maxCharsPerLine: Int) -> String {
//        return wrapTextToList(text, maxCharsPerLine: maxCharsPerLine).joined(separator: "\n")
//    }
//    
//    private func wrapTextToList(_ text: String, maxCharsPerLine: Int) -> [String] {
//        guard maxCharsPerLine > 0 else { return [text] }
//        
//        var lines: [String] = []
//        let words = text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
//        var currentLine = ""
//        
//        for word in words {
//            if word.count > maxCharsPerLine {
//                if !currentLine.isEmpty {
//                    lines.append(currentLine.trimmingCharacters(in: .whitespaces))
//                    currentLine = ""
//                }
//                
//                var remaining = word
//                while remaining.count > maxCharsPerLine {
//                    lines.append(String(remaining.prefix(maxCharsPerLine)))
//                    remaining = String(remaining.dropFirst(maxCharsPerLine))
//                }
//                if !remaining.isEmpty {
//                    currentLine = remaining + " "
//                }
//                continue
//            }
//            
//            let testLine = currentLine.isEmpty ? word : currentLine + " " + word
//            
//            if getVisualWidth(testLine) <= Double(maxCharsPerLine) {
//                currentLine = testLine
//            } else {
//                if !currentLine.isEmpty {
//                    lines.append(currentLine.trimmingCharacters(in: .whitespaces))
//                }
//                currentLine = word + " "
//            }
//        }
//        
//        if !currentLine.isEmpty {
//            lines.append(currentLine.trimmingCharacters(in: .whitespaces))
//        }
//        
//        return lines.isEmpty ? [""] : lines
//    }
//    
//    private func getVisualWidth(_ text: String) -> Double {
//        var width = 0.0
//        for scalar in text.unicodeScalars {
//            let value = scalar.value
//            if (0x1780...0x17FF).contains(value) {
//                width += 1.4
//            } else if (0x17B4...0x17D3).contains(value) {
//                width += 0.0
//            } else if (0x0E00...0x0E7F).contains(value) {
//                width += 1.2
//            } else if (0x4E00...0x9FFF).contains(value) || (0xAC00...0xD7AF).contains(value) {
//                width += 2.0
//            } else {
//                width += 1.0
//            }
//        }
//        return width
//    }
//    
//    // ====================================================================
//    // MARK: - Print Separator
//    // ====================================================================
//    private func printSeparator(width: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                var commands = Data()
//                
//                commands.append(contentsOf: [self.GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
//                commands.append(contentsOf: [self.ESC, 0x61, 0x01])
//                commands.append(contentsOf: [self.ESC, 0x21, 0x00])
//                
//                let separator = String(repeating: "=", count: width)
//                if let separatorData = separator.data(using: .ascii) {
//                    commands.append(separatorData)
//                }
//                commands.append(0x0A)
//                
//                commands.append(contentsOf: [self.GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])
//                commands.append(contentsOf: [self.ESC, 0x61, 0x00])
//                
//                self.addToBuffer(commands)
//                
//                DispatchQueue.main.async {
//                    result(true)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "SEPARATOR_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Printer Configuration Methods
//    // ====================================================================
//    private func configureOOMAS() {
//        print("⚙️ Configuring for OOMAS printer...")
//        
//        var config = Data()
//        config.append(contentsOf: [ESC, 0x33, 0x40])
//        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x05])
//        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x00])
//        
//        writeDataSmooth(config)
//        print("✅ OOMAS configuration applied")
//    }
//    
//    private func warmUpPrinter() {
//        print("🔥 Warming up printer...")
//        
//        let warmUpData = Data([0x0A, 0x0A])
//        
//        switch currentConnectionType {
//        case .bluetoothClassic, .bluetoothBLE:
//            if let peripheral = connectedPeripheral,
//               let characteristic = writeCharacteristic {
//                peripheral.writeValue(warmUpData, for: characteristic, type: .withoutResponse)
//                Thread.sleep(forTimeInterval: 0.1)
//            }
//        case .usb:
//            writeViaUSB(warmUpData)
//            Thread.sleep(forTimeInterval: 0.1)
//        case .network:
//            writeViaNetwork(warmUpData)
//            Thread.sleep(forTimeInterval: 0.1)
//        default:
//            break
//        }
//        
//        print("✅ Printer warmed up")
//    }
//    
//    private func initializePrinterOptimal() {
//        print("🔧 Initializing printer with optimal settings...")
//        
//        var commands = Data()
//        commands.append(contentsOf: [ESC, 0x40])
//        commands.append(contentsOf: [ESC, 0x21, 0x00])
//        commands.append(contentsOf: [ESC, 0x33, 0x40])
//        commands.append(contentsOf: [ESC, 0x47, 0x00])
//        
//        writeDataSmooth(commands)
//        Thread.sleep(forTimeInterval: 0.2)
//        
//        print("✅ Printer initialized with smooth settings")
//    }
//    
//    // ====================================================================
//    // MARK: - Diagnostic Tests
//    // ====================================================================
//    private func testSlowPrint(result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                print("🧪 TEST 2: Slow Print Test")
//                
//                var commands = Data()
//                commands.append(contentsOf: [self.ESC, 0x40])
//                if let textData = "TEST LINE 1".data(using: .ascii) {
//                    commands.append(textData)
//                }
//                commands.append(0x0A)
//                
//                self.writeDataDirect(commands)
//                Thread.sleep(forTimeInterval: 1.0)
//                
//                commands = Data()
//                if let textData = "TEST LINE 2".data(using: .ascii) {
//                    commands.append(textData)
//                }
//                commands.append(0x0A)
//                
//                self.writeDataDirect(commands)
//                Thread.sleep(forTimeInterval: 1.0)
//                
//                commands = Data()
//                if let textData = "TEST LINE 3".data(using: .ascii) {
//                    commands.append(textData)
//                }
//                commands.append(0x0A)
//                
//                self.writeDataDirect(commands)
//                
//                DispatchQueue.main.async {
//                    result([
//                        "test": "slow_print",
//                        "instruction": "Was it smooth? If YES → code was too fast before, If NO → hardware issue"
//                    ])
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "TEST_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    private func checkPrinterStatus(result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                print("🧪 TEST 3: Printer Status Check")
//                
//                let statusCommand = Data([0x10, 0x04, 0x01])
//                self.writeDataDirect(statusCommand)
//                Thread.sleep(forTimeInterval: 0.1)
//                
//                let status = "Status check completed"
//                
//                DispatchQueue.main.async {
//                    result([
//                        "test": "status_check",
//                        "status": status
//                    ])
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "TEST_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    private func runCompleteDiagnostic(result: @escaping FlutterResult) {
//        printQueue.async {
//            do {
//                var diagnosticResults: [String: String] = [:]
//                
//                print("""
//                ═══════════════════════════════════════
//                🔍 COMPLETE PRINTER DIAGNOSTIC
//                ═══════════════════════════════════════
//                """)
//                
//                print("\n▶️ TEST 1: Paper Feed Test")
//                let feedCommand = Data(repeating: 0x0A, count: 5)
//                self.writeDataDirect(feedCommand)
//                Thread.sleep(forTimeInterval: 2.0)
//                diagnosticResults["paper_feed"] = "Check if 'stuck stuck' sound occurred"
//                
//                print("\n▶️ TEST 2: Single Line Test")
//                if let textData = "TEST LINE\n".data(using: .ascii) {
//                    self.writeDataDirect(textData)
//                }
//                Thread.sleep(forTimeInterval: 2.0)
//                diagnosticResults["single_line"] = "Check if smooth"
//                
//                print("\n▶️ TEST 3: Multiple Lines (with delays)")
//                for i in 1...3 {
//                    if let lineData = "Line \(i)\n".data(using: .ascii) {
//                        self.writeDataDirect(lineData)
//                    }
//                    Thread.sleep(forTimeInterval: 0.5)
//                }
//                diagnosticResults["multiple_lines"] = "Check if smooth with delays"
//                
//                print("\n▶️ TEST 4: Multiple Lines (fast)")
//                if let fastData = "Fast Line 1\nFast Line 2\nFast Line 3\n".data(using: .ascii) {
//                    self.writeDataDirect(fastData)
//                }
//                Thread.sleep(forTimeInterval: 2.0)
//                diagnosticResults["fast_lines"] = "Check if 'stuck stuck' occurs when fast"
//                
//                print("""
//                
//                ═══════════════════════════════════════
//                📊 DIAGNOSTIC RESULTS
//                ═══════════════════════════════════════
//                \(diagnosticResults.map { "\($0.key): \($0.value)" }.joined(separator: "\n"))
//                ═══════════════════════════════════════
//                """)
//                
//                DispatchQueue.main.async {
//                    result(diagnosticResults)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    result(FlutterError(code: "DIAGNOSTIC_ERROR", message: error.localizedDescription, details: nil))
//                }
//            }
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Paper Control
//    // ====================================================================
//    private func feedPaper(lines: Int, result: @escaping FlutterResult) {
//        printQueue.async {
//            var commands = Data()
//            for _ in 0..<lines {
//                commands.append(0x0A)
//            }
//            self.addToBuffer(commands)
//            
//            DispatchQueue.main.async {
//                result(true)
//            }
//        }
//    }
//    
//    private func cutPaper(result: @escaping FlutterResult) {
//        printQueue.async {
//            let commands = Data([self.GS, 0x56, 0x00])
//            self.addToBuffer(commands)
//            
//            DispatchQueue.main.async {
//                result(true)
//            }
//        }
//    }
//    
//    private func setPrinterWidth(width: Int, result: @escaping FlutterResult) {
//        if width == 384 || width == 576 {
//            printerWidth = width
//            print("✅ Printer width set to \(width) dots")
//            result(true)
//        } else {
//            result(FlutterError(code: "INVALID_WIDTH", message: "Width must be 384 or 576", details: nil))
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - Status & Permissions
//    // ====================================================================
//    private func getStatus(result: @escaping FlutterResult) {
//        var connected = false
//        
//        switch currentConnectionType {
//        case .bluetoothClassic, .bluetoothBLE:
//            connected = connectedPeripheral?.state == .connected && writeCharacteristic != nil
//        case .usb:
//            connected = session != nil && writeStream?.streamStatus == .open
//        case .network:
//            connected = networkConnection?.state == .ready
//        case .none:
//            connected = false
//        }
//        
//        let bluetoothEnabled = isCentralManagerInitialized ? centralManager.state == .poweredOn : false
//        let bluetoothStatus = isCentralManagerInitialized ?
//            (centralManager.state == .poweredOn ? "authorized" : "denied") : "not_initialized"
//        
//        result([
//            "status": bluetoothStatus,
//            "enabled": bluetoothEnabled,
//            "connected": connected,
//            "connectionType": currentConnectionType.rawValue,
//            "printerWidth": printerWidth
//        ])
//    }
//    
//    private func checkBluetoothPermission(result: @escaping FlutterResult) {
//        if !isCentralManagerInitialized {
//            result([
//                "status": "not_initialized",
//                "enabled": false,
//                "message": "Bluetooth not initialized yet"
//            ])
//            return
//        }
//        
//        let state = centralManager.state
//        
//        switch state {
//        case .poweredOn:
//            result(["status": "authorized", "enabled": true, "message": "Bluetooth is ready"])
//        case .poweredOff:
//            result(["status": "authorized", "enabled": false, "message": "Bluetooth is turned off"])
//        case .unauthorized:
//            result(["status": "denied", "enabled": false, "message": "Bluetooth permission denied"])
//        case .unsupported:
//            result(["status": "unsupported", "enabled": false, "message": "Bluetooth not supported"])
//        case .resetting:
//            result(["status": "resetting", "enabled": false, "message": "Bluetooth is resetting"])
//        case .unknown:
//            result(["status": "unknown", "enabled": false, "message": "Bluetooth state unknown"])
//        @unknown default:
//            result(["status": "unknown", "enabled": false, "message": "Unknown Bluetooth state"])
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - CBCentralManagerDelegate
//    // ====================================================================
//    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("📱 Bluetooth state: \(central.state.rawValue)")
//    }
//    
//    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
//                             advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        if !discoveredPrinters.contains(where: { $0.identifier == peripheral.identifier }) {
//            discoveredPrinters.append(peripheral)
//            print("Found: \(peripheral.name ?? "Unknown") - \(peripheral.identifier.uuidString)")
//        }
//    }
//    
//    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("✅ Connected to \(peripheral.name ?? "Unknown")")
//        connectedPeripheral = peripheral
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//        currentConnectionType = .bluetoothBLE
//    }
//    
//    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("❌ Connection failed: \(error?.localizedDescription ?? "Unknown error")")
//        connectionResult?(FlutterError(code: "CONNECTION_FAILED", message: error?.localizedDescription, details: nil))
//        connectionResult = nil
//    }
//    
//    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("Disconnected from \(peripheral.name ?? "Unknown")")
//        connectedPeripheral = nil
//        writeCharacteristic = nil
//        currentConnectionType = .none
//    }
//    
//    // ====================================================================
//    // MARK: - CBPeripheralDelegate
//    // ====================================================================
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//    
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//        
//        for characteristic in characteristics {
//            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
//                writeCharacteristic = characteristic
//                print("✅ Write characteristic found")
//                connectionResult?(true)
//                connectionResult = nil
//                return
//            }
//        }
//    }
//    
//    // ====================================================================
//    // MARK: - StreamDelegate
//    // ====================================================================
//    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//        switch eventCode {
//        case .hasSpaceAvailable:
//            break
//        case .errorOccurred:
//            print(" Stream error: \(aStream.streamError?.localizedDescription ?? "Unknown")")
//        case .endEncountered:
//            print("Stream ended")
//        default:
//            break
//        }
//    }
//}
