//
////
//// ESCPOSGenerator.swift
////
//import UIKit
//
//class ESCPOSGenerator {
//
//// MARK: - Character Detection
//static func containsNonASCIICharacters(_ text: String) -> Bool {
//return !text.allSatisfy({ $0.isASCII })
//}
//
//// MARK: - Control Commands
//static func reset() -> Data {
//return Data([0x1B, 0x40]) // ESC @
//}
//
//static func cut() -> Data {
//return Data([0x1D, 0x56, 0x00]) // GS V 0 (Full cut)
//}
//
//static func feedLines(_ lines: Int = 3) -> Data {
//return Data([0x1B, 0x64, UInt8(lines)]) // ESC d n
//}
//
//// MARK: - DYNAMIC TEXT RENDERING (Primary Entry Point)
//static func generatePrintData(
//_ text: String,
//style: TextStyle,
//width: Int = 384
//) -> Data {
//if text.isEmpty {
//return Data([0x0A]) // Just a newline
//}
//
//if containsNonASCIICharacters(text) {
//print("🚨 Non-ASCII text detected. Using image rendering.")
//return renderTextAsImage(text, style: style, width: width)
//} else {
//print("✅ Pure ASCII text detected. Using raw ESC/POS commands.")
//return printEnglishText(text, style: style)
//}
//}
//
//// MARK: - 1. Image-Based Text Rendering (For Non-ASCII/Khmer)
//static func renderTextAsImage(
//_ text: String,
//style: TextStyle,
//width: Int = 384
//) -> Data {
//if text.isEmpty { return Data([0x0A]) }
//
//// This relies on the fixed KhmerTextRenderer (not shown here, but assumed fixed)
//if let renderedData = KhmerTextRenderer.renderTextSync(
//text,
//width: CGFloat(width),
//style: style,
//maxLines: 0
//) {
//if let image = UIImage(data: renderedData.data) {
//guard image.size.width > 0 && image.size.height > 0 else { return Data([0x0A]) }
//
//// Add padding to prevent clipping
//let paddedImage = addVerticalPadding(to: image, padding: 10)
//
//let imageData = imageRaster(paddedImage, width: width)
//
//// Basic validation (Checks for the image header 0x1D 0x76 0x30 0x00)
//guard imageData.count > 8 else { return Data([0x0A]) }
//
//if imageData.count >= 4 &&
//imageData[0] == 0x1D &&
//imageData[1] == 0x76 &&
//imageData[2] == 0x30 &&
//imageData[3] == 0x00 {
//return imageData
//}
//}
//}
//
//print("⚠️ Image rendering failed, returning empty line.")
//return Data([0x0A])
//}
//
//// MARK: - 2. Raw Command Text Printing (For Pure ASCII/English)
//static func printEnglishText(_ text: String, style: TextStyle) -> Data {
//guard text.allSatisfy({ $0.isASCII }) else {
//return renderTextAsImage(text, style: style)
//}
//
//var data = Data()
//
//// 1. CRITICAL: Set Code Page 437/USA (Initial)
//data.append(Data([0x1B, 0x52, 0x01])) // ESC R 1 (Select USA International)
//data.append(Data([0x1B, 0x74, 0x00])) // ESC t 0 (Select Code Page 437)
//
//// 2. Set alignment
//switch style.alignment {
//case .left:
//data.append(Data([0x1B, 0x61, 0x00]))
//case .center:
//data.append(Data([0x1B, 0x61, 0x01]))
//case .right:
//data.append(Data([0x1B, 0x61, 0x02]))
//case .justified:
//data.append(Data([0x1B, 0x61, 0x00]))
//}
//
//// 3. Set bold and font size (using existing logic)
//if style.isBold { data.append(Data([0x1B, 0x45, 0x01])) }
//var sizeValue: UInt8 = 0x00
//if style.fontSize > 28 { sizeValue = 0x11 }
//else if style.fontSize > 22 { sizeValue = 0x10 }
//if sizeValue != 0x00 { data.append(Data([0x1D, 0x21, sizeValue])) }
//
//// 4. Add ASCII text
//if let textData = text.data(using: .ascii) { data.append(textData) }
//data.append(Data([0x0A])) // Line feed
//
//// 5. Reset formatting
//data.append(Data([0x1B, 0x45, 0x00])) // Bold off
//data.append(Data([0x1D, 0x21, 0x00])) // Size normal
//data.append(Data([0x1B, 0x61, 0x00])) // Left align
//
//// 💥 6. CRITICAL FIX: Re-select the safe code page 437/USA (Final)
//// This ensures the printer is in a safe, known state for the next line,
//// preventing corruption of the Khmer image data.
//data.append(Data([0x1B, 0x52, 0x01])) // ESC R 1 (Select USA International)
//data.append(Data([0x1B, 0x74, 0x00])) // ESC t 0 (Select Code Page 437)
//
//return data
//}
//
//// MARK: - Image Helper Functions
//
//private static func addVerticalPadding(to image: UIImage, padding: CGFloat) -> UIImage {
//let newSize = CGSize(width: image.size.width, height: image.size.height + (padding * 2))
//let format = UIGraphicsImageRendererFormat()
//format.opaque = false
//format.scale = image.scale
//
//let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
//return renderer.image { context in
//UIColor.white.setFill()
//context.fill(CGRect(origin: .zero, size: newSize))
//image.draw(at: CGPoint(x: 0, y: padding))
//}
//}
//
//static func imageRaster(_ image: UIImage, width: Int = 384) -> Data {
//guard let resizedImage = resizeImage(image, targetWidth: width),
//let cgImage = resizedImage.cgImage else {
//return Data()
//}
//
//let imageWidth = cgImage.width
//let imageHeight = cgImage.height
//let widthBytes = (imageWidth + 7) / 8
//
//var bitmap = [UInt8](repeating: 0, count: widthBytes * imageHeight)
//
//guard let context = CGContext(
//data: nil,
//width: imageWidth,
//height: imageHeight,
//bitsPerComponent: 8,
//bytesPerRow: imageWidth,
//space: CGColorSpaceCreateDeviceGray(),
//bitmapInfo: CGImageAlphaInfo.none.rawValue
//) else {
//return Data()
//}
//
//context.interpolationQuality = .high
//context.setShouldAntialias(true)
//context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
//
//guard let pixelData = context.data else { return Data() }
//let pixels = pixelData.bindMemory(to: UInt8.self, capacity: imageWidth * imageHeight)
//
//let threshold: UInt8 = 128
//for y in 0..<imageHeight {
//let rowOffset = y * widthBytes
//let pixelRowOffset = y * imageWidth
//
//for byteX in 0..<widthBytes {
//var byte: UInt8 = 0
//let startX = byteX * 8
//
//for bit in 0..<8 {
//let x = startX + bit
//if x < imageWidth {
//// Invert color (Black text is '1' bit)
//if pixels[pixelRowOffset + x] < threshold {
//byte |= (1 << (7 - bit))
//}
//}
//}
//bitmap[rowOffset + byteX] = byte
//}
//}
//
//var data = Data()
//data.reserveCapacity(8 + bitmap.count)
//
//// GS v 0 (Raster bit image)
//data.append(contentsOf: [0x1D, 0x76, 0x30, 0x00])
//data.append(UInt8(widthBytes & 0xFF))
//data.append(UInt8((widthBytes >> 8) & 0xFF))
//data.append(UInt8(imageHeight & 0xFF))
//data.append(UInt8((imageHeight >> 8) & 0xFF))
//data.append(contentsOf: bitmap)
//
//return data
//}
//
//static func resizeImage(_ image: UIImage, targetWidth: Int) -> UIImage? {
//let scale = CGFloat(targetWidth) / image.size.width
//let newHeight = image.size.height * scale
//let newSize = CGSize(width: CGFloat(targetWidth), height: newHeight)
//
//let format = UIGraphicsImageRendererFormat()
//format.opaque = true
//format.scale = 1.0
//
//let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
//return renderer.image { context in
//context.cgContext.interpolationQuality = .high
//context.cgContext.setShouldAntialias(true)
//image.draw(in: CGRect(origin: .zero, size: newSize))
//}
//}
//}
