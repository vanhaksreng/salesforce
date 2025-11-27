import CoreBluetooth
import Flutter
import Foundation
import UIKit
import WebKit

@objc
class BluetoothPrinterHandler: NSObject, FlutterPlugin, CBCentralManagerDelegate,
    CBPeripheralDelegate
{

    private var methodChannel: FlutterMethodChannel?
    private var centralManager: CBCentralManager?
    private var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var connectResultCallback: FlutterResult?

    // MARK: - FlutterPlugin Protocol
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BluetoothPrinterHandler()
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
                let address = args["address"] as? String
            {
                connectDevice(address: address, result: result)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "Address is required",
                        details: nil
                    ))
            }

        case "printText":
            if let args = call.arguments as? [String: Any],
                let text = args["text"] as? String
            {
                printText(text: text, result: result)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "Text is required",
                        details: nil
                    ))
            }
        case "printHtml":
            if let args = call.arguments as? [String: Any],
                let html = args["html"] as? String
            {
                printHtml(html: html, result: result)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "HTML is required",
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

        print("Bluetooth scanDevices....")

        discoveredPeripherals.removeAll()

        guard let centralManager = centralManager else {
            result(
                FlutterError(
                    code: "BLUETOOTH_ERROR",
                    message: "Bluetooth manager not initialized",
                    details: nil
                ))

            print("BLUETOOTH_ERROR - Bluetooth manager not initialized")
            return
        }

        // Check Bluetooth state
        if centralManager.state != .poweredOn {
            result(
                FlutterError(
                    code: "BLUETOOTH_ERROR",
                    message: "Bluetooth is not available or turned off",
                    details: nil
                ))

            print("BLUETOOTH_ERROR - Bluetooth is not available or turned off")
            return
        }

        // Start scanning
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [
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
            result(
                FlutterError(
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
                self.connectResultCallback?(
                    FlutterError(
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
            peripheral.state == .connected
        else {
            result(
                FlutterError(
                    code: "NOT_CONNECTED",
                    message: "No device connected",
                    details: nil
                ))
            return
        }

        guard let characteristic = writeCharacteristic else {
            result(
                FlutterError(
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

        // Line feed (LF) to advance paper and make text visible
        data.append(0x0A)

        // Optional: Feed 1 line more for spacing (ESC d 1)
        data.append(contentsOf: [0x1B, 0x64, 0x01])

        // Cut paper: Try partial cut first (GS V B 0) for labels/receipts; fallback to full (GS V 0)
        // You can make this configurable via args if needed
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

    // Updated: HTML to ESC/POS via image rendering for Khmer support
    private func printHtml(html: String, result: @escaping FlutterResult) {
        guard let peripheral = connectedPeripheral,
            peripheral.state == .connected
        else {
            result(
                FlutterError(
                    code: "NOT_CONNECTED",
                    message: "No device connected",
                    details: nil
                ))
            return
        }

        guard let characteristic = writeCharacteristic else {
            result(
                FlutterError(
                    code: "NO_CHARACTERISTIC",
                    message: "Write characteristic not found",
                    details: nil
                ))
            return
        }

        // Parse basic HTML to text
        let parsedText = parseBasicHtml(html)
        //print("Parsed HTML to: \(parsedText)")  // Debug

        // For Khmer support, render text as image since most thermal printers (including Xprinter) do not support Khmer Unicode directly via code pages.
        // We render using a Khmer-supporting font and convert to ESC/POS raster graphics (GS v 0).
        // To handle large text (e.g., >5MB), paginate into chunks of max ~2000 dots height.

        let pointsPerDot: CGFloat = 72.0 / 203.0
        let dotWidth: Int = 384  // 58mm printer
        let labelWidth = CGFloat(dotWidth) * pointsPerDot
        let maxPageDots: Int = 2000  // Adjustable: max height per page in dots (~10 inches)
        let maxPageHeightPoints = CGFloat(maxPageDots) * pointsPerDot

        let khmerFontName = "KhmerSangamMN"
        let font = UIFont(name: khmerFontName, size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 2.0

        // Split into lines for better chunking
        let lines = parsedText.components(separatedBy: .newlines).filter { !$0.isEmpty }

        var printData = Data()
        printData.append(contentsOf: [0x1B, 0x40])  // Initialize printer
        printData.append(contentsOf: [0x1B, 0x21, 0x00])  // Normal font

        for line in lines {
            var remainingText = line
            while !remainingText.isEmpty {
                // Find the largest prefix chunk that fits max height
                let chunk = largestFittingChunk(
                    from: remainingText, maxHeight: maxPageHeightPoints, font: font,
                    paragraphStyle: paragraphStyle, width: labelWidth)

                guard let image = imageFromText(chunk, dotWidth: dotWidth, fontSize: 20.0) else {
                    print("Warning: Failed to render chunk: \(chunk.prefix(50))...")
                    break
                }

                let rasterData = escPosRaster(from: image)
                printData.append(rasterData)

                // Advance to next chunk
                let chunkLength = chunk.utf16.count  // Use UTF-16 for consistency in multi-byte chars like Khmer
                let nextIndex =
                    remainingText.utf16.index(
                        remainingText.utf16.startIndex, offsetBy: chunkLength,
                        limitedBy: remainingText.utf16.endIndex) ?? remainingText.utf16.endIndex
                remainingText = String(remainingText[nextIndex...])
            }

            // Optional: Small feed between lines if not paginated (but since rasters advance automatically, minimal)
            // printData.append(0x0A)  // Uncomment if needed for line separation
        }

        // Cut paper at the end
        printData.append(contentsOf: [0x1D, 0x56, 0x42, 0x00])  // Partial cut

        print("📄 Sending paginated HTML image print data (\(printData.count) bytes)")

        // Write data (for very large data, consider chunking writes if Bluetooth MTU is small, but iOS handles)
        if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(printData, for: characteristic, type: .withoutResponse)
        } else {
            peripheral.writeValue(printData, for: characteristic, type: .withResponse)
        }

        result(true)
    }

    // New: Find the largest prefix of text that fits within max height when wrapped
    private func largestFittingChunk(
        from text: String, maxHeight: CGFloat, font: UIFont, paragraphStyle: NSParagraphStyle,
        width: CGFloat
    ) -> String {
        if text.isEmpty { return "" }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
        ]

        // Binary search for the maximum character count that fits
        let charCount = text.count
        var low = 0
        var high = charCount

        while low < high {
            let mid = low + (high - low + 1) / 2
            let prefix = String(text.prefix(mid))
            let attributedPrefix = NSAttributedString(string: prefix, attributes: attributes)
            let prefixSize = attributedPrefix.boundingRect(
                with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size.height

            if prefixSize <= maxHeight {
                low = mid
            } else {
                high = mid - 1
            }
        }

        let fittingCount = low
        if fittingCount == 0 { return "" }

        var chunk = String(text.prefix(fittingCount))

        // Optional: Improve split by finding last space before end to avoid mid-word breaks
        if let lastSpaceIndex = chunk.lastIndex(of: " ") {
            chunk = String(chunk[..<lastSpaceIndex]) + " "  // Include space for natural flow
        }

        return chunk
    }

    // New: Render text to UIImage using Khmer-supporting font
    // Updated: Render text to UIImage using Khmer-supporting font (fixed flip order and rendering method)
    private func imageFromText(_ text: String, dotWidth: Int = 384, fontSize: CGFloat = 20.0)
        -> UIImage?
    {
        // DPI for thermal printers ~203, points per inch 72, so points per dot ~72/203 ≈ 0.355
        // Label width in points: dotWidth * (72 / 203)
        let pointsPerDot: CGFloat = 72.0 / 203.0
        let labelWidth = CGFloat(dotWidth) * pointsPerDot  // ~136 points for 384 dots

        let khmerFontName = "KhmerSangamMN"  // iOS font supporting Khmer; fallback to system if unavailable
        let font =
            UIFont(name: khmerFontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left  // Or .center for centering
        paragraphStyle.lineSpacing = 2.0

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
            ]
        )

        let label = UILabel()
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear  // Ensure transparent background

        let textSize = attributedText.boundingRect(
            with: CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size

        // Add some padding for better rendering
        let padding: CGFloat = 4.0
        let renderSize = CGSize(
            width: labelWidth + padding * 2, height: textSize.height + padding * 2)

        UIGraphicsBeginImageContextWithOptions(renderSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Standard flip to match UIKit coordinates (top-left origin)
        context.translateBy(x: 0, y: renderSize.height)
        context.scaleBy(x: 1, y: -1)

        // Position label with padding
        let labelFrame = CGRect(x: padding, y: -padding, width: labelWidth, height: textSize.height)
        label.frame = labelFrame
        label.layer.render(in: context)  // Correct method: render(in: CGContext), not draw

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // Updated: Convert UIImage to ESC/POS raster graphics data (GS v 0) - fixed row order
    private func escPosRaster(from image: UIImage) -> Data {
        guard let cgImage = image.cgImage else { return Data() }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerLine = (width + 7) / 8

        var rasterData = Data(capacity: bytesPerLine * height + 10)  // +10 for header

        // Header: GS v 0 m xL xH yL yH
        rasterData.append(0x1D)  // GS
        rasterData.append(0x76)  // v
        rasterData.append(0x30)  // 0 (raster bit image)
        rasterData.append(0x00)  // m=0 (normal)
        rasterData.append(UInt8(bytesPerLine & 0xFF))  // xL
        rasterData.append(UInt8((bytesPerLine >> 8) & 0xFF))  // xH
        rasterData.append(UInt8(height & 0xFF))  // yL
        rasterData.append(UInt8((height >> 8) & 0xFF))  // yH

        // Convert to grayscale bitmap
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapBytesPerRow = width
        let bitmapByteCount = bitmapBytesPerRow * height
        let bitmapData = malloc(bitmapByteCount)!
        defer { free(bitmapData) }

        let bitmapContext = CGContext(
            data: bitmapData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!

        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let bitmapBytes = bitmapData.assumingMemoryBound(to: UInt8.self)

        // Pack bits: 8 vertical pixels per byte? Wait, no: for GS v 0, it's horizontal bytes, bits vertical? No.
        // Actually, for raster bit image, each byte represents 8 pixels in a row (horizontal), bits from left to right, MSB left.
        // Rows from top to bottom.
        // But since bitmapData is bottom-up (y=0 is bottom), we need to read rows from bottom to top for correct top-to-bottom print.
        for y in 0..<height {
            let sourceY = height - 1 - y  // Flip: map output y=0 (top) to source bottom row
            let rowOffset = sourceY * bitmapBytesPerRow

            for byteIndex in 0..<bytesPerLine {
                var byte: UInt8 = 0
                for bit in 0..<8 {
                    let x = byteIndex * 8 + bit
                    if x < width {
                        let pixelIndex = rowOffset + x
                        let pixel = bitmapBytes[pixelIndex]
                        // Black if pixel > 128 (grayscale threshold; adjust if needed for better contrast)
                        if pixel > 128 {
                            byte |= UInt8(1 << (7 - bit))  // MSB (bit 7) for leftmost pixel
                        }
                    }
                }
                rasterData.append(byte)
            }
        }

        return rasterData
    }

    // Simple HTML parser (extend as needed; now feeds into image renderer)
    private func parseBasicHtml(_ html: String) -> String {
        var text = html

        // Remove unsupported tags (basic whitelist)
        let supportedTags = ["p", "b", "i", "u", "center", "br"]
        for tag in supportedTags {
            // Map <b> to bold (ESC E 1), but for simplicity, just extract text and note styles
            // Full impl: Track state for open/close tags
            text = text.replacingOccurrences(of: "<\(tag)>", with: "", options: .caseInsensitive)
            text = text.replacingOccurrences(of: "</\(tag)>", with: "", options: .caseInsensitive)
        }
        text = text.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)  // Line break
        text = text.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        text = text.replacingOccurrences(of: "<center>", with: "\n", options: .caseInsensitive)  // Centering handled in attributed string if needed
        text = text.replacingOccurrences(of: "</center>", with: "\n", options: .caseInsensitive)

        // Strip other tags roughly (improve with regex/NSAttributedString)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // For basic bold/italic, could enhance attributed string in imageFromText
        // e.g., detect <b> spans and apply .font = bold font

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
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
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // Avoid duplicates
        if discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            return
        }

        if peripheral.name == nil {
            return
        }

        discoveredPeripherals.append(peripheral)

        let deviceInfo: [String: String] = [
            "code": "OK",
            "name": peripheral.name ?? "Unknown Device",
            "address": peripheral.identifier.uuidString,
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

        connectResultCallback?(
            FlutterError(
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

            if characteristic.properties.contains(.write)
                || characteristic.properties.contains(.writeWithoutResponse)
            {
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
        if writeCharacteristic == nil
            && peripheral.services?.allSatisfy({ $0.characteristics != nil }) == true
        {
            connectResultCallback?(
                FlutterError(
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
