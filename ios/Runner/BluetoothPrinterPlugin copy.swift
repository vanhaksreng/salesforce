// import Flutter
// import UIKit
// import CoreBluetooth

// // MARK: - BluetoothPrinterPlugin

// /// A Flutter plugin that handles Bluetooth (BLE) printer communication.
// /// Mirrors the logic of the original Kotlin BluetoothPrinterPlugin using
// /// CoreBluetooth on iOS instead of Android's BluetoothAdapter/BluetoothSocket.
// final class BluetoothPrinterPlugin: NSObject, FlutterPlugin {

//     // ===================================================================
//     // MARK: - Constants  (mirrors Kotlin companion object)
//     // ===================================================================

//     static let channelName = "com.clearviewerp.pos_printer/bluetooth"

//     /// Classic-BT Serial Port Profile UUID kept for BLE service filtering.
//     private static let sppServiceUUID = CBUUID(string: "00001101-0000-1000-8000-00805F9B34FB")

//     // ESC/POS Commands
//     private static let ESC_INIT:     [UInt8] = [0x1B, 0x40]
//     private static let FEED_LINES:   [UInt8] = [0x1B, 0x64, 0x01]
//     private static let FULL_CUT:     [UInt8] = [0x1D, 0x56, 0x00]
//     private static let ALIGN_CENTER: [UInt8] = [0x1B, 0x61, 0x01]

//     // ===================================================================
//     // MARK: - Properties
//     // ===================================================================

//     /// Dedicated serial queue that mirrors Kotlin's single-thread executor.
//     /// Also used as the CBCentralManager delegate queue so every CB callback
//     /// arrives on this queue — never the main thread.
//     private let executor = DispatchQueue(
//         label: "com.clearviewerp.bluetooth.executor",
//         qos: .userInitiated
//     )

//     /// Initialised lazily after `executor` is ready; declared implicitly-
//     /// unwrapped so that it is always non-nil after `init()`.
//     private var centralManager: CBCentralManager!

//     /// The currently connected peripheral (mirrors `bluetoothSocket`).
//     private var connectedPeripheral: CBPeripheral?

//     /// The writable characteristic found after service/characteristic
//     /// discovery (mirrors `outputStream`).
//     private var writeCharacteristic: CBCharacteristic?

//     /// Peripherals seen during the current BLE scan.
//     private var discoveredPeripherals: [CBPeripheral] = []

//     // Pending Flutter results — stored so async CB callbacks can resolve them.
//     private var pendingPermResult:    FlutterResult?
//     private var pendingScanResult:    FlutterResult?
//     private var pendingConnectResult: FlutterResult?
//     private var pendingPrintResult:   FlutterResult?

//     // Chunked-write state (mirrors BufferedOutputStream behaviour).
//     private var pendingWriteData:   Data?
//     private var writeDataOffset:    Int  = 0
//     private var isWritingChunks:    Bool = false

//     // ===================================================================
//     // MARK: - FlutterPlugin Registration
//     // ===================================================================

//     static func register(with registrar: FlutterPluginRegistrar) {
//         let channel = FlutterMethodChannel(
//             name: channelName,
//             binaryMessenger: registrar.messenger()
//         )
//         let instance = BluetoothPrinterPlugin()
//         registrar.addMethodCallDelegate(instance, channel: channel)
//     }

//     // ===================================================================
//     // MARK: - Initialiser
//     // ===================================================================

//     override init() {
//         super.init()
//         // Initialising CBCentralManager with `queue: executor` means every
//         // delegate callback fires on `executor`, not the main thread.
//         centralManager = CBCentralManager(delegate: self, queue: executor)
//     }

//     // ===================================================================
//     // MARK: - FlutterPlugin Method Handler  (mirrors onMethodCall)
//     // ===================================================================

//     func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//         switch call.method {

//         case "requestPermissions":
//             handleRequestPermissions(result: result)

//         case "scanDevices":
//             handleScanDevices(result: result)

//         case "connect":
//             guard let args    = call.arguments as? [String: Any],
//                   let address = args["address"] as? String else {
//                 result(FlutterError(
//                     code: "NO_ADDRESS", message: "Address is required", details: nil
//                 ))
//                 return
//             }
//             handleConnect(address: address, result: result)

//         case "disconnect":
//             handleDisconnect(result: result)

//         case "printReceipt":
//             let args        = call.arguments as? [String: Any]
//             let text        = args?["text"]        as? String ?? ""
//             let printerName = args?["printerName"] as? String ?? ""
//             // `logoBytes` arrives from Flutter as FlutterStandardTypedData
//             let logoData    = (args?["logoBytes"] as? FlutterStandardTypedData)?.data
//             printKhmerReceipt(
//                 text: text, printerName: printerName,
//                 logoBytes: logoData, result: result
//             )

//         default:
//             result(FlutterMethodNotImplemented)
//         }
//     }

//     // ===================================================================
//     // MARK: - Permissions Logic  (mirrors handleRequestPermissions)
//     // ===================================================================

//     private func handleRequestPermissions(result: @escaping FlutterResult) {
//         if #available(iOS 13.1, *) {
//             let authorization = CBCentralManager.authorization
//             switch authorization {
//             case .allowedAlways:
//                 DispatchQueue.main.async { result(true) }

//             case .notDetermined:
//                 // Store the result; it will be resolved in
//                 // `centralManagerDidUpdateState(_:)` once the system
//                 // shows the permission dialog and the user responds.
//                 pendingPermResult = result

//             case .restricted, .denied:
//                 DispatchQueue.main.async { result(false) }

//             @unknown default:
//                 DispatchQueue.main.async { result(false) }
//             }
//         } else {
//             // iOS < 13.1: no explicit BT authorisation required.
//             DispatchQueue.main.async { result(true) }
//         }
//     }

//     // ===================================================================
//     // MARK: - Scan & Connect Logic
//     // ===================================================================

//     /// Returns a list of nearby BLE devices.
//     /// Mirrors `handleScanDevices`, replacing `adapter.bondedDevices`
//     /// with a 3-second active BLE scan.
//     private func handleScanDevices(result: @escaping FlutterResult) {
//         executor.async { [weak self] in
//             guard let self = self else { return }

//             guard self.centralManager.state == .poweredOn else {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "NO_BT",
//                         message: "Bluetooth not available or not powered on",
//                         details: nil
//                     ))
//                 }
//                 return
//             }

//             // Clear previous scan results and register the pending result.
//             self.discoveredPeripherals.removeAll()
//             self.pendingScanResult = result

//             // Start scanning (nil services = all peripherals, mirrors bondedDevices breadth).
//             self.centralManager.scanForPeripherals(
//                 withServices: nil,
//                 options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
//             )

//             // Stop after 3 seconds and return the collected list — mirrors
//             // the synchronous `bondedDevices` call by settling after a fixed window.
//             self.executor.asyncAfter(deadline: .now() + 3.0) { [weak self] in
//                 guard let self = self else { return }
//                 self.centralManager.stopScan()

//                 // Filter to include only peripherals with a valid, non-nil name
//                 let list: [[String: String]] = self.discoveredPeripherals
//                     .filter { $0.name != nil }
//                     .map { peripheral in
//                         let name    = peripheral.name! // Safe to unwrap due to filter
//                         let address = peripheral.identifier.uuidString
//                         return ["name": name, "address": address]
//                     }

//                 DispatchQueue.main.async { [weak self] in
//                     self?.pendingScanResult?(list)
//                     self?.pendingScanResult = nil
//                 }
//             }
// //            self.executor.asyncAfter(deadline: .now() + 3.0) { [weak self] in
// //                guard let self = self else { return }
// //                self.centralManager.stopScan()
// //
// //                let list: [[String: String]] = self.discoveredPeripherals.map { peripheral in
// //                    let name    = peripheral.name ?? "Unknown"
// //                    let address = peripheral.identifier.uuidString
// //                    return ["name": name, "address": address]
// //                }
// //
// //                DispatchQueue.main.async { [weak self] in
// //                    self?.pendingScanResult?(list)
// //                    self?.pendingScanResult = nil
// //                }
// //            }
//         }
//     }

//     /// Connects to the peripheral identified by `address` (its UUID string).
//     /// Mirrors `handleConnect(address:result:)`.
//     private func handleConnect(address: String, result: @escaping FlutterResult) {
//         guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
//             DispatchQueue.main.async {
//                 result(FlutterError(
//                     code: "NO_ADDRESS", message: "Address is required", details: nil
//                 ))
//             }
//             return
//         }

//         executor.async { [weak self] in
//             guard let self = self else { return }

//             // Tear down any existing connection — mirrors `closeConnection()` call.
//             self.closeConnection()

//             guard self.centralManager.state == .poweredOn else {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "CONNECT_FAILED",
//                         message: "Bluetooth adapter unavailable",
//                         details: nil
//                     ))
//                 }
//                 return
//             }

//             // Resolve UUID — mirrors `adapter.getRemoteDevice(address)`.
//             guard let uuid = UUID(uuidString: address) else {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "CONNECT_FAILED",
//                         message: "Invalid device identifier format",
//                         details: nil
//                     ))
//                 }
//                 return
//             }

//             // Look up the peripheral: first try the system cache (equivalent
//             // to `getRemoteDevice`), then fall back to scan results.
//             let knownPeripherals = self.centralManager.retrievePeripherals(
//                 withIdentifiers: [uuid]
//             )

//             if let peripheral = knownPeripherals.first {
//                 self.connectedPeripheral = peripheral
//                 peripheral.delegate = self
//                 self.pendingConnectResult = result
//                 self.centralManager.connect(peripheral, options: nil)
//             } else if let peripheral = self.discoveredPeripherals.first(
//                 where: { $0.identifier.uuidString == address }
//             ) {
//                 self.connectedPeripheral = peripheral
//                 peripheral.delegate = self
//                 self.pendingConnectResult = result
//                 self.centralManager.connect(peripheral, options: nil)
//             } else {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "CONNECT_FAILED",
//                         message: "Device not found. Please scan first.",
//                         details: nil
//                     ))
//                 }
//             }
//         }
//     }

//     /// Mirrors `handleDisconnect(result:)`.
//     private func handleDisconnect(result: @escaping FlutterResult) {
//         executor.async { [weak self] in
//             guard let self = self else { return }
//             self.closeConnection()
//             DispatchQueue.main.async { result(nil) }
//         }
//     }

//     /// Tears down the active connection.
//     /// Mirrors `closeConnection()`.
//     private func closeConnection() {
//         if let peripheral = connectedPeripheral {
//             centralManager.cancelPeripheralConnection(peripheral)
//         }
//         connectedPeripheral  = nil
//         writeCharacteristic  = nil
//         pendingWriteData     = nil
//         isWritingChunks      = false
//         writeDataOffset      = 0
//     }

//     // ===================================================================
//     // MARK: - Print Logic  (mirrors printKhmerReceipt)
//     // ===================================================================

//     private func printKhmerReceipt(
//         text:        String,
//         printerName: String,
//         logoBytes:   Data?,
//         result:      @escaping FlutterResult
//     ) {
//         executor.async { [weak self] in
//             guard let self = self else { return }

//             guard let characteristic = self.writeCharacteristic,
//                   let peripheral     = self.connectedPeripheral else {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "PRINT_ERROR", message: "Printer not connected", details: nil
//                     ))
//                 }
//                 return
//             }

//             do {
//                 var data = Data()
//                 data.append(contentsOf: BluetoothPrinterPlugin.ESC_INIT)
//                 data.append(contentsOf: BluetoothPrinterPlugin.ALIGN_CENTER)

//                 let bitmap    = try self.createKhmerBitmap(text: text, logoBytes: logoBytes)
//                 let imageData = self.imageDataForPrinter(bitmap: bitmap)
//                 data.append(imageData)

//                 data.append(contentsOf: BluetoothPrinterPlugin.FEED_LINES)
//                 data.append(contentsOf: BluetoothPrinterPlugin.FULL_CUT)

//                 // Kick off chunked write — mirrors `stream.flush()`.
//                 self.pendingPrintResult = result
//                 self.pendingWriteData   = data
//                 self.writeDataOffset    = 0
//                 self.isWritingChunks    = true
//                 self.writeNextChunk(peripheral: peripheral, characteristic: characteristic)

//             } catch {
//                 DispatchQueue.main.async {
//                     result(FlutterError(
//                         code: "PRINT_ERROR",
//                         message: error.localizedDescription,
//                         details: nil
//                     ))
//                 }
//             }
//         }
//     }

//     // ===================================================================
//     // MARK: - Chunked BLE Write  (mirrors BufferedOutputStream writes)
//     // ===================================================================

//     /// Writes `data` to `characteristic` in 512-byte chunks, sequencing
//     /// each chunk only after the previous one is acknowledged.
//     private func writeNextChunk(
//         peripheral:     CBPeripheral,
//         characteristic: CBCharacteristic
//     ) {
//         guard isWritingChunks, let data = pendingWriteData else { return }

//         let remaining = data.count - writeDataOffset
//         guard remaining > 0 else {
//             // All bytes sent — equivalent to stream.flush() completing.
//             isWritingChunks  = false
//             pendingWriteData = nil
//             DispatchQueue.main.async { [weak self] in
//                 self?.pendingPrintResult?("Printed successfully")
//                 self?.pendingPrintResult = nil
//             }
//             return
//         }

//         // 512 bytes is a safe BLE MTU chunk that avoids fragmentation.
//         let chunkSize = 512
//         let size      = min(chunkSize, remaining)
//         let chunk     = data.subdata(in: writeDataOffset ..< writeDataOffset + size)
//         writeDataOffset += size

//         // Prefer `.withResponse` for reliability; fall back to `.withoutResponse`.
//         let writeType: CBCharacteristicWriteType =
//             characteristic.properties.contains(.write)
//             ? .withResponse
//             : .withoutResponse

//         peripheral.writeValue(chunk, for: characteristic, type: writeType)

//         // For `.withoutResponse`, the delegate `peripheralIsReady` callback
//         // drives the next chunk (see CBPeripheralDelegate section below).
//         // For `.withResponse`, `didWriteValueFor` drives the next chunk.
//     }

//     // ===================================================================
//     // MARK: - Bitmap Creation  (mirrors createKhmerBitmap)
//     // ===================================================================

//     private func createKhmerBitmap(text: String, logoBytes: Data?) throws -> UIImage {

//         let printerWidth  = 576  // 80mm
//         let padding       = 20
//         let maxTextWidth  = printerWidth - (padding * 2)
//         let textFontSize = 23.0

//         // Load custom font — mirrors Typeface.createFromAsset; falls back to
//         // system font if the asset is missing (mirrors Typeface.DEFAULT).
//         let typefaceRegular: UIFont =
//             UIFont(name: "NotoSansKhmer-Regular", size: textFontSize)
//             ?? UIFont.systemFont(ofSize: textFontSize)

//         let boldDescriptor = typefaceRegular.fontDescriptor.withSymbolicTraits(.traitBold)
//             ?? typefaceRegular.fontDescriptor
//         let typefaceBold = UIFont(descriptor: boldDescriptor, size: textFontSize)

//         let lines = text.components(separatedBy: "\n")

//         // Mirrors: mutableListOf<Triple<StaticLayout, Int, Int>>
//         // Stores (attributed string, x, y, width) for each text block.
//         typealias LayoutEntry = (text: NSAttributedString, x: Int, y: Int, width: Int)
//         var layoutsWithPositions: [LayoutEntry] = []
//         var horizontalLinesY: [Int] = []

//         // Initial top margin — mirrors `var totalHeight = 10`.
//         var totalHeight = 10
//         var logoBitmap: UIImage?

//         // ── Logo processing ────────────────────────────────────────────
//         // Mirrors the logoBytes != null block in the original.
//         if let logoBytes = logoBytes, !logoBytes.isEmpty {
//             if let rawBitmap = UIImage(data: logoBytes) {
//                 let desiredWidth: CGFloat = 170
//                 let aspectRatio = rawBitmap.size.height / rawBitmap.size.width
//                 let desiredHeight = desiredWidth * aspectRatio

//                 let logoFormat = UIGraphicsImageRendererFormat()
//                 logoFormat.scale = 1.0   // 1 pt = 1 px — prevents Retina 2x/3x inflation
//                 let renderer = UIGraphicsImageRenderer(
//                     size: CGSize(width: desiredWidth, height: desiredHeight),
//                     format: logoFormat
//                 )
//                 logoBitmap = renderer.image { _ in
//                     rawBitmap.draw(in: CGRect(
//                         x: 0, y: 0, width: desiredWidth, height: desiredHeight
//                     ))
//                 }
//                 // Mirrors: totalHeight += desiredHeight + 5
//                 totalHeight += Int(desiredHeight) + 5
//             }
//         }

//         // Column layout config — mirrors colWidths / colPositions arrays.
//         let colWidths:    [Int] = [36, 160, 65, 100, 75, 100]
//         let colPositions: [Int] = [ 0,  36, 196, 261, 361, 436]

//         // ── Line processing loop ───────────────────────────────────────
//         for line in lines {
//             var cleanLine = line
//             var isBold    = false
//             var isTable   = false

//             if cleanLine.contains("[TABLE]") {
//                 isTable   = true
//                 cleanLine = cleanLine.replacingOccurrences(of: "[TABLE]", with: "")
//             }

//             if cleanLine.contains("<b>") && cleanLine.contains("</b>") {
//                 isBold    = true
//                 cleanLine = cleanLine
//                     .replacingOccurrences(of: "<b>",  with: "")
//                     .replacingOccurrences(of: "</b>", with: "")
//             }

//             // Horizontal rule — mirrors the [LINE] tag logic.
//             if cleanLine.contains("[LINE]") {
//                 horizontalLinesY.append(totalHeight)
//                 totalHeight += 5
//                 continue
//             }

//             let currentFont = isBold ? typefaceBold : typefaceRegular

//             if isTable {
//                 // ── Table row ──────────────────────────────────────────
//                 // Mirrors the column-splitting logic including the
//                 // item-name overflow merge.
//                 let rawParts = cleanLine.components(separatedBy: ",")
//                 let columns: [String] = {
//                     if rawParts.count <= colWidths.count {
//                         return rawParts
//                     }
//                     let overflowCount   = rawParts.count - colWidths.count
//                     let mergedItemName  = rawParts[1 ..< (2 + overflowCount)].joined(separator: ",")
//                     var result          = [rawParts[0], mergedItemName]
//                     result.append(contentsOf: rawParts[(2 + overflowCount)...])
//                     return result
//                 }()

//                 var maxHeightInRow = 0

//                 for (i, _) in columns.enumerated() {
//                     guard i < colWidths.count else { break }  // Prevent out of bounds
//                     let cellText = columns[i].trimmingCharacters(in: .whitespaces)

//                     // Column alignment — mirrors the when{} block in the Kotlin.
//                     let textAlignment: NSTextAlignment = {
//                         if i <= 1 {
//                             return .left  // ALIGN_NORMAL for columns 0 and 1
//                         }
//                         let isHeaderRow =
//                             line.range(of: "Qty|Price|Total|ចំនួន|តម្លៃ|ចុះតម្លៃ|សរុប",
//                                        options: .regularExpression) != nil
//                         return isHeaderRow ? .right : .center  // ALIGN_OPPOSITE or ALIGN_CENTER
//                     }()

//                     let attrStr = makeAttributedString(
//                         text:      cellText,
//                         font:      currentFont,
//                         alignment: textAlignment
//                     )

//                     let boundedRect = attrStr.boundingRect(
//                         with: CGSize(width: CGFloat(colWidths[i]), height: .greatestFiniteMagnitude),
//                         options: [.usesLineFragmentOrigin, .usesFontLeading],
//                         context: nil
//                     )
//                     let cellHeight = Int(ceil(boundedRect.height))
//                     if cellHeight > maxHeightInRow { maxHeightInRow = cellHeight }

//                     layoutsWithPositions.append((
//                         text:  attrStr,
//                         x:     colPositions[i] + padding,
//                         y:     totalHeight,
//                         width: colWidths[i]
//                     ))
//                 }
//                 // Mirrors: totalHeight += maxHeightInRow + 5
//                 totalHeight += maxHeightInRow + 5

//             } else {
//                 // ── Regular text block ─────────────────────────────────
//                 // Mirrors the ALIGN_NORMAL / CENTER / OPPOSITE path.
//                 var alignment: NSTextAlignment = .left  // ALIGN_NORMAL

//                 if cleanLine.contains("[C]") {
//                     alignment = .center
//                     cleanLine = cleanLine.replacingOccurrences(of: "[C]", with: "")
//                 } else if cleanLine.contains("[R]") {
//                     alignment = .right
//                     cleanLine = cleanLine.replacingOccurrences(of: "[R]", with: "")
//                 }

//                 let attrStr = makeAttributedString(
//                     text:      cleanLine,
//                     font:      currentFont,
//                     alignment: alignment
//                 )

//                 let boundedRect = attrStr.boundingRect(
//                     with: CGSize(width: CGFloat(maxTextWidth), height: .greatestFiniteMagnitude),
//                     options: [.usesLineFragmentOrigin, .usesFontLeading],
//                     context: nil
//                 )
//                 let textHeight = Int(ceil(boundedRect.height))

//                 layoutsWithPositions.append((
//                     text:  attrStr,
//                     x:     padding,
//                     y:     totalHeight,
//                     width: maxTextWidth
//                 ))
//                 totalHeight += textHeight
//             }
//         }

//         // ── Render into a Bitmap ───────────────────────────────────────
//         // Mirrors: Bitmap.createBitmap + Canvas(bitmap) + canvas.drawColor(WHITE)
//         let imageSize = CGSize(width: printerWidth, height: totalHeight + 15)
//         // scale = 1.0 forces 1 pt = 1 px so the bitmap sent to the printer
//         // is exactly `printerWidth` pixels wide, not 2x or 3x on Retina devices.
//         let bitmapFormat = UIGraphicsImageRendererFormat()
//         bitmapFormat.scale = 1.0
//         let renderer = UIGraphicsImageRenderer(size: imageSize, format: bitmapFormat)

//         let resultImage = renderer.image { ctx in
//             let cgCtx = ctx.cgContext

//             // White background
//             UIColor.white.setFill()
//             cgCtx.fill(CGRect(origin: .zero, size: imageSize))

//             // Draw logo centred at the top — mirrors `canvas.drawBitmap(logoBitmap, logoX, logoY, null)`.
//             if let logo = logoBitmap {
//                 let logoX = (CGFloat(printerWidth) - logo.size.width) / 2.0
//                 let logoY: CGFloat = 10
//                 logo.draw(at: CGPoint(x: logoX, y: logoY))
//             }

//             // Draw horizontal rule lines — mirrors canvas.drawLine for [LINE] tags.
//             cgCtx.setStrokeColor(UIColor.black.cgColor)
//             cgCtx.setLineWidth(2)
//             for lineY in horizontalLinesY {
//                 cgCtx.move(to: CGPoint(x: padding, y: lineY))
//                 cgCtx.addLine(to: CGPoint(x: printerWidth - padding, y: lineY))
//                 cgCtx.strokePath()
//             }

//             // Draw all text layouts — mirrors `layout.draw(canvas)` loop.
//             // UIGraphicsPushContext binds the renderer's CGContext as the current
//             // UIKit graphics context so NSAttributedString glyph runs (including
//             // Khmer combining marks) attach correctly to their base characters.
//             UIGraphicsPushContext(cgCtx)
//             for entry in layoutsWithPositions {
//                 let drawRect = CGRect(
//                     x:      entry.x,
//                     y:      entry.y + 5,       // +5 mirrors `yPos = item.third.toFloat() + 5f`
//                     width:  entry.width,
//                     height: Int(imageSize.height)
//                 )
//                 entry.text.draw(
//                     with:    drawRect,
//                     options: [.usesLineFragmentOrigin, .usesFontLeading],
//                     context: nil
//                 )
//             }
//             UIGraphicsPopContext()
//         }

//         return resultImage
//     }

//     /// Builds an `NSAttributedString` with the requested font, colour, and
//     /// paragraph alignment — equivalent to constructing a `TextPaint` and a
//     /// `StaticLayout.Builder` in the Kotlin source.
//     private func makeAttributedString(
//         text:      String,
//         font:      UIFont,
//         alignment: NSTextAlignment
//     ) -> NSAttributedString {
//         let paragraphStyle          = NSMutableParagraphStyle()
//         paragraphStyle.alignment    = alignment
//         // `.lineSpacing(0f, 1.2f)` in Kotlin sets a multiplier of 1.2.
//         // lineSpacing in NSParagraphStyle is an additive delta; we approximate
//         // 1.2× by adding 20% of the line height.
//         paragraphStyle.lineSpacing  = font.lineHeight * 0.2

//         let attributes: [NSAttributedString.Key: Any] = [
//             .font:            font,
//             .paragraphStyle:  paragraphStyle,
//             .foregroundColor: UIColor.black
//         ]
//         return NSAttributedString(string: text, attributes: attributes)
//     }

//     // ===================================================================
//     // MARK: - ESC/POS Raster Image Encoding  (mirrors sendImageToPrinter)
//     // ===================================================================

//     /// Converts a `UIImage` to ESC/POS raster data and returns it as `Data`.
//     /// Pixel-level logic is a direct port of the Kotlin `sendImageToPrinter`.
//     private func imageDataForPrinter(bitmap: UIImage) -> Data {
//         guard let cgImage = bitmap.cgImage else { return Data() }
        
//         let width = cgImage.width
//         let height = cgImage.height
        
//         // Create a properly oriented bitmap context using UIKit drawing
//         let bytesPerPixel = 4
//         let bytesPerRow = width * bytesPerPixel
//         var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
//         let colorSpace = CGColorSpaceCreateDeviceRGB()
//         guard let context = CGContext(
//             data: &pixelData,
//             width: width,
//             height: height,
//             bitsPerComponent: 8,
//             bytesPerRow: bytesPerRow,
//             space: colorSpace,
//             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//         ) else { return Data() }
        
//         // === Key fix starts here ===
//         UIGraphicsPushContext(context)
        
//         // Flip the context so UIKit's top-left origin maps to CG's bottom-left
//         context.translateBy(x: 0, y: CGFloat(height))
//         context.scaleBy(x: 1, y: -1)
        
//         // Draw the UIImage directly (respects .orientation metadata)
//         bitmap.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
//         UIGraphicsPopContext()
//         // === Key fix ends here ===
        
//         var data = Data()
        
//         // Set line spacing to 24 dots
//         data.append(contentsOf: [0x1B, 0x33, 24])
        
//         var y = 0
//         while y < height {
//             var command: [UInt8] = [
//                 0x1B, 0x2A,          // ESC *
//                 33,                  // 24-dot double density mode
//                 UInt8(width % 256),
//                 UInt8(width / 256)
//             ]
            
//             for x in 0..<width {
//                 for k in 0..<3 {                // 3 bytes = 24 vertical dots
//                     var byteData: UInt8 = 0
//                     for b in 0..<8 {
//                         let pixelY = y + (k * 8) + b
//                         if pixelY < height {
//                             let index = pixelY * bytesPerRow + x * bytesPerPixel
//                             let red = pixelData[index]          // R in RGBA
                            
//                             if red < 128 {                      // threshold
//                                 byteData |= (1 << (7 - b))
//                             }
//                         }
//                     }
//                     command.append(byteData)
//                 }
//             }
            
//             data.append(contentsOf: command)
//             data.append(0x0A)        // Line feed
            
//             y += 24
//         }
        
//         // Restore default line spacing
//         data.append(contentsOf: [0x1B, 0x32])
        
//         return data
//     }

//     // private func imageDataForPrinter(bitmap: UIImage) -> Data {
//     //     guard let cgImage = bitmap.cgImage else { return Data() }

//     //     let width        = cgImage.width
//     //     let height       = cgImage.height
//     //     let bytesPerPixel = 4
//     //     let bytesPerRow  = width * bytesPerPixel
//     //     var pixelData    = [UInt8](repeating: 0, count: height * bytesPerRow)

//     //     let colorSpace = CGColorSpaceCreateDeviceRGB()
//     //     guard let context = CGContext(
//     //         data:             &pixelData,
//     //         width:            width,
//     //         height:           height,
//     //         bitsPerComponent: 8,
//     //         bytesPerRow:      bytesPerRow,
//     //         space:            colorSpace,
//     //         bitmapInfo:       CGImageAlphaInfo.premultipliedLast.rawValue
//     //     ) else { return Data() }

//     //     // CGContext origin is bottom-left; UIImage origin is top-left.
//     //     // Without this flip, every stripe is read bottom-first, printing the
//     //     // receipt upside-down. Translate + scale mirrors the image vertically
//     //     // so pixel row 0 in the buffer corresponds to the visual top of the image.
//     //     context.translateBy(x: 0, y: CGFloat(height))
//     //     context.scaleBy(x: 1, y: -1)
//     //     context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

//     //     var data = Data()

//     //     // Set line spacing to exactly 24 dots (ESC 3 24 = 0x1B 0x33 0x18).
//     //     // Mirrors: stream.write(byteArrayOf(0x1B, 0x33, 24))
//     //     data.append(contentsOf: [UInt8(0x1B), UInt8(0x33), UInt8(24)])

//     //     var y = 0
//     //     while y < height {
//     //         // 24-dot double-density ESC * header — mirrors the command mutableListOf.
//     //         var command: [UInt8] = [
//     //             0x1B, 0x2A,
//     //             33,                          // 24-dot double-density mode
//     //             UInt8(width % 256),
//     //             UInt8(width / 256)
//     //         ]

//     //         for x in 0 ..< width {
//     //             // 3 bytes × 8 bits = 24 vertical dots — mirrors `for (k in 0 until 3)`.
//     //             for k in 0 ..< 3 {
//     //                 var byteData: UInt8 = 0
//     //                 for b in 0 ..< 8 {
//     //                     let pixelY = y + (k * 8) + b
//     //                     if pixelY < height {
//     //                         let pixelIndex = pixelY * bytesPerRow + x * bytesPerPixel
//     //                         let red = pixelData[pixelIndex]
//     //                         // Mirrors: if (Color.red(pixel) < 128)
//     //                         if red < 128 {
//     //                             byteData |= (1 << (7 - b))
//     //                         }
//     //                     }
//     //                 }
//     //                 command.append(byteData)
//     //             }
//     //         }

//     //         data.append(contentsOf: command)
//     //         data.append(UInt8(0x0A)) // LF — advances exactly 24 dots

//     //         y += 24
//     //     }

//     //     // Restore default line spacing (ESC 2) — mirrors stream.write(byteArrayOf(0x1B, 0x32)).
//     //     data.append(contentsOf: [UInt8(0x1B), UInt8(0x32)])

//     //     return data
//     // }

//     // ===================================================================
//     // MARK: - Dispose  (mirrors dispose())
//     // ===================================================================

//     func dispose() {
//         closeConnection()
//         centralManager.stopScan()
//     }
// }

// // ===================================================================
// // MARK: - CBCentralManagerDelegate
// // ===================================================================

// extension BluetoothPrinterPlugin: CBCentralManagerDelegate {

//     /// Required delegate method — called whenever the Bluetooth radio state changes.
//     /// Mirrors the implicit Bluetooth state handling in the Kotlin adapter checks.
//     func centralManagerDidUpdateState(_ central: CBCentralManager) {
//         switch central.state {

//         case .poweredOn:
//             // Radio is ready — resolve any pending permission request.
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingPermResult?(true)
//                 self.pendingPermResult = nil
//             }

//         case .poweredOff:
//             // Mirrors adapter == null / disabled checks.
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 let error = FlutterError(
//                     code: "BT_OFF", message: "Bluetooth is powered off", details: nil
//                 )
//                 self.pendingScanResult?(error)
//                 self.pendingScanResult = nil
//                 self.pendingConnectResult?(error)
//                 self.pendingConnectResult = nil
//             }

//         case .unauthorized:
//             // User denied Bluetooth access — mirrors permission denial on Android.
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingPermResult?(false)
//                 self.pendingPermResult = nil
//             }

//         case .unsupported:
//             // Device has no Bluetooth hardware — mirrors `bluetoothAdapter == null`.
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingPermResult?(FlutterError(
//                     code: "NO_BT",
//                     message: "Bluetooth is not supported on this device",
//                     details: nil
//                 ))
//                 self.pendingPermResult = nil
//             }

//         case .resetting:
//             // Transient state; wait for the next update.
//             break

//         case .unknown:
//             // Initial state; wait for the next update.
//             break

//         @unknown default:
//             break
//         }
//     }

//     /// Called for each peripheral found during `scanForPeripherals`.
//     /// Mirrors the BroadcastReceiver that populates the bonded device list.
//     func centralManager(
//         _ central:           CBCentralManager,
//         didDiscover          peripheral: CBPeripheral,
//         advertisementData:   [String: Any],
//         rssi RSSI:           NSNumber
//     ) {
//         // Safely unwrap RSSI — mirrors the device.name ?: "Unknown" null check.
//         let rssiValue = RSSI.intValue

//         // 127 is the sentinel for "RSSI not available" — skip such peripherals.
//         guard rssiValue != 127 else { return }

//         // Deduplicate — mirrors the Set<BluetoothDevice> semantics of bondedDevices.
//         guard !discoveredPeripherals.contains(where: {
//             $0.identifier == peripheral.identifier
//         }) else { return }

//         discoveredPeripherals.append(peripheral)
//     }

//     /// Called when the connection to a peripheral succeeds.
//     /// Mirrors the point after `socket.connect()` completes on the executor.
//     func centralManager(
//         _ central:  CBCentralManager,
//         didConnect  peripheral: CBPeripheral
//     ) {
//         connectedPeripheral  = peripheral
//         peripheral.delegate  = self
//         // Discover all services to locate the writable characteristic —
//         // mirrors `socket.outputStream` becoming available after connect.
//         peripheral.discoverServices(nil)
//     }

//     /// Called when the connection attempt fails.
//     /// Mirrors the `catch (e: Exception)` block in `handleConnect`.
//     func centralManager(
//         _ central:          CBCentralManager,
//         didFailToConnect    peripheral: CBPeripheral,
//         error:              Error?
//     ) {
//         DispatchQueue.main.async { [weak self] in
//             guard let self = self else { return }
//             self.pendingConnectResult?(FlutterError(
//                 code:    "CONNECT_FAILED",
//                 message: error?.localizedDescription ?? "Failed to connect",
//                 details: nil
//             ))
//             self.pendingConnectResult = nil
//         }
//         connectedPeripheral = nil
//     }

//     /// Called when the peripheral disconnects.
//     /// Mirrors the IOException path that closes the socket.
//     func centralManager(
//         _ central:              CBCentralManager,
//         didDisconnectPeripheral peripheral: CBPeripheral,
//         error:                  Error?
//     ) {
//         connectedPeripheral = nil
//         writeCharacteristic = nil
//         isWritingChunks     = false
//     }
// }

// // ===================================================================
// // MARK: - CBPeripheralDelegate
// // ===================================================================

// extension BluetoothPrinterPlugin: CBPeripheralDelegate {

//     /// Called after `discoverServices(nil)` completes.
//     /// Mirrors the step between `socket.connect()` and the stream being
//     /// available — here we dig deeper to find the writable characteristic.
//     func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//         if let error = error {
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingConnectResult?(FlutterError(
//                     code: "CONNECT_FAILED", message: error.localizedDescription, details: nil
//                 ))
//                 self.pendingConnectResult = nil
//             }
//             return
//         }

//         guard let services = peripheral.services, !services.isEmpty else {
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingConnectResult?(FlutterError(
//                     code: "CONNECT_FAILED", message: "No services discovered", details: nil
//                 ))
//                 self.pendingConnectResult = nil
//             }
//             return
//         }

//         for service in services {
//             peripheral.discoverCharacteristics(nil, for: service)
//         }
//     }

//     /// Called after `discoverCharacteristics(_:for:)` completes.
//     /// Finds the first writable characteristic — the equivalent of obtaining
//     /// `socket.outputStream` in the Kotlin code.
//     func peripheral(
//         _ peripheral:   CBPeripheral,
//         didDiscoverCharacteristicsFor service: CBService,
//         error:          Error?
//     ) {
//         if let error = error {
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingConnectResult?(FlutterError(
//                     code: "CONNECT_FAILED", message: error.localizedDescription, details: nil
//                 ))
//                 self.pendingConnectResult = nil
//             }
//             return
//         }

//         guard let characteristics = service.characteristics else { return }

//         // Only accept the first writable characteristic found; once
//         // `pendingConnectResult` is resolved we nil it to prevent double-invoke.
//         for characteristic in characteristics where writeCharacteristic == nil {
//             let isWritable =
//                 characteristic.properties.contains(.write) ||
//                 characteristic.properties.contains(.writeWithoutResponse)

//             if isWritable {
//                 writeCharacteristic = characteristic
//                 DispatchQueue.main.async { [weak self] in
//                     guard let self = self else { return }
//                     self.pendingConnectResult?(true)
//                     self.pendingConnectResult = nil
//                 }
//                 return
//             }
//         }
//     }

//     /// Called after a `.withResponse` write completes.
//     /// Drives the next chunk — mirrors the sequential `stream.write()` calls
//     /// that BufferedOutputStream serialises internally.
//     func peripheral(
//         _ peripheral:       CBPeripheral,
//         didWriteValueFor    characteristic: CBCharacteristic,
//         error:              Error?
//     ) {
//         if let error = error {
//             isWritingChunks = false
//             DispatchQueue.main.async { [weak self] in
//                 guard let self = self else { return }
//                 self.pendingPrintResult?(FlutterError(
//                     code: "PRINT_ERROR", message: error.localizedDescription, details: nil
//                 ))
//                 self.pendingPrintResult = nil
//             }
//             return
//         }

//         guard isWritingChunks,
//               let peripheral     = connectedPeripheral,
//               let characteristic = writeCharacteristic else { return }

//         writeNextChunk(peripheral: peripheral, characteristic: characteristic)
//     }

//     /// Called when a `.withoutResponse` peripheral is ready to accept more data.
//     /// This is the correct iOS flow-control mechanism for `writeWithoutResponse`
//     /// characteristics — prevents buffer overflow on high-throughput writes.
//     func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//         guard isWritingChunks, let characteristic = writeCharacteristic else { return }
//         writeNextChunk(peripheral: peripheral, characteristic: characteristic)
//     }
// }
