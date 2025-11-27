import CoreBluetooth
import ExternalAccessory
import Flutter
import Network
import UIKit

public class ThermalPrinterPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate,
    CBPeripheralDelegate, EAAccessoryDelegate, StreamDelegate
{

    // Bluetooth & BLE
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var discoveredPrinters: [CBPeripheral] = []
    private var scanResult: FlutterResult?

    // USB (External Accessory)
    private var accessory: EAAccessory?
    private var session: EASession?
    private var writeStream: OutputStream?

    // Network
    private var networkConnection: NWConnection?

    // Current connection type
    private var currentConnectionType: String = "bluetooth"
    private var isScanning = false
    private var connectionResult: FlutterResult?

    // Printer settings
    private var printerWidth: Int = 576  // Default 80mm (576px)

    // ESC/POS Commands
    private let ESC: UInt8 = 0x1B
    private let GS: UInt8 = 0x1D

    // MARK: - Font Cache
    private var fontCache: [String: UIFont] = [:]

    public override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self, queue: DispatchQueue.main,
            options: [
                CBCentralManagerOptionShowPowerAlertKey: true
            ])
        print("🔵 ThermalPrinterPlugin initialized")

        // Preload fonts
        preloadFonts()
    }

    // MARK: - Font Management
    private func preloadFonts() {
        print("🔄 Preloading fonts...")
        _ = getFont(bold: false, size: 24)
        _ = getFont(bold: true, size: 24)
        print("✅ Fonts preloaded")
    }

//    private func getFont(bold: Bool, size: CGFloat) -> UIFont {
//        let key = "\(bold ? "bold" : "regular")-\(size)"
//
//        if let cached = fontCache[key] {
//            return cached
//        }
//
//        let font: UIFont
//        if bold {
//            font = UIFont.boldSystemFont(ofSize: size)
//        } else {
//            font = UIFont.systemFont(ofSize: size)
//        }
//
//        fontCache[key] = font
//        return font
//    }
    
    private func getFont(bold: Bool, size: CGFloat) -> UIFont {
        let key = "\(bold ? "bold" : "regular")-\(size)"

        // Cached?
        if let cached = fontCache[key] {
            return cached
        }

        // Matching Android behavior
        let fontName = bold
            ? "NotoSansKhmer-Bold"
            : "NotoSansKhmer-Regular"

        // Load custom font
        let font = UIFont(name: fontName, size: size)
            ?? UIFont.systemFont(ofSize: size)   // fallback

        // Cache
        fontCache[key] = font
        return font
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "thermal_printer", binaryMessenger: registrar.messenger())
        let instance = ThermalPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "discoverPrinters":
            guard let args = call.arguments as? [String: Any],
                let type = args["type"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing type", details: nil))
                return
            }
            discoverPrinters(type: type, result: result)

        case "discoverAllPrinters":
            discoverAllPrinters(result: result)

        case "connect":
            guard let args = call.arguments as? [String: Any],
                let address = args["address"] as? String,
                let type = args["type"] as? String
            else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            connect(address: address, type: type, result: result)

        case "connectNetwork":
            guard let args = call.arguments as? [String: Any],
                let ipAddress = args["ipAddress"] as? String
            else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing IP address", details: nil))
                return
            }
            let port = args["port"] as? Int ?? 9100
            connectNetwork(ipAddress: ipAddress, port: port, result: result)

        case "disconnect":
            disconnect(result: result)

        case "printText":
            guard let args = call.arguments as? [String: Any],
                let text = args["text"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing text", details: nil))
                return
            }
            let fontSize = args["fontSize"] as? Int ?? 24
            let bold = args["bold"] as? Bool ?? false
            let align = args["align"] as? String ?? "left"
            let maxCharsPerLine = args["maxCharsPerLine"] as? Int ?? 0

            printText(
                text: text, fontSize: fontSize, bold: bold, align: align,
                maxCharsPerLine: maxCharsPerLine, result: result)

        case "printRow":
            guard let args = call.arguments as? [String: Any],
                let columns = args["columns"] as? [[String: Any]]
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing columns", details: nil))
                return
            }
            let fontSize = args["fontSize"] as? Int ?? 24
            printRow(columns: columns, fontSize: fontSize, result: result)

        case "printImage":
            guard let args = call.arguments as? [String: Any],
                let imageBytes = args["imageBytes"] as? FlutterStandardTypedData
            else {
                result(
                    FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                return
            }
            let width = args["width"] as? Int ?? 384
            printImage(imageBytes: imageBytes.data, width: width, result: result)

        case "feedPaper":
            guard let args = call.arguments as? [String: Any],
                let lines = args["lines"] as? Int
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing lines", details: nil))
                return
            }
            feedPaper(lines: lines, result: result)

        case "cutPaper":
            cutPaper(result: result)

        case "getStatus":
            getStatus(result: result)

        case "setPrinterWidth":
            guard let args = call.arguments as? [String: Any],
                let width = args["width"] as? Int
            else {
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

    // MARK: - Discovery (keeping existing discovery code)
    private func discoverPrinters(type: String, result: @escaping FlutterResult) {
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
        scanResult = result
        discoveredPrinters.removeAll()
        isScanning = true

        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: false
                ])
        } else if centralManager.state == .poweredOff {
            isScanning = false
            result(
                FlutterError(
                    code: "BLUETOOTH_OFF", message: "Bluetooth is turned off.", details: nil))
            scanResult = nil
            return
        } else if centralManager.state == .unauthorized {
            isScanning = false
            result(
                FlutterError(
                    code: "PERMISSION_DENIED", message: "Bluetooth permission denied.", details: nil
                ))
            scanResult = nil
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.isScanning {
                self.isScanning = false
                self.centralManager.stopScan()
            }

            var allPrinters: [[String: Any]] = []

            for printer in self.discoveredPrinters {
                allPrinters.append([
                    "name": printer.name ?? "Unknown Device",
                    "address": printer.identifier.uuidString,
                    "type": "ble",
                ])
            }

            let accessories = EAAccessoryManager.shared().connectedAccessories
            for acc in accessories {
                allPrinters.append([
                    "name": acc.name,
                    "address": String(acc.connectionID),
                    "type": "usb",
                ])
            }

            if let callback = self.scanResult {
                callback(allPrinters)
                self.scanResult = nil
            }
        }
    }
    
    private func discoverBluetoothPrinters(result: @escaping FlutterResult) {
        scanResult = result
        discoveredPrinters.removeAll()
        isScanning = true
        
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: false
                ])
        } else if centralManager.state == .poweredOff {
            isScanning = false
            result(
                FlutterError(
                    code: "BLUETOOTH_OFF",
                    message: "Bluetooth is turned off",
                    details: nil))
            scanResult = nil
            return
        } else if centralManager.state == .unauthorized {
            isScanning = false
            result(
                FlutterError(
                    code: "PERMISSION_DENIED",
                    message: "Bluetooth permission denied",
                    details: nil)
            )
            scanResult = nil
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.isScanning {
                self.isScanning = false
                self.centralManager.stopScan()
            }
            
            // Filter out devices without a name
            let printers = self.discoveredPrinters
                .filter { $0.name != nil && !$0.name!.isEmpty }
                .map { printer in
                    return [
                        "name": printer.name!,
                        "address": printer.identifier.uuidString,
                        "type": "ble",
                    ] as [String: Any]
                }
            
            if let callback = self.scanResult {
                callback(printers)
                self.scanResult = nil
            }
        }
    }

//    private func discoverBluetoothPrinters(result: @escaping FlutterResult) {
//        scanResult = result
//        discoveredPrinters.removeAll()
//        isScanning = true
//
//        if centralManager.state == .poweredOn {
//            centralManager.scanForPeripherals(
//                withServices: nil,
//                options: [
//                    CBCentralManagerScanOptionAllowDuplicatesKey: false
//                ])
//        } else if centralManager.state == .poweredOff {
//            isScanning = false
//            result(
//                FlutterError(
//                    code: "BLUETOOTH_OFF", message: "Bluetooth is turned off", details: nil))
//            scanResult = nil
//            return
//        } else if centralManager.state == .unauthorized {
//            isScanning = false
//            result(
//                FlutterError(
//                    code: "PERMISSION_DENIED", message: "Bluetooth permission denied", details: nil)
//            )
//            scanResult = nil
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if self.isScanning {
//                self.isScanning = false
//                self.centralManager.stopScan()
//            }
//
//            let printers = self.discoveredPrinters.map { printer in
//                return [
//                    "name": printer.name ?? "Unknown Device",
//                    "address": printer.identifier.uuidString,
//                    "type": "ble",
//                ] as [String: Any]
//            }
//
//            if let callback = self.scanResult {
//                callback(printers)
//                self.scanResult = nil
//            }
//        }
//    }

    private func discoverUSBPrinters(result: @escaping FlutterResult) {
        let accessories = EAAccessoryManager.shared().connectedAccessories
        let printers = accessories.map { acc in
            return [
                "name": acc.name,
                "address": String(acc.connectionID),
                "type": "usb",
            ]
        }
        result(printers)
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && isScanning {
            central.scanForPeripherals(
                withServices: nil,
                options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: false
                ])
        }
    }

    public func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        if !discoveredPrinters.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPrinters.append(peripheral)
        }
    }

    // MARK: - Connection (keeping existing connection code)
    private func connect(address: String, type: String, result: @escaping FlutterResult) {
        currentConnectionType = type

        switch type {
        case "bluetooth", "ble":
            connectBluetooth(address: address, result: result)
        case "usb":
            connectUSB(connectionID: UInt(address) ?? 0, result: result)
        default:
            result(
                FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil)
            )
        }
    }

    private func connectBluetooth(address: String, result: @escaping FlutterResult) {
        guard let printer = discoveredPrinters.first(where: { $0.identifier.uuidString == address })
        else {
            result(FlutterError(code: "NOT_FOUND", message: "Printer not found", details: nil))
            return
        }

        connectionResult = result
        connectedPeripheral = printer
        printer.delegate = self
        centralManager.connect(printer, options: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if let callback = self.connectionResult {
                self.connectionResult = nil
                callback(false)
            }
        }
    }

    private func connectUSB(connectionID: UInt, result: @escaping FlutterResult) {
        let accessories = EAAccessoryManager.shared().connectedAccessories
        guard let acc = accessories.first(where: { $0.connectionID == connectionID }) else {
            result(
                FlutterError(code: "NOT_FOUND", message: "USB accessory not found", details: nil))
            return
        }

        accessory = acc
        guard let protocolString = acc.protocolStrings.first else {
            result(
                FlutterError(code: "NO_PROTOCOL", message: "No protocol available", details: nil))
            return
        }

        session = EASession(accessory: acc, forProtocol: protocolString)
        writeStream = session?.outputStream
        writeStream?.delegate = self
        writeStream?.schedule(in: .current, forMode: .default)
        writeStream?.open()

        result(true)
    }

    private func connectNetwork(ipAddress: String, port: Int, result: @escaping FlutterResult) {
        let host = NWEndpoint.Host(ipAddress)
        let port = NWEndpoint.Port(integerLiteral: UInt16(port))

        networkConnection = NWConnection(host: host, port: port, using: .tcp)

        var hasResponded = false

        networkConnection?.stateUpdateHandler = { [weak self] state in
            guard let self = self, !hasResponded else { return }

            switch state {
            case .ready:
                hasResponded = true
                result(true)
            case .failed(let error):
                hasResponded = true
                result(
                    FlutterError(
                        code: "CONNECTION_FAILED", message: error.localizedDescription, details: nil
                    ))
            default:
                break
            }
        }

        networkConnection?.start(queue: .global())
        currentConnectionType = "network"

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if !hasResponded {
                hasResponded = true
                result(false)
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    public func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        if let callback = connectionResult {
            connectionResult = nil
            callback(false)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.write)
                || characteristic.properties.contains(.writeWithoutResponse)
            {
                writeCharacteristic = characteristic

                if let callback = connectionResult {
                    connectionResult = nil
                    callback(true)
                }
                break
            }
        }
    }

    private func disconnect(result: @escaping FlutterResult) {
        switch currentConnectionType {
        case "bluetooth", "ble":
            if let peripheral = connectedPeripheral {
                centralManager.cancelPeripheralConnection(peripheral)
                connectedPeripheral = nil
                writeCharacteristic = nil
            }
        case "usb":
            writeStream?.close()
            writeStream?.remove(from: .current, forMode: .default)
            session = nil
            accessory = nil
        case "network":
            networkConnection?.cancel()
            networkConnection = nil
        default:
            break
        }
        result(true)
    }

    // MARK: - Write Data Method
    private func writeDataSmooth(_ data: Data) {
        let startTime = Date()

        switch currentConnectionType {
        case "bluetooth", "ble":
            guard let peripheral = connectedPeripheral,
                let characteristic = writeCharacteristic
            else {
                print("❌ WRITE: No peripheral/characteristic")
                return
            }

            let chunkSize = data.count > 2000 ? 256 : 512
            var offset = 0
            var chunkCount = 0

            while offset < data.count {
                let end = min(offset + chunkSize, data.count)
                let chunk = data.subdata(in: offset..<end)

                peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
                offset = end
                chunkCount += 1

                // Small delay for large data
                if data.count > 2000 {
                    Thread.sleep(forTimeInterval: 0.015)
                }
            }

            let writeTime = Date().timeIntervalSince(startTime) * 1000
            print(
                "📡 BLE WRITE: \(data.count) bytes in \(chunkCount) chunks, took \(Int(writeTime))ms"
            )

        case "usb":
            guard let stream = writeStream, stream.hasSpaceAvailable else {
                print("❌ WRITE: USB stream not available")
                return
            }
            let bytes = [UInt8](data)
            stream.write(bytes, maxLength: bytes.count)

            let writeTime = Date().timeIntervalSince(startTime) * 1000
            print("📡 USB WRITE: \(data.count) bytes, took \(Int(writeTime))ms")

        case "network":
            guard let connection = networkConnection else {
                print("❌ WRITE: Network connection not available")
                return
            }
            connection.send(content: data, completion: .contentProcessed { _ in })

            let writeTime = Date().timeIntervalSince(startTime) * 1000
            print("📡 NET WRITE: \(data.count) bytes, took \(Int(writeTime))ms")

        default:
            break
        }
    }

    // MARK: - Print Text
    private func printText(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int,
        result: @escaping FlutterResult
    ) {
        let startTime = Date()
        let preview = text.prefix(30)

        if containsComplexUnicode(text) {
            print("🖼️ SWIFT: Rendering Complex text (Image): \"\(preview)...\"")

            DispatchQueue.global(qos: .userInitiated).async {
                let renderStart = Date()

                guard
                    let imageData = self.renderTextToData(
                        text: text,
                        fontSize: fontSize,
                        bold: bold,
                        align: align,
                        maxCharsPerLine: maxCharsPerLine
                    )
                else {
                    DispatchQueue.main.async {
                        result(
                            FlutterError(
                                code: "RENDER_ERROR", message: "Failed to render", details: nil))
                    }
                    return
                }

                let renderTime = Date().timeIntervalSince(renderStart) * 1000
                print("✅ SWIFT: Rendered in \(Int(renderTime))ms, size: \(imageData.count) bytes")

                DispatchQueue.main.async {
                    self.writeDataSmooth(imageData)
                    let totalTime = Date().timeIntervalSince(startTime) * 1000
                    print("🖨️ SWIFT: Sent, total: \(Int(totalTime))ms")
                    result(true)
                }
            }
        } else {
            print("🔵 SWIFT: Printing English text: \"\(preview)\"")
            printSimpleText(
                text: text, fontSize: fontSize, bold: bold, align: align,
                maxCharsPerLine: maxCharsPerLine, result: result)

            let totalTime = Date().timeIntervalSince(startTime) * 1000
            print("⚡ SWIFT: English printed in \(Int(totalTime))ms")
        }
    }

    private func containsComplexUnicode(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if (value >= 0x1780 && value <= 0x17FF)  // Khmer
                || (value >= 0x0E00 && value <= 0x0E7F)  // Thai
                || (value >= 0x4E00 && value <= 0x9FFF)  // CJK
                || (value >= 0xAC00 && value <= 0xD7AF)
            {  // Hangul
                return true
            }
        }
        return false
    }

    private func printSimpleText(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int,
        result: @escaping FlutterResult
    ) {
        var commands = Data()

        commands.append(contentsOf: [ESC, 0x40])
        commands.append(contentsOf: [ESC, 0x74, 0x01])

        if bold {
            commands.append(contentsOf: [ESC, 0x45, 0x01])
        }

        let alignCode: UInt8
        switch align.lowercased() {
        case "center": alignCode = 0x01
        case "right": alignCode = 0x02
        default: alignCode = 0x00
        }
        commands.append(contentsOf: [ESC, 0x61, alignCode])

        let sizeCommand: UInt8
        if fontSize > 30 {
            sizeCommand = 0x30
        } else if fontSize > 24 {
            sizeCommand = 0x11
        } else {
            sizeCommand = 0x00
        }
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])

        let textToProcess: String
        if maxCharsPerLine > 0 {
            textToProcess = wrapText(text, maxCharsPerLine: maxCharsPerLine)
        } else {
            textToProcess = text
        }

        if let textData = textToProcess.data(using: .utf8) {
            commands.append(textData)
        }

        commands.append(contentsOf: [0x0A])

        if bold {
            commands.append(contentsOf: [ESC, 0x45, 0x00])
        }
        commands.append(contentsOf: [ESC, 0x61, 0x00])

        DispatchQueue.main.async {
            self.writeDataSmooth(commands)
            result(true)
        }
    }

    private func wrapText(_ text: String, maxCharsPerLine: Int) -> String {
        var result = ""
        var currentLine = ""
        let words = text.components(separatedBy: " ")

        for word in words {
            if currentLine.isEmpty {
                currentLine = word
            } else if (currentLine.count + 1 + word.count) <= maxCharsPerLine {
                currentLine += " " + word
            } else {
                result += currentLine + "\n"
                currentLine = word
            }
        }

        if !currentLine.isEmpty {
            result += currentLine
        }

        return result
    }

    // MARK: - Render Text to Image Data (OPTIMIZED WITH LARGER TEXT)
    private func renderTextToData(
        text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int
    ) -> Data? {
        // INCREASED BASE SIZE: Larger Khmer text rendering
        let baseFontSize: CGFloat = 24.0  // Increased from 18
        let scaledFontSize: CGFloat

        if fontSize > 30 {
            scaledFontSize = baseFontSize * 2.0  // Increased from 1.6
        } else if fontSize > 24 {
            scaledFontSize = baseFontSize * 1.5  // Increased from 1.2
        } else {
            scaledFontSize = baseFontSize
        }

        print("📏 SWIFT: fontSize=\(fontSize) -> scaledFontSize=\(scaledFontSize), bold=\(bold)")

        // Use cached font
        let font = getFont(bold: bold, size: scaledFontSize)

        let maxWidth = CGFloat(self.printerWidth)
        let padding: CGFloat = 2.0  // Slightly more padding
        let availableWidth = maxWidth - (padding * 2)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 0

        switch align.lowercased() {
        case "center": paragraphStyle.alignment = .center
        case "right": paragraphStyle.alignment = .right
        default: paragraphStyle.alignment = .left
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle,
        ]

        let textToRender =
            maxCharsPerLine > 0 ? self.wrapText(text, maxCharsPerLine: maxCharsPerLine) : text

        // Calculate size
        let size = (textToRender as NSString).size(withAttributes: attributes)
        let height = ceil(size.height) + padding * 2

        // Create image context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: height), true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: height))

        // Disable smoothing for sharper monochrome
        context.setShouldSmoothFonts(false)
        context.setAllowsFontSmoothing(false)
        context.setAllowsAntialiasing(false)

        // Draw text
        let drawRect = CGRect(x: padding, y: padding, width: availableWidth, height: size.height)
        (textToRender as NSString).draw(in: drawRect, withAttributes: attributes)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let bitmap = self.convertToMonochromeFast(image: image) else {
            return nil
        }

        // Build ESC/POS command
        var commands = Data()
        commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])

        let widthBytes = (bitmap.width + 7) / 8
        commands.append(UInt8(widthBytes & 0xFF))
        commands.append(UInt8((widthBytes >> 8) & 0xFF))
        commands.append(UInt8(bitmap.height & 0xFF))
        commands.append(UInt8((bitmap.height >> 8) & 0xFF))
        commands.append(bitmap.data)

        return commands
    }

    // MARK: - Convert to Monochrome
    private func convertToMonochromeFast(image: UIImage) -> (width: Int, height: Int, data: Data)? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            )
        else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixelData = context.data else { return nil }

        let widthBytes = (width + 7) / 8
        let totalBytes = widthBytes * height

        let bitmapPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalBytes)
        bitmapPointer.initialize(repeating: 0, count: totalBytes)

        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: width * height)

        let threshold: UInt8 = 160

        for y in 0..<height {
            let rowOffset = y * width
            let bitmapRowOffset = y * widthBytes

            for x in 0..<width {
                if pixels[rowOffset + x] < threshold {
                    let byteIndex = bitmapRowOffset + (x >> 3)
                    let bitIndex = 7 - (x & 7)
                    bitmapPointer[byteIndex] |= (1 << bitIndex)
                }
            }
        }

        let bitmapData = Data(bytes: bitmapPointer, count: totalBytes)
        bitmapPointer.deallocate()

        return (width: width, height: height, data: bitmapData)
    }

    // MARK: - Print Row (NEW METHOD)
//    private func printRow(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult)
//    {
//        let startTime = Date()
//
//        // Check if any column contains complex unicode
//        var hasComplexUnicode = false
//        for col in columns {
//            if let text = col["text"] as? String, containsComplexUnicode(text) {
//                hasComplexUnicode = true
//                break
//            }
//        }
//
//        if hasComplexUnicode {
//            print("🖼️ SWIFT: Rendering Row with Complex text as Image")
//
//            DispatchQueue.global(qos: .userInitiated).async {
//                let renderStart = Date()
//                guard let imageData = self.renderRowToData(columns: columns, fontSize: fontSize)
//                else {
//                    DispatchQueue.main.async {
//                        result(
//                            FlutterError(
//                                code: "RENDER_ERROR", message: "Failed to render row", details: nil)
//                        )
//                    }
//                    return
//                }
//
//                let renderTime = Date().timeIntervalSince(renderStart) * 1000
//                print(
//                    "✅ SWIFT: Row rendered in \(Int(renderTime))ms, size: \(imageData.count) bytes")
//
//                DispatchQueue.main.async {
//                    self.writeDataSmooth(imageData)
//                    let totalTime = Date().timeIntervalSince(startTime) * 1000
//                    print("🖨️ SWIFT: Row printed in \(Int(totalTime))ms")
//                    result(true)
//                }
//            }
//        } else {
//            // Use text method for simple ASCII text
//            printRowUsingTextMethod(columns: columns, fontSize: fontSize, result: result)
//            let totalTime = Date().timeIntervalSince(startTime) * 1000
//            print("🖨️ SWIFT: Row printed in \(Int(totalTime))ms")
//        }
//    }
//
//    private func printRowUsingTextMethod(
//        columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult
//    ) {
//        print("🔵 SWIFT: Printing row with \(columns.count) columns (Simple text)")
//
//        var commands = Data()
//
//        // Initialize printer
//        commands.append(contentsOf: [ESC, 0x40])
//        commands.append(contentsOf: [ESC, 0x74, 0x01])
//
//        // Font size
//        let sizeCommand: UInt8
//        if fontSize > 30 {
//            sizeCommand = 0x30
//        } else if fontSize > 24 {
//            sizeCommand = 0x11
//        } else {
//            sizeCommand = 0x00
//        }
//        commands.append(contentsOf: [ESC, 0x21, sizeCommand])
//
//        // Line spacing (tighter)
//        commands.append(contentsOf: [ESC, 0x33, 0x10])
//
//        // Check for bold
//        var hasBold = false
//        for col in columns {
//            if let bold = col["bold"] as? Bool, bold {
//                hasBold = true
//                break
//            }
//        }
//
//        if hasBold {
//            commands.append(contentsOf: [ESC, 0x45, 0x01])
//        }
//
//        // Left align
//        commands.append(contentsOf: [ESC, 0x61, 0x00])
//
//        // Build row text
//        var rowText = ""
//        let totalChars: Int = (fontSize > 30 ? 24 : (fontSize > 24 ? 32 : 48))
////        let totalChars: Int
////        if fontSize > 30 {
////            totalChars = 24
////        } else if fontSize > 24 {
////            totalChars = 32
////        } else {
////            totalChars = 48
////        }
//
//        for col in columns {
//            let text = col["text"] as? String ?? ""
//            let width = col["width"] as? Int ?? 6
//            let align = col["align"] as? String ?? "left"
//
//            let maxCharsPerColumn = (totalChars * width) / 12
//            let formattedText = formatColumnText(text, width: maxCharsPerColumn, align: align)
//            rowText += formattedText
//        }
//
//        if let textData = rowText.data(using: .utf8) {
//            commands.append(textData)
//        }
//        commands.append(contentsOf: [0x0A])
//
//        // Reset line spacing
//        commands.append(contentsOf: [ESC, 0x33, 0x30])
//
//        // Reset bold
//        if hasBold {
//            commands.append(contentsOf: [ESC, 0x45, 0x00])
//        }
//
//        // Reset alignment
//        commands.append(contentsOf: [ESC, 0x61, 0x00])
//
//        DispatchQueue.main.async {
//            self.writeDataSmooth(commands)
//            result(true)
//        }
//    }
//
//    private func formatColumnText(_ text: String, width: Int, align: String) -> String {
//        if text.count == width { return text }
//        if text.count > width { return String(text.prefix(width)) }
//
//        switch align.lowercased() {
//        case "center":
//            let totalPadding = width - text.count
//            let leftPadding = totalPadding / 2
//            let rightPadding = totalPadding - leftPadding
//            return String(repeating: " ", count: leftPadding) + text
//                + String(repeating: " ", count: rightPadding)
//        case "right":
//            return String(repeating: " ", count: width - text.count) + text
//        default:  // left
//            return text + String(repeating: " ", count: width - text.count)
//        }
//    }
    
    // MARK: - Print Row
    private func printRow(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult) {
        let startTime = Date()
        
        // Validate total width
        let totalWidth = columns.reduce(0) { $0 + (($1["width"] as? Int) ?? 6) }
        if totalWidth > 12 {
            result(FlutterError(
                code: "ROW_ERROR",
                message: "Total column width exceeds 12, got \(totalWidth)",
                details: nil
            ))
            return
        }
        
        // Check if any column contains complex unicode
        var hasComplexUnicode = false
        for col in columns {
            if let text = col["text"] as? String, containsComplexUnicode(text) {
                hasComplexUnicode = true
                break
            }
        }
        
        if hasComplexUnicode {
            print("🖼️ SWIFT: Rendering Row with Complex text as Image")
            
            DispatchQueue.global(qos: .userInitiated).async {
                let renderStart = Date()
                
                guard let imageData = self.renderRowToData(columns: columns, fontSize: fontSize) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "RENDER_ERROR", message: "Failed to render row", details: nil))
                    }
                    return
                }
                
                let renderTime = Date().timeIntervalSince(renderStart) * 1000
                print("✅ SWIFT: Row rendered in \(Int(renderTime))ms, size: \(imageData.count) bytes")
                
                DispatchQueue.main.async {
                    self.writeDataSmooth(imageData)
                    let totalTime = Date().timeIntervalSince(startTime) * 1000
                    print("🖨️ SWIFT: Row printed in \(Int(totalTime))ms")
                    result(true)
                }
            }
            
        } else {
            // Simple ASCII text
            printRowUsingTextMethod(columns: columns, fontSize: fontSize, result: result)
            let totalTime = Date().timeIntervalSince(startTime) * 1000
            print("🖨️ SWIFT: Row printed in \(Int(totalTime))ms")
        }
    }

    // MARK: - Simple Text Row
    private func printRowUsingTextMethod(columns: [[String: Any]], fontSize: Int, result: @escaping FlutterResult) {
        print("🔵 SWIFT: Printing row with \(columns.count) columns (Simple text)")
        
        var commands = Data()
        
        // Initialize printer
        commands.append(contentsOf: [ESC, 0x40])   // Initialize
        commands.append(contentsOf: [ESC, 0x74, 0x01]) // Code page
        
        // Font size
        let sizeCommand: UInt8 = (fontSize > 30) ? 0x30 : (fontSize > 24 ? 0x11 : 0x00)
        commands.append(contentsOf: [ESC, 0x21, sizeCommand])
        
        // Line spacing (tighter)
        commands.append(contentsOf: [ESC, 0x33, 0x10])
        
        // Bold check
        let hasBold = columns.contains { ($0["bold"] as? Bool) ?? false }
        if hasBold {
            commands.append(contentsOf: [ESC, 0x45, 0x01])
        }
        
        // Left align
        commands.append(contentsOf: [ESC, 0x61, 0x00])
        
        // Determine total chars per row
        let totalChars = (fontSize > 30) ? 24 : (fontSize > 24 ? 32 : 48)
        
        // Wrap text per column
        var columnTextLists: [[String]] = []
        for col in columns {
            let text = col["text"] as? String ?? ""
            let width = col["width"] as? Int ?? 6
            let colMax = (totalChars * width) / 12
            columnTextLists.append(wrapTextToList(text, maxChars: colMax))
        }
        
        // Determine max lines
        let maxLines = columnTextLists.map { $0.count }.max() ?? 1
        
        // Build line by line
        for lineIndex in 0..<maxLines {
            var lineText = ""
            for (colIndex, col) in columns.enumerated() {
                let align = col["align"] as? String ?? "left"
                let width = col["width"] as? Int ?? 6
                let colMax = (totalChars * width) / 12
                
                let lines = columnTextLists[colIndex]
                let text = (lineIndex < lines.count) ? lines[lineIndex] : ""
                lineText += formatColumnText(text, width: colMax, align: align)
            }
            if let data = lineText.data(using: .utf8) {
                commands.append(data)
            }
            commands.append(0x0A) // New line
        }
        
        // Reset line spacing
        commands.append(contentsOf: [ESC, 0x33, 0x30])
        
        // Reset bold
        if hasBold {
            commands.append(contentsOf: [ESC, 0x45, 0x00])
        }
        
        // Reset alignment
        commands.append(contentsOf: [ESC, 0x61, 0x00])
        
        DispatchQueue.main.async {
            self.writeDataSmooth(commands)
            result(true)
        }
    }

    // MARK: - Format Column Text
    private func formatColumnText(_ text: String, width: Int, align: String) -> String {
        if text.count == width { return text }
        if text.count > width { return String(text.prefix(width)) }
        
        switch align.lowercased() {
        case "center":
            let totalPadding = width - text.count
            let leftPadding = totalPadding / 2
            let rightPadding = totalPadding - leftPadding
            return String(repeating: " ", count: leftPadding) + text + String(repeating: " ", count: rightPadding)
        case "right":
            return String(repeating: " ", count: width - text.count) + text
        default: // left
            return text + String(repeating: " ", count: width - text.count)
        }
    }

    // MARK: - Wrap Text Helper
    private func wrapTextToList(_ text: String, maxChars: Int) -> [String] {
        if maxChars <= 0 { return [text] }
        
        var lines: [String] = []
        var remaining = text[...]
        
        while remaining.count > maxChars {
            let idx = remaining.index(remaining.startIndex, offsetBy: maxChars)
            lines.append(String(remaining[..<idx]))
            remaining = remaining[idx...]
        }
        
        if !remaining.isEmpty {
            lines.append(String(remaining))
        }
        
        return lines
    }


    private func renderRowToData(columns: [[String: Any]], fontSize: Int) -> Data? {
        // INCREASED BASE SIZE: Larger Khmer text for rows
        let baseFontSize: CGFloat = 24.0  // Increased from 18
        let scaledFontSize: CGFloat

        if fontSize > 30 {
            scaledFontSize = baseFontSize * 2.0
        } else if fontSize > 24 {
            scaledFontSize = baseFontSize * 1.5
        } else {
            scaledFontSize = baseFontSize
        }

        print("📏 SWIFT: Row fontSize=\(fontSize) -> scaledFontSize=\(scaledFontSize)")

        let maxWidth = CGFloat(self.printerWidth)

        // Calculate column widths
        var columnWidths: [CGFloat] = []
        var totalWidth = 0
        for col in columns {
            let width = col["width"] as? Int ?? 6
            totalWidth += width
            columnWidths.append((maxWidth * CGFloat(width)) / 12.0)
        }

        // Adjust chars per row for larger text
        let totalChars: Int
        if fontSize > 30 {
            totalChars = 20
        } else if fontSize > 24 {
            totalChars = 28
        } else {
            totalChars = 42
        }

        // Calculate max lines needed
        var maxLines = 1
        for col in columns {
            let text = col["text"] as? String ?? ""
            let width = col["width"] as? Int ?? 6
            let colChars = (totalChars * width) / 12
            let lineCount = (text.count + colChars - 1) / colChars
            if lineCount > maxLines {
                maxLines = lineCount
            }
        }

        // Calculate line height
        let testFont = getFont(bold: false, size: scaledFontSize)
        let lineHeight = ceil(testFont.lineHeight) * 1.1

        // Slightly more padding
        let verticalPadding: CGFloat = 4.0
        let totalHeight = (CGFloat(maxLines) * lineHeight) + (verticalPadding * 2)

        // Create image context
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: maxWidth, height: totalHeight), true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: totalHeight))

        // Disable smoothing
        context.setShouldSmoothFonts(false)
        context.setAllowsFontSmoothing(false)
        context.setAllowsAntialiasing(false)

        // Draw each column
        var currentX: CGFloat = 0
        for (index, col) in columns.enumerated() {
            let text = col["text"] as? String ?? ""
            let bold = col["bold"] as? Bool ?? false
            let align = col["align"] as? String ?? "left"
            let colWidth = columnWidths[index]
            let width = col["width"] as? Int ?? 6
            let colChars = (totalChars * width) / 12

            // Get cached font
            let font = getFont(bold: bold, size: scaledFontSize)

            // Word wrap for this column
            var lines: [String] = []
            var remaining = text
            while remaining.count > colChars {
                lines.append(String(remaining.prefix(colChars)))
                remaining = String(remaining.dropFirst(colChars))
            }
            if !remaining.isEmpty {
                lines.append(remaining)
            }

            // Draw each line
            for (lineIndex, line) in lines.enumerated() {
                if line.isEmpty { continue }

                let paragraphStyle = NSMutableParagraphStyle()
                switch align.lowercased() {
                case "center": paragraphStyle.alignment = .center
                case "right": paragraphStyle.alignment = .right
                default: paragraphStyle.alignment = .left
                }

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle,
                ]

                let y = verticalPadding + (CGFloat(lineIndex) * lineHeight)
                let drawRect = CGRect(x: currentX, y: y, width: colWidth, height: lineHeight)
                (line as NSString).draw(in: drawRect, withAttributes: attributes)
            }

            currentX += colWidth
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        guard let bitmap = self.convertToMonochromeFast(image: image) else {
            return nil
        }

        // Build ESC/POS command
        var commands = Data()
        commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])

        let widthBytes = (bitmap.width + 7) / 8
        commands.append(UInt8(widthBytes & 0xFF))
        commands.append(UInt8((widthBytes >> 8) & 0xFF))
        commands.append(UInt8(bitmap.height & 0xFF))
        commands.append(UInt8((bitmap.height >> 8) & 0xFF))
        commands.append(bitmap.data)

        return commands
    }

    // MARK: - Other Methods (keeping existing)
    private func printImage(imageBytes: Data, width: Int, result: @escaping FlutterResult) {
        guard let image = UIImage(data: imageBytes) else {
            result(
                FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
            return
        }

        let scaledImage = resizeImage(image: image, maxWidth: 576)
        guard let bitmap = convertToMonochromeFast(image: scaledImage) else {
            result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert", details: nil))
            return
        }

        var commands = Data()
        commands.append(contentsOf: [ESC, 0x40])
        commands.append(contentsOf: [GS, 0x76, 0x30, 0x00])

        let widthBytes = (bitmap.width + 7) / 8
        commands.append(UInt8(widthBytes & 0xFF))
        commands.append(UInt8((widthBytes >> 8) & 0xFF))
        commands.append(UInt8(bitmap.height & 0xFF))
        commands.append(UInt8((bitmap.height >> 8) & 0xFF))
        commands.append(bitmap.data)
        commands.append(contentsOf: [0x0A, 0x0A])

        writeDataSmooth(commands)
        result(true)
    }

    private func resizeImage(image: UIImage, maxWidth: Int) -> UIImage {
        let size = image.size
        if size.width <= CGFloat(maxWidth) { return image }

        let ratio = CGFloat(maxWidth) / size.width
        let newSize = CGSize(width: CGFloat(maxWidth), height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? image
    }

    private func feedPaper(lines: Int, result: @escaping FlutterResult) {
        var commands = Data()
        for _ in 0..<lines {
            commands.append(0x0A)
        }
        writeDataSmooth(commands)
        result(true)
    }

    private func cutPaper(result: @escaping FlutterResult) {
        let commands = Data([GS, 0x56, 0x00])
        writeDataSmooth(commands)
        result(true)
    }

    private func getStatus(result: @escaping FlutterResult) {
        var connected = false

        switch currentConnectionType {
        case "bluetooth", "ble":
            connected = connectedPeripheral?.state == .connected && writeCharacteristic != nil
        case "usb":
            connected = session != nil && writeStream?.streamStatus == .open
        case "network":
            connected = networkConnection?.state == .ready
        default:
            break
        }

        result([
            "connected": connected,
            "paperStatus": "ok",
            "connectionType": currentConnectionType,
            "printerWidth": printerWidth,
        ])
    }

    private func setPrinterWidth(width: Int, result: @escaping FlutterResult) {
        if width == 384 || width == 576 {
            printerWidth = width
            result(true)
        } else {
            result(
                FlutterError(
                    code: "INVALID_WIDTH", message: "Width must be 384 or 576", details: nil))
        }
    }

    private func checkBluetoothPermission(result: @escaping FlutterResult) {
        let state = centralManager.state

        var status: [String: Any] = [:]

        switch state {
        case .poweredOn:
            status = ["status": "authorized", "enabled": true, "message": "Bluetooth is ready"]
        case .poweredOff:
            status = [
                "status": "authorized", "enabled": false, "message": "Bluetooth is turned off",
            ]
        case .unauthorized:
            status = [
                "status": "denied", "enabled": false, "message": "Bluetooth permission denied",
            ]
        case .unsupported:
            status = [
                "status": "unsupported", "enabled": false, "message": "Bluetooth not supported",
            ]
        case .resetting:
            status = ["status": "resetting", "enabled": false, "message": "Bluetooth is resetting"]
        case .unknown:
            status = ["status": "unknown", "enabled": false, "message": "Bluetooth state unknown"]
        @unknown default:
            status = ["status": "unknown", "enabled": false, "message": "Unknown Bluetooth state"]
        }

        result(status)
    }

    // MARK: - StreamDelegate
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasSpaceAvailable:
            break
        case .errorOccurred:
            print("Stream error: \(aStream.streamError?.localizedDescription ?? "Unknown")")
        case .endEncountered:
            print("Stream ended")
        default:
            break
        }
    }

}
//===============================================old code============================================

//import Flutter
//import UIKit
//import ExternalAccessory
//import CoreBluetooth
//import Network
//
//public class ThermalPrinterPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate, EAAccessoryDelegate, StreamDelegate {
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
//    // Current connection type
//    private var currentConnectionType: String = "bluetooth"
//    private var isScanning = false
//    private var connectionResult: FlutterResult?
//
//    // Printer settings
//    private var printerWidth: Int = 576 // Default 80mm (576px), can be 384 for 58mm
//
//    // ESC/POS Commands
//    private let ESC: UInt8 = 0x1B
//    private let GS: UInt8 = 0x1D
//
//    public override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [
//            CBCentralManagerOptionShowPowerAlertKey: true
//        ])
//        print("🔵 CBCentralManager initialized")
//    }
//
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "thermal_printer", binaryMessenger: registrar.messenger())
//        let instance = ThermalPrinterPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//
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
//            // CRITICAL: Handle directly without queueing
//            printText(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine, result: result)
//
//        case "printImage":
//            guard let args = call.arguments as? [String: Any],
//                  let imageBytes = args["imageBytes"] as? FlutterStandardTypedData else {
//                result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
//                return
//            }
//            let width = args["width"] as? Int ?? 384
//            printImage(imageBytes: imageBytes.data, width: width, result: result)
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
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//
//    // MARK: - Discovery
//
//    private func discoverPrinters(type: String, result: @escaping FlutterResult) {
//        switch type {
//        case "bluetooth", "ble":
//            discoverBluetoothPrinters(result: result)
//        case "usb":
//            discoverUSBPrinters(result: result)
//        case "network":
//            result([])
//        default:
//            result(FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil))
//        }
//    }
//
//    private func discoverAllPrinters(result: @escaping FlutterResult) {
//        scanResult = result
//        discoveredPrinters.removeAll()
//        isScanning = true
//
//        if centralManager.state == .poweredOn {
//            centralManager.scanForPeripherals(withServices: nil, options: [
//                CBCentralManagerScanOptionAllowDuplicatesKey: false
//            ])
//        } else if centralManager.state == .poweredOff {
//            isScanning = false
//            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is turned off.", details: nil))
//            scanResult = nil
//            return
//        } else if centralManager.state == .unauthorized {
//            isScanning = false
//            result(FlutterError(code: "PERMISSION_DENIED", message: "Bluetooth permission denied.", details: nil))
//            scanResult = nil
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if self.isScanning {
//                self.isScanning = false
//                self.centralManager.stopScan()
//            }
//
//            var allPrinters: [[String: Any]] = []
//
//            for printer in self.discoveredPrinters {
//                allPrinters.append([
//                    "name": printer.name ?? "Unknown Device",
//                    "address": printer.identifier.uuidString,
//                    "type": "ble"
//                ])
//            }
//
//            let accessories = EAAccessoryManager.shared().connectedAccessories
//            for acc in accessories {
//                allPrinters.append([
//                    "name": acc.name,
//                    "address": String(acc.connectionID),
//                    "type": "usb"
//                ])
//            }
//
//            if let callback = self.scanResult {
//                callback(allPrinters)
//                self.scanResult = nil
//            }
//        }
//    }
//
//    private func discoverBluetoothPrinters(result: @escaping FlutterResult) {
//        scanResult = result
//        discoveredPrinters.removeAll()
//        isScanning = true
//
//        if centralManager.state == .poweredOn {
//            centralManager.scanForPeripherals(withServices: nil, options: [
//                CBCentralManagerScanOptionAllowDuplicatesKey: false
//            ])
//        } else if centralManager.state == .poweredOff {
//            isScanning = false
//            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is turned off", details: nil))
//            scanResult = nil
//            return
//        } else if centralManager.state == .unauthorized {
//            isScanning = false
//            result(FlutterError(code: "PERMISSION_DENIED", message: "Bluetooth permission denied", details: nil))
//            scanResult = nil
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if self.isScanning {
//                self.isScanning = false
//                self.centralManager.stopScan()
//            }
//
//            let printers = self.discoveredPrinters.map { printer in
//                return [
//                    "name": printer.name ?? "Unknown Device",
//                    "address": printer.identifier.uuidString,
//                    "type": "ble"
//                ] as [String: Any]
//            }
//
//            if let callback = self.scanResult {
//                callback(printers)
//                self.scanResult = nil
//            }
//        }
//    }
//
//    private func discoverUSBPrinters(result: @escaping FlutterResult) {
//        let accessories = EAAccessoryManager.shared().connectedAccessories
//        let printers = accessories.map { acc in
//            return [
//                "name": acc.name,
//                "address": String(acc.connectionID),
//                "type": "usb"
//            ]
//        }
//        result(printers)
//    }
//
//    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn && isScanning {
//            central.scanForPeripherals(withServices: nil, options: [
//                CBCentralManagerScanOptionAllowDuplicatesKey: false
//            ])
//        }
//    }
//
//    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if !discoveredPrinters.contains(where: { $0.identifier == peripheral.identifier }) {
//            discoveredPrinters.append(peripheral)
//        }
//    }
//
//    // MARK: - Connection
//
//    private func connect(address: String, type: String, result: @escaping FlutterResult) {
//        currentConnectionType = type
//
//        switch type {
//        case "bluetooth", "ble":
//            connectBluetooth(address: address, result: result)
//        case "usb":
//            connectUSB(connectionID: UInt(address) ?? 0, result: result)
//        default:
//            result(FlutterError(code: "INVALID_TYPE", message: "Unknown connection type", details: nil))
//        }
//    }
//
//    private func connectBluetooth(address: String, result: @escaping FlutterResult) {
//        guard let printer = discoveredPrinters.first(where: { $0.identifier.uuidString == address }) else {
//            result(FlutterError(code: "NOT_FOUND", message: "Printer not found", details: nil))
//            return
//        }
//
//        connectionResult = result
//        connectedPeripheral = printer
//        printer.delegate = self
//        centralManager.connect(printer, options: nil)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if let callback = self.connectionResult {
//                self.connectionResult = nil
//                callback(false)
//            }
//        }
//    }
//
//    private func connectUSB(connectionID: UInt, result: @escaping FlutterResult) {
//        let accessories = EAAccessoryManager.shared().connectedAccessories
//        guard let acc = accessories.first(where: { $0.connectionID == connectionID }) else {
//            result(FlutterError(code: "NOT_FOUND", message: "USB accessory not found", details: nil))
//            return
//        }
//
//        accessory = acc
//        guard let protocolString = acc.protocolStrings.first else {
//            result(FlutterError(code: "NO_PROTOCOL", message: "No protocol available", details: nil))
//            return
//        }
//
//        session = EASession(accessory: acc, forProtocol: protocolString)
//        writeStream = session?.outputStream
//        writeStream?.delegate = self
//        writeStream?.schedule(in: .current, forMode: .default)
//        writeStream?.open()
//
//        result(true)
//    }
//
//    private func connectNetwork(ipAddress: String, port: Int, result: @escaping FlutterResult) {
//        let host = NWEndpoint.Host(ipAddress)
//        let port = NWEndpoint.Port(integerLiteral: UInt16(port))
//
//        networkConnection = NWConnection(host: host, port: port, using: .tcp)
//
//        var hasResponded = false
//
//        networkConnection?.stateUpdateHandler = { [weak self] state in
//            guard let self = self, !hasResponded else { return }
//
//            switch state {
//            case .ready:
//                hasResponded = true
//                result(true)
//            case .failed(let error):
//                hasResponded = true
//                result(FlutterError(code: "CONNECTION_FAILED", message: error.localizedDescription, details: nil))
//            default:
//                break
//            }
//        }
//
//        networkConnection?.start(queue: .global())
//        currentConnectionType = "network"
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if !hasResponded {
//                hasResponded = true
//                result(false)
//            }
//        }
//    }
//
//    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheral.discoverServices(nil)
//    }
//
//    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        if let callback = connectionResult {
//            connectionResult = nil
//            callback(false)
//        }
//    }
//
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//        for characteristic in characteristics {
//            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
//                writeCharacteristic = characteristic
//
//                if let callback = connectionResult {
//                    connectionResult = nil
//                    callback(true)
//                }
//                break
//            }
//        }
//    }
//
//    private func disconnect(result: @escaping FlutterResult) {
//        switch currentConnectionType {
//        case "bluetooth", "ble":
//            if let peripheral = connectedPeripheral {
//                centralManager.cancelPeripheralConnection(peripheral)
//                connectedPeripheral = nil
//                writeCharacteristic = nil
//            }
//        case "usb":
//            writeStream?.close()
//            writeStream?.remove(from: .current, forMode: .default)
//            session = nil
//            accessory = nil
//        case "network":
//            networkConnection?.cancel()
//            networkConnection = nil
//        default:
//            break
//        }
//        result(true)
//    }
//
//    // MARK: - CRITICAL: Ultra-Fast Write Method
//
//    private func writeDataUltraFast(_ data: Data) {
//        let startTime = Date()
//
//        switch currentConnectionType {
//        case "bluetooth", "ble":
//            guard let peripheral = connectedPeripheral,
//                  let characteristic = writeCharacteristic else {
//                print("❌ WRITE: No peripheral/characteristic")
//                return
//            }
//
//            // CRITICAL: Adaptive chunk size based on data size
//            // Larger chunks for bigger data = faster throughput
//            let chunkSize = data.count > 10000 ? 512 : 256
//            var offset = 0
//            var chunkCount = 0
//
//            while offset < data.count {
//                let end = min(offset + chunkSize, data.count)
//                let chunk = data.subdata(in: offset..<end)
//
//                // Write directly - BLE stack handles buffering
//                peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
//                offset = end
//                chunkCount += 1
//
//                // NO SLEEP - maximum speed
//            }
//
//            let writeTime = Date().timeIntervalSince(startTime) * 1000
//            print("📡 BLE WRITE: \(data.count) bytes in \(chunkCount) chunks, took \(Int(writeTime))ms")
//
//        case "usb":
//            guard let stream = writeStream, stream.hasSpaceAvailable else {
//                print("❌ WRITE: USB stream not available")
//                return
//            }
//            let bytes = [UInt8](data)
//            stream.write(bytes, maxLength: bytes.count)
//
//            let writeTime = Date().timeIntervalSince(startTime) * 1000
//            print("📡 USB WRITE: \(data.count) bytes, took \(Int(writeTime))ms")
//
//        case "network":
//            guard let connection = networkConnection else {
//                print("❌ WRITE: Network connection not available")
//                return
//            }
//            connection.send(content: data, completion: .contentProcessed { _ in })
//
//            let writeTime = Date().timeIntervalSince(startTime) * 1000
//            print("📡 NET WRITE: \(data.count) bytes, took \(Int(writeTime))ms")
//
//        default:
//            break
//        }
//    }
//
//    // MARK: - Printing Functions
//
//    private func printText(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int, result: @escaping FlutterResult) {
//        let startTime = Date()
//        let preview = text.prefix(30)
//
//        // Check if text contains Khmer or complex unicode
//        if containsComplexUnicode(text) {
//            print("🔵 SWIFT: Rendering Khmer text: \"\(preview)...\"")
//
//            // CRITICAL: Render entire line (including English) as image for proper alignment
//            DispatchQueue.global(qos: .userInitiated).async {
//                let renderStart = Date()
//
//                guard let imageData = self.renderTextToData(
//                    text: text,
//                    fontSize: fontSize,
//                    bold: bold,
//                    align: align,
//                    maxCharsPerLine: maxCharsPerLine
//                ) else {
//                    DispatchQueue.main.async {
//                        result(FlutterError(code: "RENDER_ERROR", message: "Failed to render", details: nil))
//                    }
//                    return
//                }
//
//                let renderTime = Date().timeIntervalSince(renderStart) * 1000
//                print("⏱️ SWIFT: Rendered in \(Int(renderTime))ms, size: \(imageData.count) bytes")
//
//                // Send immediately on main thread
//                DispatchQueue.main.async {
//                    let sendStart = Date()
//                    self.writeDataUltraFast(imageData)
//                    let sendTime = Date().timeIntervalSince(sendStart) * 1000
//
//                    let totalTime = Date().timeIntervalSince(startTime) * 1000
//                    print("📤 SWIFT: Sent in \(Int(sendTime))ms, total: \(Int(totalTime))ms")
//
//                    result(true)
//                }
//            }
//        } else {
//            print("🔵 SWIFT: Printing English text: \"\(preview)\"")
//            // Fast path for pure English text
//            printSimpleText(text: text, fontSize: fontSize, bold: bold, align: align, maxCharsPerLine: maxCharsPerLine, result: result)
//
//            let totalTime = Date().timeIntervalSince(startTime) * 1000
//            print("✅ SWIFT: English printed in \(Int(totalTime))ms")
//        }
//    }
//
//    private func containsComplexUnicode(_ text: String) -> Bool {
//        for scalar in text.unicodeScalars {
//            let value = scalar.value
//            if (value >= 0x1780 && value <= 0x17FF) ||  // Khmer
//               (value >= 0x0E00 && value <= 0x0E7F) ||  // Thai
//               (value >= 0x4E00 && value <= 0x9FFF) ||  // CJK
//               (value >= 0xAC00 && value <= 0xD7AF) {   // Hangul
//                return true
//            }
//        }
//        return false
//    }
//
//    private func printSimpleText(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int, result: @escaping FlutterResult) {
//        var commands = Data()
//
//        commands.append(contentsOf: [ESC, 0x40])
//
//        let alignCode: UInt8
//        switch align.lowercased() {
//        case "center": alignCode = 0x01
//        case "right": alignCode = 0x02
//        default: alignCode = 0x00
//        }
//        commands.append(contentsOf: [ESC, 0x61, alignCode])
//
//        let size = min(max(fontSize / 12, 1), 7)
//        commands.append(contentsOf: [GS, 0x21, UInt8((size - 1) * 16 + (size - 1))])
//
//        if bold {
//            commands.append(contentsOf: [ESC, 0x45, 0x01])
//        }
//
//        let textToProcess: String
//        if maxCharsPerLine > 0 {
//            textToProcess = wrapText(text, maxCharsPerLine: maxCharsPerLine)
//        } else {
//            textToProcess = text
//        }
//
//        if let textData = textToProcess.data(using: .utf8) {
//            commands.append(textData)
//        }
//
//        commands.append(contentsOf: [0x0A])
//
//        if bold {
//            commands.append(contentsOf: [ESC, 0x45, 0x00])
//        }
//        commands.append(contentsOf: [ESC, 0x61, 0x00])
//
//        // Write on main thread directly
//        DispatchQueue.main.async {
//            self.writeDataUltraFast(commands)
//            result(true)
//        }
//    }
//
//    private func wrapText(_ text: String, maxCharsPerLine: Int) -> String {
//        var result = ""
//        var currentLine = ""
//        let words = text.components(separatedBy: " ")
//
//        for word in words {
//            if currentLine.isEmpty {
//                currentLine = word
//            } else if (currentLine.count + 1 + word.count) <= maxCharsPerLine {
//                currentLine += " " + word
//            } else {
//                result += currentLine + "\n"
//                currentLine = word
//            }
//        }
//
//        if !currentLine.isEmpty {
//            result += currentLine
//        }
//
//        return result
//    }
//
//    // CRITICAL: Balanced rendering - good quality + fast speed
//    private func renderTextToData(text: String, fontSize: Int, bold: Bool, align: String, maxCharsPerLine: Int) -> Data? {
//        // Use system font for better rendering
//        let font: UIFont
//        if bold {
//            font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
//        } else {
//            font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)
//        }
//
//        let maxWidth = CGFloat(self.printerWidth)
//        let padding: CGFloat = 8  // Add back padding for better margins
//        let availableWidth = maxWidth - (padding * 2)
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineBreakMode = .byWordWrapping
//        paragraphStyle.lineSpacing = 0
//
//        switch align.lowercased() {
//        case "center": paragraphStyle.alignment = .center
//        case "right": paragraphStyle.alignment = .right
//        default: paragraphStyle.alignment = .left
//        }
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .foregroundColor: UIColor.black,
//            .paragraphStyle: paragraphStyle
//        ]
//
//        let textToRender = maxCharsPerLine > 0 ? self.wrapText(text, maxCharsPerLine: maxCharsPerLine) : text
//
//        // Calculate size
//        let size = (textToRender as NSString).size(withAttributes: attributes)
//        let height = ceil(size.height) + padding * 2
//
//        // CRITICAL: Use scale 1.0 for better quality (not 0.5)
//        // The speed gain from 0.5 isn't worth the quality loss
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: height), true, 1.0)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//
//        // White background
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(CGRect(x: 0, y: 0, width: maxWidth, height: height))
//
//        // CRITICAL: Enable text smoothing for better Khmer rendering
//        context.setShouldSmoothFonts(true)
//        context.setAllowsFontSmoothing(true)
//        context.setAllowsAntialiasing(true)
//
//        // Draw text
//        let drawRect = CGRect(x: padding, y: padding, width: availableWidth, height: size.height)
//        (textToRender as NSString).draw(in: drawRect, withAttributes: attributes)
//
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        UIGraphicsEndImageContext()
//
//        // Don't resize if already correct size
//        let finalImage = image.size.width <= 576 ? image : self.resizeImageHighQuality(image: image, maxWidth: 576)
//
//        guard let bitmap = self.convertToMonochromeFast(image: finalImage) else {
//            return nil
//        }
//
//        // Build ESC/POS command
//        var commands = Data()
//        commands.append(contentsOf: [self.ESC, 0x40])
//        commands.append(contentsOf: [self.GS, 0x76, 0x30, 0x00])
//
//        let widthBytes = (bitmap.width + 7) / 8
//        commands.append(UInt8(widthBytes & 0xFF))
//        commands.append(UInt8((widthBytes >> 8) & 0xFF))
//        commands.append(UInt8(bitmap.height & 0xFF))
//        commands.append(UInt8((bitmap.height >> 8) & 0xFF))
//        commands.append(bitmap.data)
//        commands.append(contentsOf: [0x0A])
//
//        return commands
//    }
//
//    // CRITICAL: High-quality resize with interpolation
//    private func resizeImageHighQuality(image: UIImage, maxWidth: Int) -> UIImage {
//        let size = image.size
//        if size.width <= CGFloat(maxWidth) { return image }
//
//        let ratio = CGFloat(maxWidth) / size.width
//        let newSize = CGSize(width: CGFloat(maxWidth), height: size.height * ratio)
//
//        // Use high quality interpolation
//        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
//
//        if let context = UIGraphicsGetCurrentContext() {
//            context.interpolationQuality = .high
//            context.setShouldAntialias(true)
//        }
//
//        image.draw(in: CGRect(origin: .zero, size: newSize))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return resizedImage ?? image
//    }
//
//    // CRITICAL: Optimized bitmap conversion with better threshold for clarity
//    private func convertToMonochromeFast(image: UIImage) -> (width: Int, height: Int, data: Data)? {
//        guard let cgImage = image.cgImage else { return nil }
//
//        let width = cgImage.width
//        let height = cgImage.height
//
//        let colorSpace = CGColorSpaceCreateDeviceGray()
//        guard let context = CGContext(
//            data: nil,
//            width: width,
//            height: height,
//            bitsPerComponent: 8,
//            bytesPerRow: width,
//            space: colorSpace,
//            bitmapInfo: CGImageAlphaInfo.none.rawValue
//        ) else { return nil }
//
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//        guard let pixelData = context.data else { return nil }
//
//        let widthBytes = (width + 7) / 8
//        let totalBytes = widthBytes * height
//
//        // Use UnsafeMutablePointer for faster access
//        let bitmapPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalBytes)
//        bitmapPointer.initialize(repeating: 0, count: totalBytes)
//
//        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
//
//        // CRITICAL: Use 160 threshold instead of 128 for clearer text
//        // Lower threshold = more black pixels = sharper text
//        let threshold: UInt8 = 160
//
//        // OPTIMIZED: Single-threaded with pointer arithmetic
//        for y in 0..<height {
//            let rowOffset = y * width
//            let bitmapRowOffset = y * widthBytes
//
//            for x in 0..<width {
//                if pixels[rowOffset + x] < threshold {
//                    let byteIndex = bitmapRowOffset + (x >> 3)
//                    let bitIndex = 7 - (x & 7)
//                    bitmapPointer[byteIndex] |= (1 << bitIndex)
//                }
//            }
//        }
//
//        // Convert to Data
//        let bitmapData = Data(bytes: bitmapPointer, count: totalBytes)
//        bitmapPointer.deallocate()
//
//        return (width: width, height: height, data: bitmapData)
//    }
//
//    private func printImage(imageBytes: Data, width: Int, result: @escaping FlutterResult) {
//        guard let image = UIImage(data: imageBytes) else {
//            result(FlutterError(code: "INVALID_IMAGE", message: "Cannot decode image", details: nil))
//            return
//        }
//
//        let scaledImage = resizeImage(image: image, maxWidth: 576)
//        guard let bitmap = convertToMonochromeFast(image: scaledImage) else {
//            result(FlutterError(code: "CONVERSION_ERROR", message: "Cannot convert", details: nil))
//            return
//        }
//
//        var commands = Data()
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
//        writeDataUltraFast(commands)
//        result(true)
//    }
//
//    private func resizeImage(image: UIImage, maxWidth: Int) -> UIImage {
//        let size = image.size
//        if size.width <= CGFloat(maxWidth) { return image }
//
//        let ratio = CGFloat(maxWidth) / size.width
//        let newSize = CGSize(width: CGFloat(maxWidth), height: size.height * ratio)
//
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        image.draw(in: CGRect(origin: .zero, size: newSize))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return resizedImage ?? image
//    }
//
//    private func feedPaper(lines: Int, result: @escaping FlutterResult) {
//        var commands = Data()
//        for _ in 0..<lines {
//            commands.append(0x0A)
//        }
//        writeDataUltraFast(commands)
//        result(true)
//    }
//
//    private func cutPaper(result: @escaping FlutterResult) {
//        let commands = Data([GS, 0x56, 0x00])
//        writeDataUltraFast(commands)
//        result(true)
//    }
//
//    private func getStatus(result: @escaping FlutterResult) {
//        var connected = false
//
//        switch currentConnectionType {
//        case "bluetooth", "ble":
//            connected = connectedPeripheral?.state == .connected && writeCharacteristic != nil
//        case "usb":
//            connected = session != nil && writeStream?.streamStatus == .open
//        case "network":
//            connected = networkConnection?.state == .ready
//        default:
//            break
//        }
//
//        result([
//            "connected": connected,
//            "paperStatus": "ok",
//            "connectionType": currentConnectionType,
//            "printerWidth": printerWidth
//        ])
//    }
//
//    private func setPrinterWidth(width: Int, result: @escaping FlutterResult) {
//        if width == 384 || width == 576 {
//            printerWidth = width
//            result(true)
//        } else {
//            result(FlutterError(code: "INVALID_WIDTH", message: "Width must be 384 or 576", details: nil))
//        }
//    }
//
//    private func checkBluetoothPermission(result: @escaping FlutterResult) {
//        let state = centralManager.state
//
//        var status: [String: Any] = [:]
//
//        switch state {
//        case .poweredOn:
//            status = ["status": "authorized", "enabled": true, "message": "Bluetooth is ready"]
//        case .poweredOff:
//            status = ["status": "authorized", "enabled": false, "message": "Bluetooth is turned off"]
//        case .unauthorized:
//            status = ["status": "denied", "enabled": false, "message": "Bluetooth permission denied"]
//        case .unsupported:
//            status = ["status": "unsupported", "enabled": false, "message": "Bluetooth not supported"]
//        case .resetting:
//            status = ["status": "resetting", "enabled": false, "message": "Bluetooth is resetting"]
//        case .unknown:
//            status = ["status": "unknown", "enabled": false, "message": "Bluetooth state unknown"]
//        @unknown default:
//            status = ["status": "unknown", "enabled": false, "message": "Unknown Bluetooth state"]
//        }
//
//        result(status)
//    }
//
//    // MARK: - StreamDelegate
//
//    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//        switch eventCode {
//        case .hasSpaceAvailable:
//            break
//        case .errorOccurred:
//            print("Stream error: \(aStream.streamError?.localizedDescription ?? "Unknown")")
//        case .endEncountered:
//            print("Stream ended")
//        default:
//            break
//        }
//    }
//}
//
