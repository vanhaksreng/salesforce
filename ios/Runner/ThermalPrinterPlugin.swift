import CoreBluetooth
import ExternalAccessory
import Flutter
import Network
import UIKit

// ====================================================================
// MARK: - Configuration
// ====================================================================
struct PrinterConfig {
    static let width58mm = 384
    static let width80mm = 576
    static let connectionTimeout: TimeInterval = 15.0
}

// ====================================================================
// MARK: - Printer Settings (Dynamic Configuration)
// ====================================================================
struct PrinterSettings {
    let width: Int
    let maxChars: Int
    let fontScaleSmall: CGFloat
    let fontScaleMedium: CGFloat
    let fontScaleLarge: CGFloat
    let fontScaleXLarge: CGFloat
    let lineSpacingTight: CGFloat
    let lineSpacingNormal: CGFloat
    let paddingSmall: CGFloat
    let paddingMedium: CGFloat
    let paddingLarge: CGFloat
    // ✅ NEW: Khmer-specific settings
    let khmerLineSpacingMultiplier: CGFloat
    let khmerPaddingMultiplier: CGFloat
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
    private var printerWidth = PrinterConfig.width80mm  // Default to 80mm

    // ESC/POS Commands
    private let ESC: UInt8 = 0x1B
    private let GS: UInt8 = 0x1D

    // Synchronization
    private let printQueue = DispatchQueue(
        label: "com.clearviewerp.thermal_printer", qos: .userInitiated)
    private let writeLock = NSLock()

    // Operation queue for sequential writing
    private var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()

    // Batching
    private var receiptBuffer = Data()
    private var isBatchMode = false

    // Font cache
    private var fontCache: [String: UIFont] = [:]

    // Pending results
    private var pendingResults: [String: FlutterResult] = [:]

    // MARK: - Helper function to get printer-specific settings
    private func getPrinterConfig() -> PrinterSettings {
        switch printerWidth {
        case PrinterConfig.width58mm:
            return PrinterSettings(
                width: 384,
                maxChars: 32,
                fontScaleSmall: 0.6,
                fontScaleMedium: 0.75,
                fontScaleLarge: 0.9,
                fontScaleXLarge: 1.2,
                lineSpacingTight: 0.95,
                lineSpacingNormal: 0.92,
                paddingSmall: 2.0,  // Increased from 1.0
                paddingMedium: 3.0,  // Increased from 2.0
                paddingLarge: 4.0,  // Increased from 3.0
                khmerLineSpacingMultiplier: 1.25,
                khmerPaddingMultiplier: 1.8
            )
        default:  // 80mm
            return PrinterSettings(
                width: 576,
                maxChars: 48,
                fontScaleSmall: 0.6,
                fontScaleMedium: 0.8,
                fontScaleLarge: 1.0,
                fontScaleXLarge: 1.5,
                lineSpacingTight: 0.90,
                lineSpacingNormal: 0.88,
                paddingSmall: 3.0,  // Increased from 2.0
                paddingMedium: 4.0,  // Increased from 3.0
                paddingLarge: 5.0,  // Increased from 4.0
                khmerLineSpacingMultiplier: 1.2,
                khmerPaddingMultiplier: 1.5
            )
        }
    }

    // MARK: - Plugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "thermal_printer", binaryMessenger: registrar.messenger())
        let instance = ThermalPrinterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.initialize()
    }

    // MARK: - Initialization
    private func initialize() {
        networkQueue = DispatchQueue(label: "com.clearviewerp.network_queue")
        preloadFonts()
    }

    private func ensureBluetoothManager() {
        if centralManager == nil {
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
                let type = args?["type"] as? String
            else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            connect(address: address, type: type, result: result)

        case "connectNetwork":
            guard let ipAddress = args?["ipAddress"] as? String else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing IP address", details: nil))
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
            printText(
                text: text, fontSize: fontSize, bold: bold, align: align,
                maxCharsPerLine: maxCharsPerLine, result: result)

        case "printRow":
            let columns = args?["columns"] as? [[String: Any]] ?? []
            let fontSize = args?["fontSize"] as? Int ?? 24
            printRow(columns: columns, fontSize: fontSize, result: result)

        case "printImage":
            guard let imageBytes = args?["imageBytes"] as? FlutterStandardTypedData else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                return
            }
            let width = args?["width"] as? Int ?? printerWidth
            let align = args?["align"] as? Int ?? 1
            printImage(imageBytes: imageBytes.data, width: width, align: align, result: result)

        case "printImageWithPadding":
            guard let imageBytes = args?["imageBytes"] as? FlutterStandardTypedData else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                return
            }
            let width = args?["width"] as? Int ?? 384
            let align = args?["align"] as? Int ?? 1
            let paperWidth = args?["paperWidth"] as? Int ?? 576
            printImageWithPadding(
                imageBytes: imageBytes.data, width: width, align: align, paperWidth: paperWidth,
                result: result)

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

        var initCommands = Data()
        initCommands.append(contentsOf: [ESC, 0x40])
        initCommands.append(contentsOf: [ESC, 0x74, 0x01])
        initCommands.append(contentsOf: [ESC, 0x33, 0x30])

        receiptBuffer.append(initCommands)
    }

    private func endBatchMode() {
        isBatchMode = false
        if !receiptBuffer.isEmpty {
            let originalSize = receiptBuffer.count

            let optimizedData = optimizeLineFeeds(data: receiptBuffer)

            writeDataSmooth(data: optimizedData)
            Thread.sleep(forTimeInterval: 0.050)

            receiptBuffer.removeAll()
        }
    }

    private func queueWrite(data: Data) {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            self.writeLock.lock()
            defer { self.writeLock.unlock() }

            self.writeDataSmooth(data: data)
            Thread.sleep(forTimeInterval: 0.010)
        }
    }

    private func addToBuffer(data: Data) {
        if isBatchMode {
            receiptBuffer.append(data)
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
            let feedCommand = Data(repeating: 0x0A, count: 10)
            self.writeDataSmooth(data: feedCommand)
            Thread.sleep(forTimeInterval: 2.0)

            DispatchQueue.main.async {
                result([
                    "test": "paper_feed",
                    "instruction":
                        "Did you hear 'stuck stuck' during paper feed? YES = Paper problem, NO = Code problem",
                ])
            }
        }
    }

    private func testSlowPrint(result: @escaping FlutterResult) {
        printQueue.async {

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
                    "instruction":
                        "Was it smooth? If YES → code was too fast before, If NO → hardware issue",
                ])
            }
        }
    }

    private func checkPrinterStatus(result: @escaping FlutterResult) {
        printQueue.async {
            let statusCommand = Data([0x10, 0x04, 0x01])
            self.writeDataSmooth(data: statusCommand)
            Thread.sleep(forTimeInterval: 0.1)

            DispatchQueue.main.async {
                result([
                    "test": "status_check",
                    "status": "Status check sent",
                ])
            }
        }
    }

    private func runCompleteDiagnostic(result: @escaping FlutterResult) {
        printQueue.async {
            var diagnosticResults: [String: String] = [:]

            let feedCommand = Data(repeating: 0x0A, count: 5)
            self.writeDataSmooth(data: feedCommand)
            Thread.sleep(forTimeInterval: 2.0)
            diagnosticResults["paper_feed"] = "Check if 'stuck stuck' sound occurred"

            let textCommand = "TEST LINE\n".data(using: .ascii)!
            self.writeDataSmooth(data: textCommand)
            Thread.sleep(forTimeInterval: 2.0)
            diagnosticResults["single_line"] = "Check if smooth"

            for i in 1...3 {
                let line = "Line \(i)\n".data(using: .ascii)!
                self.writeDataSmooth(data: line)
                Thread.sleep(forTimeInterval: 0.5)
            }
            diagnosticResults["multiple_lines"] = "Check if smooth with delays"

            let fastLines = "Fast Line 1\nFast Line 2\nFast Line 3\n".data(using: .ascii)!
            self.writeDataSmooth(data: fastLines)
            Thread.sleep(forTimeInterval: 2.0)
            diagnosticResults["fast_lines"] = "Check if 'stuck stuck' occurs when fast"

            DispatchQueue.main.async {
                result(diagnosticResults)
            }
        }
    }

    // ====================================================================
    // MARK: - Initialization
    // ====================================================================
    private func initializePrinterOptimal() {
        var commands = Data()
        commands.append(contentsOf: [ESC, 0x40])
        commands.append(contentsOf: [ESC, 0x21, 0x00])
        commands.append(contentsOf: [ESC, 0x33, 0x40])
        commands.append(contentsOf: [ESC, 0x47, 0x00])

        writeDataSmooth(data: commands)
        Thread.sleep(forTimeInterval: 0.2)
    }

    private func initializePrinterForSmoothPrinting() {

        var commands = Data()

        commands.append(contentsOf: [ESC, 0x40])
        writeBLEDataOptimized(data: commands)
        Thread.sleep(forTimeInterval: 0.12)

        commands.removeAll()

        commands.append(contentsOf: [ESC, 0x33, 0x30])
        commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x06])
        commands.append(contentsOf: [ESC, 0x21, 0x00])

        writeBLEDataOptimized(data: commands)
        Thread.sleep(forTimeInterval: 0.12)
    }

    private func configureForOOMAS() {

        var config = Data()
        config.append(contentsOf: [ESC, 0x33, 0x40])
        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x05])
        config.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x00])

        writeDataSmooth(data: config)
    }

    private func warmUpPrinter() {

        var warmUpData = Data()
        warmUpData.append(contentsOf: [ESC, 0x40])
        warmUpData.append(0x0A)

        writeDataSmooth(data: warmUpData)
        Thread.sleep(forTimeInterval: 0.1)
    }

    private func testPrint(_ message: String) {
        // print(message)
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
            result(
                FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil)
            )
        }
    }

    private func discoverAllPrinters(result: @escaping FlutterResult) {
        ensureBluetoothManager()
        var allPrinters: [[String: Any]] = []

        for peripheral in discoveredDevices {
            if let name = peripheral.name, !name.isEmpty {
                allPrinters.append([
                    "name": name,
                    "address": peripheral.identifier.uuidString,
                    "type": "bluetooth",
                ])
            }
        }

        let accessories = EAAccessoryManager.shared().connectedAccessories
        for accessory in accessories {
            allPrinters.append([
                "name": accessory.name,
                "address": "\(accessory.connectionID)",
                "type": "usb",
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

        manager.scanForPeripherals(
            withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.stopDiscovery()
        }
    }

    private func stopDiscovery() {
        centralManager?.stopScan()

        let printers =
            discoveredDevices
            .compactMap { peripheral -> [String: Any]? in
                guard let name = peripheral.name, !name.isEmpty else {
                    return nil
                }
                return [
                    "name": name,
                    "address": peripheral.identifier.uuidString,
                    "type": "bluetooth",
                ]
            }

        if let result = discoveryResult {
            result(printers)
            discoveryResult = nil
        }
    }

    private func discoverUSBPrinters(result: @escaping FlutterResult) {
        let accessories = EAAccessoryManager.shared().connectedAccessories
        let printers = accessories.map { accessory in
            return [
                "name": accessory.name,
                "address": "\(accessory.connectionID)",
                "type": "usb",
            ]
        }
        result(printers)
    }

    // ====================================================================
    // MARK: - Connection
    // ====================================================================
    private func connect(address: String, type: String, result: @escaping FlutterResult) {

        switch type {
        case "bluetooth", "ble":
            connectBluetooth(address: address, result: result)
        case "usb":
            result(
                FlutterError(
                    code: "NOT_IMPLEMENTED", message: "USB not yet implemented", details: nil))
        default:
            result(
                FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil)
            )
        }
    }

    private func connectBluetooth(address: String, result: @escaping FlutterResult) {
        guard let manager = centralManager else {
            result(FlutterError(code: "BT_NOT_READY", message: "Bluetooth not ready", details: nil))
            return
        }

        guard manager.state == .poweredOn else {
            result(
                FlutterError(
                    code: "BLUETOOTH_OFF", message: "Bluetooth is turned off", details: nil))
            return
        }

        if let uuid = UUID(uuidString: address) {
            let peripherals = manager.retrievePeripherals(withIdentifiers: [uuid])
            if let peripheral = peripherals.first {
                pendingResults[address] = result
                connectedPeripheral = peripheral
                peripheral.delegate = self
                manager.connect(peripheral, options: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + PrinterConfig.connectionTimeout) {
                    if self.pendingResults[address] != nil {
                        self.pendingResults.removeValue(forKey: address)
                        result(
                            FlutterError(
                                code: "TIMEOUT", message: "Connection timeout", details: nil))
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
                    result(
                        FlutterError(
                            code: "CONNECTION_FAILED", message: error.localizedDescription,
                            details: nil))
                }
            case .waiting(let error):
                break
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
    }

    // ====================================================================
    // MARK: - Writing Data
    // ====================================================================
    private func writeDataSmooth(data: Data) {
        let startTime = Date()

        switch currentConnectionType {
        case .bluetoothBLE:
            writeBLEDataOptimized(data: data)
            Thread.sleep(forTimeInterval: 0.025)

        case .network:
            writeNetworkOptimized(data: data)
            Thread.sleep(forTimeInterval: 0.020)

        default:
            return
        }

        let elapsed = Date().timeIntervalSince(startTime)
    }

    private func writeBLEDataOptimized(data: Data) {
        guard let peripheral = connectedPeripheral,
            let characteristic = writeCharacteristic
        else {
            return
        }

        let canWriteWithoutResponse = characteristic.properties.contains(.writeWithoutResponse)

        if canWriteWithoutResponse {
            let chunkSize = 128
            let reliableDelay: TimeInterval = 0.010

            var offset = 0
            var chunksWritten = 0

            while offset < data.count {
                let end = min(offset + chunkSize, data.count)
                let chunk = data[offset..<end]

                peripheral.writeValue(Data(chunk), for: characteristic, type: .withoutResponse)
                chunksWritten += 1

                Thread.sleep(forTimeInterval: reliableDelay)

                offset = end
            }

            Thread.sleep(forTimeInterval: 0.025)

        } else {
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
        }
    }

    private func writeNetworkOptimized(data: Data) {
        guard let connection = networkConnection else {
            return
        }

        if data.count < 1000 {
            connection.send(
                content: data,
                completion: .contentProcessed { error in
                    if let error = error {
                        // print("❌ Network error: \(error)")
                    }
                })
            return
        }

        let chunkSize = 512
        var offset = 0

        while offset < data.count {
            let end = min(offset + chunkSize, data.count)
            let chunk = data[offset..<end]

            connection.send(
                content: chunk,
                completion: .contentProcessed { error in
                    if let error = error {
                        // print("❌ Network error: \(error)")
                    }
                })

            if end < data.count {
                Thread.sleep(forTimeInterval: 0.01)
            }

            offset = end
        }
    }

    // ====================================================================
    // MARK: - Print Text
    // ====================================================================
    private func printText(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int,
        result: @escaping FlutterResult
    ) {
        let startTime = Date()

        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }

            do {
                let shouldRenderAsImage = fontSize < 20 || self.containsComplexUnicode(text: text)

                if shouldRenderAsImage {
                    guard
                        let imageData = self.renderTextToData(
                            text: text, fontSize: fontSize, bold: bold, align: align,
                            maxCharsPerLine: maxCharsPerLine)
                    else {
                        throw NSError(
                            domain: "PrintError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to render text"])
                    }

                    var finalData = Data([self.ESC, 0x61, 0x00])

                    // ✅ ADD EXTRA LINE FEED FOR KHMER
                    let hasKhmer = self.containsComplexUnicode(text: text)
                    if hasKhmer && fontSize < 18 {
                        finalData.append(imageData)
                        finalData.append(0x0A)  // Extra line feed
                    } else {
                        finalData.append(imageData)
                    }

                    self.addToBuffer(data: finalData)
                } else {
                    self.printSimpleTextInternalBatched(
                        text: text, fontSize: fontSize, bold: bold, align: align,
                        maxCharsPerLine: maxCharsPerLine)
                }

                let elapsed = Date().timeIntervalSince(startTime)

                DispatchQueue.main.async {
                    result(true)
                }
            } catch {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func printSimpleTextInternalBatched(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int
    ) {
        var commands = Data()

        let isSeparatorLine = text.filter({ $0 == "=" }).count > Int(Double(text.count) * 0.8)

        if isSeparatorLine {
            commands.append(contentsOf: [GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
        }

        commands.append(contentsOf: [ESC, 0x45, bold ? 0x01 : 0x00])

        let alignValue: UInt8
        switch align.lowercased() {
        case "center": alignValue = 0x01
        case "right": alignValue = 0x02
        default: alignValue = 0x00
        }
        commands.append(contentsOf: [ESC, 0x61, alignValue])

        let sizeCommand: UInt8
        if isSeparatorLine {
            sizeCommand = 0x00
        } else {
            switch fontSize {
            case ...17: sizeCommand = 0x01
            case 18...24: sizeCommand = 0x00
            case 25...30: sizeCommand = 0x11
            default: sizeCommand = 0x30
            }
        }
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])

        let wrappedText =
            maxCharsPerLine > 0 ? wrapText(text: text, maxChars: maxCharsPerLine) : text
        if let textData = wrappedText.data(using: .ascii) {
            commands.append(textData)
        }
        commands.append(0x0A)

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

            commands.append(contentsOf: [self.GS, 0x28, 0x4B, 0x02, 0x00, 0x30, 0x03])
            commands.append(contentsOf: [self.ESC, 0x61, 0x01])
            commands.append(contentsOf: [self.ESC, 0x21, 0x00])

            let separator = String(repeating: "=", count: width)
            if let data = separator.data(using: .ascii) {
                commands.append(data)
            }
            commands.append(0x0A)

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
    private func printRow(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult)
    {
        let startTime = Date()

        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }

            let posColumns = columns.compactMap { col -> PosColumn? in
                guard let text = col["text"] as? String,
                    let width = col["width"] as? Int
                else { return nil }
                let align = col["align"] as? String ?? "left"
                let bold = col["bold"] as? Bool ?? false
                return PosColumn(text: text, width: width, align: align, bold: bold)
            }

            let totalWidth = posColumns.reduce(0) { $0 + $1.width }
            if totalWidth > 12 {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "ROW_ERROR", message: "Total width exceeds 12: \(totalWidth)",
                            details: nil))
                }
                return
            }

            let hasComplexUnicode = posColumns.contains {
                self.containsComplexUnicode(text: $0.text)
            }
            let shouldRenderAsImage = fontSize < 20 || hasComplexUnicode

            if shouldRenderAsImage {
                guard let imageData = self.renderRowToData(columns: posColumns, fontSize: fontSize)
                else {
                    DispatchQueue.main.async {
                        result(
                            FlutterError(
                                code: "RENDER_ERROR", message: "Failed to render row", details: nil)
                        )
                    }
                    return
                }
                self.addToBuffer(data: imageData)
            } else {
                self.printRowUsingTextMethodBatched(columns: posColumns, fontSize: fontSize)
            }

            let elapsed = Date().timeIntervalSince(startTime)

            DispatchQueue.main.async {
                result(true)
            }
        }
    }

    private func printRowUsingTextMethodBatched(columns: [PosColumn], fontSize: Int) {
        let totalChars: Int
        switch fontSize {
        case ...17: totalChars = 48
        case 18...24: totalChars = 48
        case 25...30: totalChars = 32
        default: totalChars = 24
        }

        var commands = Data()

        let sizeCommand: UInt8
        switch fontSize {
        case ...17: sizeCommand = 0x01
        case 18...24: sizeCommand = 0x00
        case 25...30: sizeCommand = 0x11
        default: sizeCommand = 0x30
        }
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])

        let hasBold = columns.contains { $0.bold }
        if hasBold {
            commands.append(contentsOf: [ESC, 0x45, 0x01])
        }

        commands.append(contentsOf: [ESC, 0x61, 0x00])

        let columnTextLists = columns.map {
            column -> (lines: [String], width: Int, align: String) in
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
            return String(repeating: " ", count: leftPadding) + text
                + String(repeating: " ", count: width - text.count - leftPadding)
        case "right":
            return String(repeating: " ", count: width - text.count) + text
        default:
            return text + String(repeating: " ", count: width - text.count)
        }
    }

    // ====================================================================
    // MARK: - Print Image
    // ====================================================================
    private func printImage(
        imageBytes: Data, width: Int, align: Int, result: @escaping FlutterResult
    ) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }

            guard let image = UIImage(data: imageBytes) else {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
                }
                return
            }

            let alignment = ImageAlignment.from(align)
            let scaledImage = self.resizeImage(image: image, maxWidth: width)

            guard let monochromeData = self.convertToMonochrome(image: scaledImage) else {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "CONVERSION_ERROR", message: "Cannot convert to monochrome",
                            details: nil))
                }
                return
            }

            var commands = Data()

            commands.append(contentsOf: [self.ESC, 0x40])
            commands.append(contentsOf: [self.ESC, 0x61, UInt8(alignment.rawValue)])
            commands.append(contentsOf: [self.ESC, 0x33, 0x00])

            commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])

            let widthBytes = (monochromeData.width + 7) / 8
            commands.append(UInt8(widthBytes & 0xFF))
            commands.append(UInt8((widthBytes >> 8) & 0xFF))
            commands.append(UInt8(monochromeData.height & 0xFF))
            commands.append(UInt8((monochromeData.height >> 8) & 0xFF))

            commands.append(monochromeData.data)

            commands.append(contentsOf: [self.ESC, 0x33, 0x1E])
            commands.append(contentsOf: [self.ESC, 0x61, 0x00])

            self.writeDataSmooth(data: commands)

            DispatchQueue.main.async {
                result(true)
            }
        }
    }

    private func printImageWithPadding(
        imageBytes: Data, width: Int, align: Int, paperWidth: Int, result: @escaping FlutterResult
    ) {
        printQueue.async {
            self.writeLock.lock()
            defer { self.writeLock.unlock() }

            guard let image = UIImage(data: imageBytes) else {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
                }
                return
            }

            let alignment = ImageAlignment.from(align)
            let scaledImage = self.resizeImage(image: image, maxWidth: width)

            guard var monochromeData = self.convertToMonochrome(image: scaledImage) else {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: "CONVERSION_ERROR", message: "Cannot convert to monochrome",
                            details: nil))
                }
                return
            }

            if alignment != .left {
                monochromeData = self.addPaddingToMonochrome(
                    data: monochromeData, alignment: alignment, paperWidth: paperWidth)
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

        guard
            let context = CGContext(
                data: &pixels,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            )
        else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var grayscale = pixels.map { Float($0) }

        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let oldPixel = grayscale[index]

                let newPixel: Float = oldPixel > 128.0 ? 255.0 : 0.0
                grayscale[index] = newPixel

                let error = oldPixel - newPixel

                if x + 1 < width {
                    grayscale[index + 1] += error * 7.0 / 16.0
                }
                if y + 1 < height {
                    if x > 0 {
                        grayscale[index + width - 1] += error * 3.0 / 16.0
                    }
                    grayscale[index + width] += error * 5.0 / 16.0
                    if x + 1 < width {
                        grayscale[index + width + 1] += error * 1.0 / 16.0
                    }
                }
            }
        }

        let widthBytes = (width + 7) / 8
        var data = Data(count: widthBytes * height)

        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x

                if grayscale[index] < 128.0 {
                    let byteIndex = y * widthBytes + (x / 8)
                    let bitIndex = 7 - (x % 8)
                    data[byteIndex] |= (1 << bitIndex)
                }
            }
        }

        return MonochromeData(width: width, height: height, data: data)
    }

    private func addPaddingToMonochrome(
        data: MonochromeData, alignment: ImageAlignment, paperWidth: Int
    ) -> MonochromeData {
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

            // ✅ FIX: Use subdata to extract source data first
            let sourceStart = oldRowOffset
            let sourceEnd = oldRowOffset + currentWidthBytes
            let sourceData = data.data.subdata(in: sourceStart..<sourceEnd)
            
            // Then use replaceSubrange with the extracted data
            let destStart = newRowOffset + leftPaddingBytes
            let destEnd = newRowOffset + leftPaddingBytes + currentWidthBytes
            newData.replaceSubrange(destStart..<destEnd, with: sourceData)
        }

        return MonochromeData(width: paperWidth, height: data.height, data: newData)
    }

    // ====================================================================
    // MARK: - Text Rendering (IMPROVED FOR KHMER)
    // ====================================================================
    private func renderTextToData(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int
    ) -> Data? {
        let config = getPrinterConfig()
        let font = getFont(size: fontSize, bold: bold)

        let maxWidth = CGFloat(printerWidth)

        // ✅ INCREASED PADDING FOR KHMER
        let hasKhmer = containsComplexUnicode(text: text)
        let padding: CGFloat
        switch fontSize {
        case ..<14:
            padding = hasKhmer ? config.paddingSmall * 2.0 : config.paddingSmall
        case 14..<18:
            padding = hasKhmer ? config.paddingMedium * 1.8 : config.paddingMedium
        default:
            padding = hasKhmer ? config.paddingLarge * 1.5 : config.paddingLarge
        }

        // ✅ USE WIDTH-BASED WRAPPING
        let availableWidth = maxWidth - (padding * 2)
        let lines: [String]
        if maxCharsPerLine > 0 && maxCharsPerLine < 100 {
            lines = wrapTextToList(text: text, maxChars: maxCharsPerLine)
        } else {
            lines = wrapTextToWidth(text: text, maxWidth: availableWidth, font: font)
        }

        // ✅ INCREASED LINE SPACING FOR KHMER
        let lineSpacingMultiplier: CGFloat
        switch fontSize {
        case ..<14:
            lineSpacingMultiplier = hasKhmer ? 1.25 : config.lineSpacingTight
        case 14..<18:
            lineSpacingMultiplier = hasKhmer ? 1.15 : config.lineSpacingNormal
        default:
            lineSpacingMultiplier = hasKhmer ? 1.10 : 0.90
        }

        let lineHeight = font.lineHeight * lineSpacingMultiplier

        // ✅ ADD EXTRA SPACE FOR KHMER DESCENDERS
        let extraBottomPadding = hasKhmer ? padding * 0.5 : 0
        let totalHeight = CGFloat(lines.count) * lineHeight + padding * 2 + extraBottomPadding

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: maxWidth, height: totalHeight), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: totalHeight))

        let textColor = UIColor.black
        var y = padding

        for line in lines {
            if !line.isEmpty {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: textColor,
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

        print(
            "✅ Rendered \(lines.count) lines, total height: \(Int(totalHeight))px (Khmer spacing: \(hasKhmer ? "YES" : "NO"))"
        )
        return commands
    }

    private func renderRowToData(columns: [PosColumn], fontSize: Int) -> Data? {
        let config = getPrinterConfig()
        let font = getFont(size: fontSize, bold: false)

        let maxWidth = CGFloat(printerWidth)
        let columnWidths = columns.map { (maxWidth * CGFloat($0.width)) / 12.0 }

        // ✅ Check if ANY column has Khmer
        let hasKhmer = columns.contains { containsComplexUnicode(text: $0.text) }

        // Calculate lines for each column using width-based wrapping
        var columnLinesList: [[String]] = []
        var maxLines = 1

        for (index, column) in columns.enumerated() {
            let colWidth = columnWidths[index]
            let availableWidth = colWidth - 4.0

            let columnFont = getFont(size: fontSize, bold: column.bold)
            let hasColumnKhmer = containsComplexUnicode(text: column.text)

            let lines: [String]
            if hasColumnKhmer {
                lines = wrapTextToWidth(
                    text: column.text, maxWidth: availableWidth, font: columnFont)
            } else {
                lines = wrapTextToWidth(
                    text: column.text, maxWidth: availableWidth, font: columnFont)
            }

            columnLinesList.append(lines)
            maxLines = max(maxLines, lines.count)
        }

        // ✅ INCREASED LINE SPACING FOR KHMER ROWS
        let lineSpacingMultiplier: CGFloat
        switch fontSize {
        case ..<14:
            lineSpacingMultiplier = hasKhmer ? 1.25 : config.lineSpacingTight
        case 14..<18:
            lineSpacingMultiplier = hasKhmer ? 1.15 : config.lineSpacingNormal
        default:
            lineSpacingMultiplier = hasKhmer ? 1.10 : 0.90
        }

        let lineHeight = font.lineHeight * lineSpacingMultiplier

        // ✅ INCREASED PADDING FOR KHMER ROWS
        let verticalPadding: CGFloat
        switch fontSize {
        case ..<14:
            verticalPadding = hasKhmer ? config.paddingSmall * 2.0 : config.paddingSmall
        case 14..<18:
            verticalPadding = hasKhmer ? config.paddingMedium * 1.8 : config.paddingMedium
        default:
            verticalPadding = hasKhmer ? config.paddingLarge * 1.5 : config.paddingLarge
        }

        // ✅ ADD EXTRA BOTTOM SPACE FOR KHMER
        let extraBottomPadding = hasKhmer ? verticalPadding * 0.5 : 0
        let totalHeight = lineHeight * CGFloat(maxLines) + verticalPadding * 2 + extraBottomPadding

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: maxWidth, height: totalHeight), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: totalHeight))

        var currentX: CGFloat = 0
        for (index, column) in columns.enumerated() {
            let colWidth = columnWidths[index]
            let lines = columnLinesList[index]
            let columnFont = getFont(size: fontSize, bold: column.bold)

            for (lineIndex, line) in lines.enumerated() {
                if line.isEmpty { continue }

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: columnFont,
                    .foregroundColor: UIColor.black,
                ]

                let attributedString = NSAttributedString(string: line, attributes: attributes)
                let size = attributedString.size()

                let x: CGFloat
                switch column.align.lowercased() {
                case "center": x = currentX + (colWidth - size.width) / 2
                case "right": x = currentX + colWidth - size.width - 2.0
                default: x = currentX + 2.0
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

        print(
            "✅ Row rendered: \(columns.count) columns, \(maxLines) lines, height: \(Int(totalHeight))px (Khmer: \(hasKhmer ? "YES" : "NO"))"
        )
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

        let config = getPrinterConfig()
        let baseFontSize: CGFloat = 24.0
        let scaledFontSize: CGFloat

        switch size {
        case ...11: scaledFontSize = baseFontSize * config.fontScaleSmall
        case 12..<14: scaledFontSize = baseFontSize * 0.75
        case 14..<18: scaledFontSize = baseFontSize * config.fontScaleMedium
        case 18..<24: scaledFontSize = baseFontSize * config.fontScaleLarge
        case 24...30: scaledFontSize = baseFontSize * config.fontScaleXLarge
        default: scaledFontSize = baseFontSize * 2.0
        }

        var font: UIFont?

        if bold {
            font =
                UIFont(name: "NotoSansKhmer-Bold", size: scaledFontSize)
                ?? UIFont(name: "NotoSansKhmer-SemiBold", size: scaledFontSize)
                ?? UIFont(name: "NotoSansKhmer-Medium", size: scaledFontSize)
        }

        if font == nil {
            font = UIFont(name: "NotoSansKhmer-Regular", size: scaledFontSize)
        }

        if font == nil {
            font =
                bold
                ? UIFont.boldSystemFont(ofSize: scaledFontSize)
                : UIFont.systemFont(ofSize: scaledFontSize)
        }

        fontCache[fontKey] = font!
        return font!
    }

    private func preloadFonts() {
        DispatchQueue.global(qos: .background).async {
            _ = self.getFont(size: 24, bold: false)
            _ = self.getFont(size: 24, bold: true)
        }
    }

    // ====================================================================
    // MARK: - Text Utilities (IMPROVED FOR KHMER)
    // ====================================================================
    private func containsComplexUnicode(text: String) -> Bool {
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if (0x1780...0x17FF).contains(value) || (0x0E00...0x0E7F).contains(value)
                || (0x4E00...0x9FFF).contains(value) || (0xAC00...0xD7AF).contains(value)
            {
                return true
            }
        }
        return false
    }

    /**
     * Check if character is a Khmer combining mark
     */
    private func isKhmerCombiningMark(_ scalar: Unicode.Scalar) -> Bool {
        let value = scalar.value
        return (0x17B6...0x17BD).contains(value)  // Khmer vowels
            || (0x17C0...0x17D3).contains(value)  // Khmer signs
            || value == 0x17D2  // Coeng
    }

    private func wrapText(text: String, maxChars: Int) -> String {
        return wrapTextToList(text: text, maxChars: maxChars).joined(separator: "\n")
    }

    /**
     * Improved wrapTextToList - handles Khmer combining characters
     */
    private func wrapTextToList(text: String, maxChars: Int) -> [String] {
        guard maxChars > 0 else { return [text] }
        guard !text.isEmpty else { return [""] }

        var lines: [String] = []
        let hasKhmer = containsComplexUnicode(text: text)

        if hasKhmer {
            // ✅ KHMER TEXT: Use grapheme-aware wrapping
            var lineStart = text.startIndex
            var graphemeCount = 0
            var lastSafeBreak = text.startIndex

            var currentIndex = text.startIndex
            while currentIndex < text.endIndex {
                let nextIndex = text.index(after: currentIndex)
                graphemeCount += 1

                // Check if we can break here (not a combining mark)
                if currentIndex < text.endIndex {
                    let char = text[currentIndex]
                    let isCombining = char.unicodeScalars.contains { isKhmerCombiningMark($0) }

                    if !isCombining {
                        lastSafeBreak = nextIndex
                    }
                }

                // Need to wrap
                if graphemeCount >= maxChars && lastSafeBreak > lineStart {
                    let line = String(text[lineStart..<lastSafeBreak]).trimmingCharacters(
                        in: .whitespaces)
                    if !line.isEmpty {
                        lines.append(line)
                    }
                    lineStart = lastSafeBreak
                    graphemeCount = 0
                    lastSafeBreak = lineStart

                    // Skip spaces
                    while lineStart < text.endIndex && text[lineStart] == " " {
                        lineStart = text.index(after: lineStart)
                    }
                }

                currentIndex = nextIndex
            }

            // Add remaining
            if lineStart < text.endIndex {
                let line = String(text[lineStart...]).trimmingCharacters(in: .whitespaces)
                if !line.isEmpty {
                    lines.append(line)
                }
            }

        } else {
            // ✅ LATIN TEXT: Use word-based wrapping
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

                if testLine.count <= maxChars {
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
        }

        return lines.isEmpty ? [""] : lines
    }

    /**
     * Wrap text based on actual rendered width (BEST for Khmer)
     */
    private func wrapTextToWidth(text: String, maxWidth: CGFloat, font: UIFont) -> [String] {
        guard !text.isEmpty else { return [""] }
        guard maxWidth > 0 else { return [text] }

        var lines: [String] = []
        var lineStart = text.startIndex
        var lastGoodBreakPoint = text.startIndex
        var lastBreakPointWidth: CGFloat = 0

        var currentIndex = text.startIndex
        var previousIndex = text.startIndex

        while currentIndex < text.endIndex {
            let nextIndex = text.index(after: currentIndex)

            // Measure width from line start to current position
            let segment = String(text[lineStart..<nextIndex])
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let segmentWidth = (segment as NSString).size(withAttributes: attributes).width

            // Check if current character is a space (good break point)
            let currentChar = text[currentIndex]
            if currentChar == " " || currentChar == "\n" {
                lastGoodBreakPoint = nextIndex
                lastBreakPointWidth = segmentWidth
            }

            // Check for manual line break
            if currentChar == "\n" {
                let line = String(text[lineStart..<currentIndex]).trimmingCharacters(
                    in: .whitespaces)
                if !line.isEmpty {
                    lines.append(line)
                }
                lineStart = nextIndex
                lastGoodBreakPoint = nextIndex
                lastBreakPointWidth = 0
                previousIndex = nextIndex
                currentIndex = nextIndex
                continue
            }

            // Line too long
            if segmentWidth > maxWidth {
                let breakPoint =
                    (lastGoodBreakPoint > lineStart && lastBreakPointWidth > maxWidth * 0.4)
                    ? lastGoodBreakPoint
                    : previousIndex

                if breakPoint > lineStart {
                    let line = String(text[lineStart..<breakPoint]).trimmingCharacters(
                        in: .whitespaces)
                    if !line.isEmpty {
                        lines.append(line)
                    }

                    lineStart = breakPoint
                    lastGoodBreakPoint = breakPoint
                    lastBreakPointWidth = 0

                    // Skip spaces
                    while lineStart < text.endIndex && text[lineStart] == " " {
                        lineStart = text.index(after: lineStart)
                    }

                    currentIndex = lineStart
                    previousIndex = lineStart
                    continue
                }
            }

            previousIndex = currentIndex
            currentIndex = nextIndex
        }

        // Add remaining text
        if lineStart < text.endIndex {
            let lastLine = String(text[lineStart...]).trimmingCharacters(in: .whitespaces)
            if !lastLine.isEmpty {
                lines.append(lastLine)
            }
        }

        return lines.isEmpty ? [""] : lines
    }

    private func getVisualWidth(text: String) -> Double {
        var width = 0.0
        for scalar in text.unicodeScalars {
            let value = scalar.value
            switch value {
            case 0x1780...0x17FF: width += 0.75
            case 0x17B4...0x17DD: width += 0.0
            case 0x0E00...0x0E7F: width += 1.2
            case 0x4E00...0x9FFF, 0xAC00...0xD7AF: width += 2.0
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
            "connectionType": String(describing: currentConnectionType).lowercased(),
            "printerWidth": printerWidth,
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
    }

    public func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    public func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        let address = peripheral.identifier.uuidString
        if let result = pendingResults.removeValue(forKey: address) {
            DispatchQueue.main.async {
                result(
                    FlutterError(
                        code: "CONNECTION_FAILED", message: error?.localizedDescription,
                        details: nil))
            }
        }
    }

    public func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
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
            return
        }

        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        guard error == nil else {
            return
        }

        for characteristic in service.characteristics ?? [] {
            if characteristic.properties.contains(.write)
                || characteristic.properties.contains(.writeWithoutResponse)
            {
                writeCharacteristic = characteristic
                currentConnectionType = .bluetoothBLE

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

        let address = peripheral.identifier.uuidString
        if let result = pendingResults.removeValue(forKey: address) {
            DispatchQueue.main.async {
                result(
                    FlutterError(
                        code: "NO_CHARACTERISTIC", message: "No writable characteristic found",
                        details: nil))
            }
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        if let error = error {
        }
    }
}
