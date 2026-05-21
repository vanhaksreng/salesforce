import Flutter
import UIKit
import CoreBluetooth

/// A Flutter plugin that handles Bluetooth (BLE) printer communication.
final class BluetoothPrinterPlugin: NSObject, FlutterPlugin {

    static let channelName = "com.clearviewerp.pos_printer/bluetooth"

    /// Classic-BT Serial Port Profile UUID kept for BLE service filtering.
    private static let sppServiceUUID = CBUUID(string: "00001101-0000-1000-8000-00805F9B34FB")

    // ESC/POS Commands
    private static let ESC_INIT: [UInt8] = [0x1B, 0x40]
    private static let FEED_LINES: [UInt8] = [0x1B, 0x64, 0x01]
    private static let FULL_CUT: [UInt8] = [0x1D, 0x56, 0x00]
    private static let ALIGN_CENTER: [UInt8] = [0x1B, 0x61, 0x01]

    // ===================================================================
    // MARK: - Properties
    // ===================================================================

    private let executor = DispatchQueue(
        label: "com.clearviewerp.bluetooth.executor",
        qos: .userInitiated
    )

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    /// Peripherals seen during the current BLE scan.
    private var discoveredPeripherals: [CBPeripheral] = []

    // Pending Flutter results — stored so async CB callbacks can resolve them.
    private var pendingPermResult: FlutterResult?
    private var pendingScanResult: FlutterResult?
    private var pendingConnectResult: FlutterResult?
    private var pendingPrintResult: FlutterResult?

    // Chunked-write state (mirrors BufferedOutputStream behaviour).
    private var pendingWriteData: Data?
    private var writeDataOffset: Int = 0
    private var isWritingChunks: Bool = false

    // ===================================================================
    // MARK: - FlutterPlugin Registration
    // ===================================================================

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = BluetoothPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // ===================================================================
    // MARK: - Initialiser
    // ===================================================================

    override init() {
        super.init()
        // Initialising CBCentralManager with `queue: executor` means every
        // delegate callback fires on `executor`, not the main thread.
        centralManager = CBCentralManager(delegate: self, queue: executor)
    }

    // ===================================================================
    // MARK: - FlutterPlugin Method Handler (mirrors onMethodCall)
    // ===================================================================

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "requestPermissions":
            handleRequestPermissions(result: result)

        case "scanDevices":
            handleScanDevices(result: result)

        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let address = args["address"] as? String else {
                result(FlutterError(
                    code: "NO_ADDRESS", message: "Address is required", details: nil
                ))
                return
            }
            handleConnect(address: address, result: result)

        case "disconnect":
            handleDisconnect(result: result)

        case "isDeviceAvailable":
            handleIsDeviceAvailable(call: call, result: result)

        case "printReceipt":
            let args = call.arguments as? [String: Any]
            let text = args?["text"] as? String ?? ""
            let printerName = args?["printerName"] as? String ?? ""
            let logoData = (args?["logoBytes"] as? FlutterStandardTypedData)?.data
            let paperWidth = args?["paperWidth"] as? Int ?? 576

            printKhmerReceipt(
                text: text, 
                paperWidth: paperWidth,
                printerName: printerName,
                logoBytes: logoData, 
                result: result
            )

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // ===================================================================
    // MARK: - Permissions Logic (mirrors handleRequestPermissions)
    // ===================================================================

    private func handleRequestPermissions(result: @escaping FlutterResult) {
        if #available(iOS 13.1, *) {
            let authorization = CBCentralManager.authorization
            switch authorization {
            case .allowedAlways:
                DispatchQueue.main.async { result(true) }

            case .notDetermined:
                // Store the result; it will be resolved in
                // `centralManagerDidUpdateState(_:)` once the system
                // shows the permission dialog and the user responds.
                pendingPermResult = result

            case .restricted, .denied:
                DispatchQueue.main.async { result(false) }

            @unknown default:
                DispatchQueue.main.async { result(false) }
            }
        } else {
            // iOS < 13.1: no explicit BT authorisation required.
            DispatchQueue.main.async { result(true) }
        }
    }

    // ===================================================================
    // MARK: - Scan & Connect Logic
    // ===================================================================

    /// Returns a list of nearby BLE devices.
    /// Mirrors `handleScanDevices`, replacing `adapter.bondedDevices`
    /// with a 3-second active BLE scan.
    private func handleScanDevices(result: @escaping FlutterResult) {
        executor.async { [weak self] in
            guard let self = self else { return }

            guard self.centralManager.state == .poweredOn else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "NO_BT",
                        message: "Bluetooth not available or not powered on",
                        details: nil
                    ))
                }
                return
            }

            // Clear previous scan results and register the pending result.
            self.discoveredPeripherals.removeAll()
            self.pendingScanResult = result

            // ចាប់ផ្ដើមស្កេន BLE — mirrors `adapter.startDiscovery()`. We scan for all
            self.centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )

            // Stop after 5 seconds and return the collected list — mirrors
            // the synchronous `bondedDevices` call by settling after a fixed window.
            self.executor.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                guard let self = self else { return }
                self.centralManager.stopScan()

                // Filter to include only peripherals with a valid, non-nil name
                let list: [[String: String]] = self.discoveredPeripherals
                .filter { $0.name != nil && !$0.name!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map { peripheral in
                    return ["name": peripheral.name!, "address": peripheral.identifier.uuidString]
                }

                DispatchQueue.main.async { [weak self] in
                    self?.pendingScanResult?(list)
                    self?.pendingScanResult = nil
                }
            }
        }
    }

    /// Connects to the peripheral identified by `address` (its UUID string).
    /// Mirrors `handleConnect(address:result:)`.
    private func handleConnect(address: String, result: @escaping FlutterResult) {
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            DispatchQueue.main.async {
                result(FlutterError(
                    code: "NO_ADDRESS", message: "Address is required", details: nil
                ))
            }
            return
        }

        executor.async { [weak self] in
            guard let self = self else { return }

            // Tear down any existing connection — mirrors `closeConnection()` call.
            self.closeConnection()

            guard self.centralManager.state == .poweredOn else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "CONNECT_FAILED",
                        message: "Bluetooth adapter unavailable",
                        details: nil
                    ))
                }
                return
            }

            // Resolve UUID — mirrors `adapter.getRemoteDevice(address)`.
            guard let uuid = UUID(uuidString: address) else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "CONNECT_FAILED",
                        message: "Invalid device identifier format",
                        details: nil
                    ))
                }
                return
            }

            // Look up the peripheral: first try the system cache (equivalent
            // to `getRemoteDevice`), then fall back to scan results.
            let knownPeripherals = self.centralManager.retrievePeripherals(
                withIdentifiers: [uuid]
            )

            if let peripheral = knownPeripherals.first {
                self.connectedPeripheral = peripheral
                peripheral.delegate = self
                self.pendingConnectResult = result
                self.centralManager.connect(peripheral, options: nil)
            } else if let peripheral = self.discoveredPeripherals.first(
                where: { $0.identifier.uuidString == address }
            ) {
                self.connectedPeripheral = peripheral
                peripheral.delegate = self
                self.pendingConnectResult = result
                self.centralManager.connect(peripheral, options: nil)
            } else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "CONNECT_FAILED",
                        message: "Device not found. Please scan first.",
                        details: nil
                    ))
                }
            }
        }
    }

    /// Mirrors `handleDisconnect(result:)`.
    private func handleDisconnect(result: @escaping FlutterResult) {
        executor.async { [weak self] in
            guard let self = self else { return }
            self.closeConnection()
            DispatchQueue.main.async { result(nil) }
        }
    }

    /// Tears down the active connection.
    /// Mirrors `closeConnection()`.
    private func closeConnection() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheral = nil
        writeCharacteristic = nil
        pendingWriteData = nil
        isWritingChunks = false
        writeDataOffset = 0
    }

    /// Checks if a device with the given address is currently available (either bonded or discovered). 
    /// Mirrors `handleIsDeviceAvailable`, replacing the bonded device check with a lookup in the `discoveredPeripherals` array, which is populated during BLE scans.
    private func handleIsDeviceAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {

        guard let args = call.arguments as? [String: Any],
              let targetAddress = args["address"] as? String else {
            result(false)
            return
        }

        let isAvailable = discoveredPeripherals.contains { peripheral in
            return peripheral.identifier.uuidString.lowercased() == targetAddress.lowercased()
        }
        
        result(isAvailable)
    }

    // ===================================================================
    // MARK: - Print Logic (mirrors printKhmerReceipt)
    // ===================================================================

    private func printKhmerReceipt(
        text: String,
        paperWidth: Int,
        printerName: String,
        logoBytes: Data?,
        result: @escaping FlutterResult
    ) {
        executor.async { [weak self] in
            guard let self = self else { return }

            guard let characteristic = self.writeCharacteristic,
                  let peripheral = self.connectedPeripheral else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "PRINT_ERROR", message: "Printer not connected", details: nil
                    ))
                }
                return
            }

            do {
                var data = Data()
                data.append(contentsOf: BluetoothPrinterPlugin.ESC_INIT)
                data.append(contentsOf: BluetoothPrinterPlugin.ALIGN_CENTER)

                let bitmap = try self.createKhmerBitmap(text: text, logoBytes: logoBytes, paperWidth: paperWidth)
                let imageData = self.imageDataForPrinter(bitmap: bitmap)
                data.append(imageData)

                data.append(contentsOf: BluetoothPrinterPlugin.FEED_LINES)
                data.append(contentsOf: BluetoothPrinterPlugin.FULL_CUT)

                // Kick off chunked write — mirrors `stream.flush()`.
                self.pendingPrintResult = result
                self.pendingWriteData = data
                self.writeDataOffset = 0
                self.isWritingChunks = true
                self.writeNextChunk(peripheral: peripheral, characteristic: characteristic)

            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "PRINT_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }
    }

    // ===================================================================
    // MARK: - Chunked BLE Write (mirrors BufferedOutputStream writes)
    // ===================================================================

    /// Writes `data` to `characteristic` in 512-byte chunks, sequencing
    /// each chunk only after the previous one is acknowledged.
    private func writeNextChunk(
        peripheral: CBPeripheral,
        characteristic: CBCharacteristic
    ) {
        guard isWritingChunks, let data = pendingWriteData else { return }

        let remaining = data.count - writeDataOffset
        guard remaining > 0 else {
            isWritingChunks = false
            pendingWriteData = nil
            DispatchQueue.main.async { [weak self] in
                self?.pendingPrintResult?("Printed successfully")
                self?.pendingPrintResult = nil
            }
            return
        }

        // Drop chunk size down to protect hardware buffers
        let chunkSize = 128
        let size = min(chunkSize, remaining)
        let chunk = data.subdata(in: writeDataOffset ..< writeDataOffset + size)

        // Check availability explicitly
        let canWriteWithResponse = characteristic.properties.contains(.write)
        let canWriteWithoutResponse = characteristic.properties.contains(.writeWithoutResponse)

        if canWriteWithResponse {
            writeDataOffset += size
            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
            // -> Triggers didWriteValueFor to send the next chunk safely
        } else if canWriteWithoutResponse {
            // Double check that the peripheral is ready for un-acknowledged data flood
            if peripheral.canSendWriteWithoutResponse {
                writeDataOffset += size
                peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)

                // For writeWithoutResponse, manually cycle the loop on the executor queue
                // with a micro-delay (e.g., 5-10ms) to allow the printer hardware to breathe.
                executor.asyncAfter(deadline: .now() + 0.005) { [weak self] in
                    self?.writeNextChunk(peripheral: peripheral, characteristic: characteristic)
                }
            } else {
                // Peripheral buffer is full; back off and wait for peripheralIsReady(toSendWriteWithoutResponse:)
                // Do NOT increment writeDataOffset yet.
            }
        }
    }

    // ===================================================================
    // MARK: - Bitmap Creation (mirrors createKhmerBitmap)
    // ===================================================================

    private func createKhmerBitmap(text: String, logoBytes: Data?, paperWidth: Int) throws -> UIImage {

        let printerWidth = paperWidth // 80mm | 58mm
        let padding = 20
        let maxTextWidth = printerWidth - (padding * 2)
        let textFontSize = printerWidth == 384 ? 16.0 : 22.0

        // Load custom font — mirrors Typeface.createFromAsset; falls back to
        // system font if the asset is missing (mirrors Typeface.DEFAULT).
        let typefaceRegular: UIFont =
            UIFont(name: "NotoSansKhmer-Regular", size: textFontSize)
            ?? UIFont.systemFont(ofSize: textFontSize)

        let boldDescriptor = typefaceRegular.fontDescriptor.withSymbolicTraits(.traitBold)
            ?? typefaceRegular.fontDescriptor
        let typefaceBold = UIFont(descriptor: boldDescriptor, size: textFontSize)

        let lines = text.components(separatedBy: "\n")

        // Stores (attributed string, x, y, width) for each text block.
        typealias LayoutEntry = (text: NSAttributedString, x: Int, y: Int, width: Int)
        var layoutsWithPositions: [LayoutEntry] = []
        var horizontalLinesY: [Int] = []

        // Initial top margin — mirrors `var totalHeight = 10`.
        var totalHeight = 10
        var logoBitmap: UIImage?

        // ── Logo processing ────────────────────────────────────────────
        if let logoBytes = logoBytes, !logoBytes.isEmpty {
            if let rawBitmap = UIImage(data: logoBytes) {
                let desiredWidth: CGFloat = 170
                let aspectRatio = rawBitmap.size.height / rawBitmap.size.width
                let desiredHeight = desiredWidth * aspectRatio

                let logoFormat = UIGraphicsImageRendererFormat()
                logoFormat.scale = 1.0 // 1 pt = 1 px — prevents Retina 2x/3x inflation
                let renderer = UIGraphicsImageRenderer(
                    size: CGSize(width: desiredWidth, height: desiredHeight),
                    format: logoFormat
                )
                logoBitmap = renderer.image { _ in
                    rawBitmap.draw(in: CGRect(
                        x: 0, y: 0, width: desiredWidth, height: desiredHeight
                    ))
                }
                totalHeight += Int(desiredHeight) + 5
            }
        }

        // Column layout config — mirrors colWidths / colPositions arrays.
        // let colWidths: [Int] = [36, 160, 65, 100, 75, 100]

        // គណនាសមាមាត្រជួរឈររបស់តារាងទៅតាមទំហំក្រដាស (Responsive Columns)
        let scaleFactor = CGFloat(printerWidth) / 576.0
        let colWidths: [Int] = [
            Int(40.0 * scaleFactor),
            Int(193.0 * scaleFactor),
            Int(65.0 * scaleFactor),
            Int(80.0 * scaleFactor),
            Int(68.0 * scaleFactor),
            Int(90.0 * scaleFactor)
        ]

        //  let colWidths: [Int] = [
        //     Int(36.0 * scaleFactor),
        //     Int(170.0 * scaleFactor),
        //     Int(65.0 * scaleFactor),
        //     Int(100.0 * scaleFactor),
        //     Int(65.0 * scaleFactor),
        //     Int(100.0 * scaleFactor)
        // ]

        // let colPositions: [Int] = [0, 36, 196, 261, 361, 436]
        var colPositions: [Int] = []
        var currentPos = 0
        for width in colWidths {
            colPositions.append(currentPos)
            currentPos += width
        }

        // ── Line processing loop ───────────────────────────────────────
        for line in lines {
            var cleanLine = line
            var isBold = false
            var isTable = false

            if cleanLine.contains("[TABLE]") {
                isTable = true
                cleanLine = cleanLine.replacingOccurrences(of: "[TABLE]", with: "")
            }

            if cleanLine.contains("<b>") && cleanLine.contains("</b>") {
                isBold = true
                cleanLine = cleanLine
                    .replacingOccurrences(of: "<b>", with: "")
                    .replacingOccurrences(of: "</b>", with: "")
            }

            // Horizontal rule — mirrors the [LINE] tag logic.
            if cleanLine.contains("[LINE]") {
                horizontalLinesY.append(totalHeight)
                totalHeight += 5
                continue
            }

            let currentFont = isBold ? typefaceBold : typefaceRegular

            if isTable {
                let rawParts = cleanLine.components(separatedBy: ",")
                let columns: [String] = {
                    if rawParts.count <= colWidths.count {
                        return rawParts
                    }
                    let overflowCount = rawParts.count - colWidths.count
                    let mergedItemName = rawParts[1 ..< (2 + overflowCount)].joined(separator: ",")
                    var result = [rawParts[0], mergedItemName]
                    result.append(contentsOf: rawParts[(2 + overflowCount)...])
                    return result
                }()

                var maxHeightInRow = 0

                for (i, _) in columns.enumerated() {
                    guard i < colWidths.count else { break } // Prevent out of bounds
                    let cellText = columns[i].trimmingCharacters(in: .whitespaces)
                    let textAlignment: NSTextAlignment = {
                        if i <= 1 {
                            return .left // ALIGN_NORMAL for columns 0 and 1
                        }

                        return .right

                        // let isHeaderRow = line.range(of: "Qty|Price|Total|ចំនួន|តម្លៃ|ចុះតម្លៃ|សរុប", options: .regularExpression) != nil
                        // let isHeaderRow = cleanLine.range(
                        //     of: "Qty|Price|Total|Dis|ចំនួន|តម្លៃ|ចុះតម្លៃ|សរុប", 
                        //     options: [.regularExpression, .caseInsensitive]
                        // ) != nil

                        // return isHeaderRow ? .right : .center // ALIGN_OPPOSITE or ALIGN_CENTER
                    }()

                    let attrStr = makeAttributedString(
                        text: cellText,
                        font: currentFont,
                        alignment: textAlignment
                    )

                    let boundedRect = attrStr.boundingRect(
                        with: CGSize(width: CGFloat(colWidths[i]), height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        context: nil
                    )
                    let cellHeight = Int(ceil(boundedRect.height))
                    if cellHeight > maxHeightInRow { maxHeightInRow = cellHeight }

                    layoutsWithPositions.append((
                        text: attrStr,
                        x: colPositions[i] + padding,
                        y: totalHeight,
                        width: colWidths[i]
                    ))
                }
                totalHeight += maxHeightInRow + 5

            } else {
                var alignment: NSTextAlignment = .left // ALIGN_NORMAL

                if cleanLine.contains("[C]") {
                    alignment = .center
                    cleanLine = cleanLine.replacingOccurrences(of: "[C]", with: "")
                } else if cleanLine.contains("[R]") {
                    alignment = .right
                    cleanLine = cleanLine.replacingOccurrences(of: "[R]", with: "")
                }

                let attrStr = makeAttributedString(
                    text: cleanLine,
                    font: currentFont,
                    alignment: alignment
                )

                let boundedRect = attrStr.boundingRect(
                    with: CGSize(width: CGFloat(maxTextWidth), height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
                let textHeight = Int(ceil(boundedRect.height))

                layoutsWithPositions.append((
                    text: attrStr,
                    x: padding,
                    y: totalHeight,
                    width: maxTextWidth
                ))
                totalHeight += textHeight
            }
        }

        // ── Render into a Bitmap ───────────────────────────────────────
        let imageSize = CGSize(width: printerWidth, height: totalHeight + 15)
        // scale = 1.0 forces 1 pt = 1 px so the bitmap sent to the printer
        // is exactly `printerWidth` pixels wide, not 2x or 3x on Retina devices.
        let bitmapFormat = UIGraphicsImageRendererFormat()
        bitmapFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: bitmapFormat)

        let resultImage = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            
            // CRITICAL ALIGNMENT & HARDENING SETTINGS
            cgCtx.setShouldAntialias(false)
            cgCtx.setAllowsAntialiasing(false)
            cgCtx.setShouldSmoothFonts(false)
            cgCtx.setAllowsFontSmoothing(false)
            cgCtx.setShouldSubpixelPositionFonts(false)
            cgCtx.setShouldSubpixelQuantizeFonts(false)
            cgCtx.interpolationQuality = .none

            // White background
            UIColor.white.setFill()
            cgCtx.fill(CGRect(origin: .zero, size: imageSize))

            // Draw logo centred at the top
            if let logo = logoBitmap {
                let logoX = (CGFloat(printerWidth) - logo.size.width) / 2.0
                let logoY: CGFloat = 10
                logo.draw(at: CGPoint(x: logoX, y: logoY))
            }

            // Draw horizontal rule lines
            cgCtx.setStrokeColor(UIColor.black.cgColor)
            cgCtx.setLineWidth(2)
            for lineY in horizontalLinesY {
                cgCtx.move(to: CGPoint(x: padding, y: lineY))
                cgCtx.addLine(to: CGPoint(x: printerWidth - padding, y: lineY))
                cgCtx.strokePath()
            }

            // Draw all text layouts
            UIGraphicsPushContext(cgCtx)
            for entry in layoutsWithPositions {
                let drawRect = CGRect(
                    x: entry.x,
                    y: entry.y + 5,
                    width: entry.width,
                    height: Int(imageSize.height)
                )
                entry.text.draw(
                    with: drawRect,
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
            }
            UIGraphicsPopContext()
        }

        return resultImage
    }

    /// Builds an `NSAttributedString` with the requested font, colour, and
    /// paragraph alignment.
    private func makeAttributedString(
        text: String,
        font: UIFont,
        alignment: NSTextAlignment
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        // lineSpacing in NSParagraphStyle is an additive delta; we approximate
        // 1.2× by adding 20% of the line height.
        paragraphStyle.lineSpacing = font.lineHeight * 0.2

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    // ===================================================================
    // MARK: - ESC/POS Raster Image Encoding (mirrors sendImageToPrinter)
    // ===================================================================

    /// Converts a `UIImage` to ESC/POS raster data and returns it as `Data`.
    private func imageDataForPrinter(bitmap: UIImage) -> Data {
        guard let cgImage = bitmap.cgImage else { return Data() }

        let width = cgImage.width
        let height = cgImage.height

        // Create a properly oriented bitmap context using UIKit drawing
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return Data() }

        UIGraphicsPushContext(context)

        // Flip the context so UIKit's top-left origin maps to CG's bottom-left
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)

        // Draw the UIImage directly (respects .orientation metadata)
        bitmap.draw(in: CGRect(x: 0, y: 0, width: width, height: height))

        UIGraphicsPopContext()

        var data = Data()

        // Set line spacing to 24 dots
        data.append(contentsOf: [0x1B, 0x33, 24])

        var y = 0
        while y < height {
            var command: [UInt8] = [
                0x1B, 0x2A, // ESC *
                33, // 24-dot double density mode
                UInt8(width % 256),
                UInt8(width / 256)
            ]

            for x in 0..<width {
                for k in 0..<3 { // 3 bytes = 24 vertical dots
                    var byteData: UInt8 = 0
                    for b in 0..<8 {
                        let pixelY = y + (k * 8) + b
                        if pixelY < height {
                            let index = pixelY * bytesPerRow + x * bytesPerPixel
                            let red = pixelData[index]     // R in RGBA
                            let alpha = pixelData[index + 3] // A in RGBA (ស្ថិតនៅលំដាប់ទី៤ នៃ Byte នីមួយៗ)

                            if alpha > 30 && red < 140 { 
                                byteData |= (1 << (7 - b))
                            }
                        }
                    }
                    command.append(byteData)
                }
            }

            data.append(contentsOf: command)
            data.append(0x0A) // Line feed

            y += 24
        }

        // Restore default line spacing
        data.append(contentsOf: [0x1B, 0x32])

        return data
    }

    func dispose() {
        closeConnection()
        centralManager.stopScan()
    }
}

// ===================================================================
// MARK: - CBCentralManagerDelegate
// ===================================================================

extension BluetoothPrinterPlugin: CBCentralManagerDelegate {

    /// Required delegate method — called whenever the Bluetooth radio state changes.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {

        case .poweredOn:
            // Radio is ready — resolve any pending permission request.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingPermResult?(true)
                self.pendingPermResult = nil
            }

        case .poweredOff:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let error = FlutterError(
                    code: "BT_OFF", message: "Bluetooth is powered off", details: nil
                )
                self.pendingScanResult?(error)
                self.pendingScanResult = nil
                self.pendingConnectResult?(error)
                self.pendingConnectResult = nil
            }

        case .unauthorized:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingPermResult?(false)
                self.pendingPermResult = nil
            }

        case .unsupported:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingPermResult?(FlutterError(
                    code: "NO_BT",
                    message: "Bluetooth is not supported on this device",
                    details: nil
                ))
                self.pendingPermResult = nil
            }

        case .resetting:
            break

        case .unknown:
            break

        @unknown default:
            break
        }
    }

    /// Called for each peripheral found during `scanForPeripherals`.
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let rssiValue = RSSI.intValue

        // 127 is the sentinel for "RSSI not available" — skip such peripherals.
        guard rssiValue != 127 else { return }

        if let index = discoveredPeripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            
            // ប្រសិនបើពីមុនវាអត់ទាន់មានឈ្មោះ (nil) ប៉ុន្តែពេលនេះវាទើបតែរកឈ្មោះឃើញពីប្រព័ន្ធ
            // ឬមានឈ្មោះដេកចាំនៅក្នុងកញ្ចប់ Advertisement Data
            let existingPeripheral = discoveredPeripherals[index]
            if existingPeripheral.name == nil {
                let newName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
                if newName != nil {
                    discoveredPeripherals[index] = peripheral
                }
            }
        } else {
            discoveredPeripherals.append(peripheral)
        }

        // guard !discoveredPeripherals.contains(where: {
        //     $0.identifier == peripheral.identifier
        // }) else { return }

        // discoveredPeripherals.append(peripheral)
    }

    /// Called when the connection to a peripheral succeeds.
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    /// Called when the connection attempt fails.
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pendingConnectResult?(FlutterError(
                code: "CONNECT_FAILED",
                message: error?.localizedDescription ?? "Failed to connect",
                details: nil
            ))
            self.pendingConnectResult = nil
        }
        connectedPeripheral = nil
    }

    /// Called when the peripheral disconnects.
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        connectedPeripheral = nil
        writeCharacteristic = nil
        isWritingChunks = false
    }
}

// ===================================================================
// MARK: - CBPeripheralDelegate
// ===================================================================

extension BluetoothPrinterPlugin: CBPeripheralDelegate {

    /// Called after `discoverServices(nil)` completes.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingConnectResult?(FlutterError(
                    code: "CONNECT_FAILED", message: error.localizedDescription, details: nil
                ))
                self.pendingConnectResult = nil
            }
            return
        }

        guard let services = peripheral.services, !services.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingConnectResult?(FlutterError(
                    code: "CONNECT_FAILED", message: "No services discovered", details: nil
                ))
                self.pendingConnectResult = nil
            }
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    /// Called after `discoverCharacteristics(_:for:)` completes.
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingConnectResult?(FlutterError(
                    code: "CONNECT_FAILED", message: error.localizedDescription, details: nil
                ))
                self.pendingConnectResult = nil
            }
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where writeCharacteristic == nil {
            let isWritable =
                characteristic.properties.contains(.write) ||
                characteristic.properties.contains(.writeWithoutResponse)

            if isWritable {
                writeCharacteristic = characteristic
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.pendingConnectResult?(true)
                    self.pendingConnectResult = nil
                }
                return
            }
        }
    }

    /// Called after a `.withResponse` write completes.
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            isWritingChunks = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingPrintResult?(FlutterError(
                    code: "PRINT_ERROR", message: error.localizedDescription, details: nil
                ))
                self.pendingPrintResult = nil
            }
            return
        }

        guard isWritingChunks,
              let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else { return }

        writeNextChunk(peripheral: peripheral, characteristic: characteristic)
    }

    /// Called when a `.withoutResponse` peripheral is ready to accept more data.
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        guard isWritingChunks, let characteristic = writeCharacteristic else { return }
        writeNextChunk(peripheral: peripheral, characteristic: characteristic)
    }
}
