
//
// ESCPOSGenerator.swift
//
import UIKit

class ESCPOSGenerator {

// MARK: - Character Detection
static func containsNonASCIICharacters(_ text: String) -> Bool {
return !text.allSatisfy({ $0.isASCII })
}

// MARK: - Control Commands
static func reset() -> Data {
return Data([0x1B, 0x40]) // ESC @
}

static func cut() -> Data {
return Data([0x1D, 0x56, 0x00]) // GS V 0 (Full cut)
}

static func feedLines(_ lines: Int = 3) -> Data {
return Data([0x1B, 0x64, UInt8(lines)]) // ESC d n
}

// MARK: - DYNAMIC TEXT RENDERING (Primary Entry Point)
static func generatePrintData(
_ text: String,
style: TextStyle,
width: Int = 384
) -> Data {
if text.isEmpty {
return Data([0x0A]) // Just a newline
}

if containsNonASCIICharacters(text) {
print("🚨 Non-ASCII text detected. Using image rendering.")
return renderTextAsImage(text, style: style, width: width)
} else {
print("✅ Pure ASCII text detected. Using raw ESC/POS commands.")
return printEnglishText(text, style: style)
}
}

// MARK: - 1. Image-Based Text Rendering (For Non-ASCII/Khmer)
static func renderTextAsImage(
_ text: String,
style: TextStyle,
width: Int = 384
) -> Data {
if text.isEmpty { return Data([0x0A]) }

// This relies on the fixed KhmerTextRenderer (not shown here, but assumed fixed)
if let renderedData = KhmerTextRenderer.renderTextSync(
text,
width: CGFloat(width),
style: style,
maxLines: 0
) {
if let image = UIImage(data: renderedData.data) {
guard image.size.width > 0 && image.size.height > 0 else { return Data([0x0A]) }

// Add padding to prevent clipping
let paddedImage = addVerticalPadding(to: image, padding: 10)

let imageData = imageRaster(paddedImage, width: width)

// Basic validation (Checks for the image header 0x1D 0x76 0x30 0x00)
guard imageData.count > 8 else { return Data([0x0A]) }

if imageData.count >= 4 &&
imageData[0] == 0x1D &&
imageData[1] == 0x76 &&
imageData[2] == 0x30 &&
imageData[3] == 0x00 {
return imageData
}
}
}

print("⚠️ Image rendering failed, returning empty line.")
return Data([0x0A])
}

// MARK: - 2. Raw Command Text Printing (For Pure ASCII/English)
static func printEnglishText(_ text: String, style: TextStyle) -> Data {
guard text.allSatisfy({ $0.isASCII }) else {
return renderTextAsImage(text, style: style)
}

var data = Data()

// 1. CRITICAL: Set Code Page 437/USA (Initial)
data.append(Data([0x1B, 0x52, 0x01])) // ESC R 1 (Select USA International)
data.append(Data([0x1B, 0x74, 0x00])) // ESC t 0 (Select Code Page 437)

// 2. Set alignment
switch style.alignment {
case .left:
data.append(Data([0x1B, 0x61, 0x00]))
case .center:
data.append(Data([0x1B, 0x61, 0x01]))
case .right:
data.append(Data([0x1B, 0x61, 0x02]))
case .justified:
data.append(Data([0x1B, 0x61, 0x00]))
}

// 3. Set bold and font size (using existing logic)
if style.isBold { data.append(Data([0x1B, 0x45, 0x01])) }
var sizeValue: UInt8 = 0x00
if style.fontSize > 28 { sizeValue = 0x11 }
else if style.fontSize > 22 { sizeValue = 0x10 }
if sizeValue != 0x00 { data.append(Data([0x1D, 0x21, sizeValue])) }

// 4. Add ASCII text
if let textData = text.data(using: .ascii) { data.append(textData) }
data.append(Data([0x0A])) // Line feed

// 5. Reset formatting
data.append(Data([0x1B, 0x45, 0x00])) // Bold off
data.append(Data([0x1D, 0x21, 0x00])) // Size normal
data.append(Data([0x1B, 0x61, 0x00])) // Left align

// 💥 6. CRITICAL FIX: Re-select the safe code page 437/USA (Final)
// This ensures the printer is in a safe, known state for the next line,
// preventing corruption of the Khmer image data.
data.append(Data([0x1B, 0x52, 0x01])) // ESC R 1 (Select USA International)
data.append(Data([0x1B, 0x74, 0x00])) // ESC t 0 (Select Code Page 437)

return data
}

// MARK: - Image Helper Functions

private static func addVerticalPadding(to image: UIImage, padding: CGFloat) -> UIImage {
let newSize = CGSize(width: image.size.width, height: image.size.height + (padding * 2))
let format = UIGraphicsImageRendererFormat()
format.opaque = false
format.scale = image.scale

let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
return renderer.image { context in
UIColor.white.setFill()
context.fill(CGRect(origin: .zero, size: newSize))
image.draw(at: CGPoint(x: 0, y: padding))
}
}

static func imageRaster(_ image: UIImage, width: Int = 384) -> Data {
guard let resizedImage = resizeImage(image, targetWidth: width),
let cgImage = resizedImage.cgImage else {
return Data()
}

let imageWidth = cgImage.width
let imageHeight = cgImage.height
let widthBytes = (imageWidth + 7) / 8

var bitmap = [UInt8](repeating: 0, count: widthBytes * imageHeight)

guard let context = CGContext(
data: nil,
width: imageWidth,
height: imageHeight,
bitsPerComponent: 8,
bytesPerRow: imageWidth,
space: CGColorSpaceCreateDeviceGray(),
bitmapInfo: CGImageAlphaInfo.none.rawValue
) else {
return Data()
}

context.interpolationQuality = .high
context.setShouldAntialias(true)
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

guard let pixelData = context.data else { return Data() }
let pixels = pixelData.bindMemory(to: UInt8.self, capacity: imageWidth * imageHeight)

let threshold: UInt8 = 128
for y in 0..<imageHeight {
let rowOffset = y * widthBytes
let pixelRowOffset = y * imageWidth

for byteX in 0..<widthBytes {
var byte: UInt8 = 0
let startX = byteX * 8

for bit in 0..<8 {
let x = startX + bit
if x < imageWidth {
// Invert color (Black text is '1' bit)
if pixels[pixelRowOffset + x] < threshold {
byte |= (1 << (7 - bit))
}
}
}
bitmap[rowOffset + byteX] = byte
}
}

var data = Data()
data.reserveCapacity(8 + bitmap.count)

// GS v 0 (Raster bit image)
data.append(contentsOf: [0x1D, 0x76, 0x30, 0x00])
data.append(UInt8(widthBytes & 0xFF))
data.append(UInt8((widthBytes >> 8) & 0xFF))
data.append(UInt8(imageHeight & 0xFF))
data.append(UInt8((imageHeight >> 8) & 0xFF))
data.append(contentsOf: bitmap)

return data
}

static func resizeImage(_ image: UIImage, targetWidth: Int) -> UIImage? {
let scale = CGFloat(targetWidth) / image.size.width
let newHeight = image.size.height * scale
let newSize = CGSize(width: CGFloat(targetWidth), height: newHeight)

let format = UIGraphicsImageRendererFormat()
format.opaque = true
format.scale = 1.0

let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
return renderer.image { context in
context.cgContext.interpolationQuality = .high
context.cgContext.setShouldAntialias(true)
image.draw(in: CGRect(origin: .zero, size: newSize))
}
}
}
//import UIKit
//
//class ESCPOSGenerator {
//    // MARK: - Character Detection
//    // RENAMED/MODIFIED: Check for any NON-ASCII characters
//    static func containsNonASCIICharacters(_ text: String) -> Bool {
//        return !text.allSatisfy({ $0.isASCII })
//    }
//    
//    // Original Khmer ranges (kept for reference, but new function above is more generic)
//    // static func containsKhmerCharacters(_ text: String) -> Bool {
//    //     return text.unicodeScalars.contains { scalar in
//    //         let codePoint = scalar.value
//    //         return (0x1780...0x17FF).contains(codePoint) ||
//    //                  (0x19E0...0x19FF).contains(codePoint)
//    //     }
//    // }
//    
//    // MARK: - Control Commands
//    static func reset() -> Data {
//        return Data([0x1B, 0x40]) // ESC @
//    }
//    
//    static func cut() -> Data {
//        return Data([0x1D, 0x56, 0x00]) // GS V 0
//    }
//    
//    static func feedLines(_ lines: Int = 3) -> Data {
//        return Data([0x1B, 0x64, UInt8(lines)]) // ESC d n
//    }
//    
//    // MARK: - DYNAMIC TEXT RENDERING (New Primary Function)
//    /**
//     Dynamically prints text. Uses image rendering for non-ASCII characters (Khmer, etc.)
//     and raw ESC/POS commands for pure ASCII text (English, numbers).
//     */
//    static func printText(
//        _ text: String,
//        style: TextStyle,
//        width: Int = 384
//    ) -> Data {
//        if text.isEmpty {
//            return Data([0x0A]) // Just a newline
//        }
//        
//        if containsNonASCIICharacters(text) {
//            print("🚨 Non-ASCII characters detected. Using image rendering for maximum compatibility.")
//            return renderTextAsImage(text, style: style, width: width)
//        } else {
//            print("✅ Pure ASCII text detected. Using raw ESC/POS commands (faster).")
//            return printEnglishText(text, style: style)
//        }
//    }
//    
//    // MARK: - Non-ASCII Text Rendering (Image-Based)
//    // RENAMED: from renderKhmerText to renderTextAsImage
//    static func renderTextAsImage(
//        _ text: String,
//        style: TextStyle,
//        width: Int = 384
//    ) -> Data {
//        if text.isEmpty {
//            return Data([0x0A]) // Just a newline
//        }
//          
//        print("🖼️ Rendering text as image with style: \(text.prefix(30))...")
//        
//        // CRITICAL: Only use image-based rendering for complex characters
//        // NEVER send raw text to printer (causes Chinese characters)
//        // ... (The rest of the original 'renderKhmerText' function logic remains the same)
//        //
//        
//        if let renderedData = KhmerTextRenderer.renderTextSync(
//            text,
//            width: CGFloat(width),
//            style: style,
//            maxLines: 0
//        ) {
//            if let image = UIImage(data: renderedData.data) {
//                // Validate image
//                guard image.size.width > 0 && image.size.height > 0 else {
//                    print("❌ Invalid image dimensions: \(image.size)")
//                    return Data([0x0A])
//                }
//                
//                // Add padding to prevent clipping
//                let paddedImage = addVerticalPadding(to: image, padding: 10)
//                print("✅ Added padding: \(paddedImage.size)")
//                
//                let imageData = imageRaster(paddedImage, width: width)
//                
//                // Validate ESC/POS output
//                guard imageData.count > 8 else {
//                    print("❌ ESC/POS data too small: \(imageData.count) bytes")
//                    return Data([0x0A])
//                }
//                
//                // Verify header
//                if imageData.count >= 4 &&
//                    imageData[0] == 0x1D &&
//                    imageData[1] == 0x76 &&
//                    imageData[2] == 0x30 &&
//                    imageData[3] == 0x00 {
//                    print("✅ Text rendered as ESC/POS image: \(imageData.count) bytes")
//                    return imageData
//                } else {
//                    print("❌ Invalid ESC/POS header generated")
//                    return Data([0x0A])
//                }
//            } else {
//                print("❌ Failed to decode PNG image")
//            }
//        } else {
//            print("❌ KhmerTextRenderer.renderTextSync returned nil")
//        }
//          
//        // CRITICAL: NEVER use fallback - it causes Chinese characters!
//        // If rendering fails completely, just return empty line
//        print("⚠️ Rendering failed completely, returning empty line")
//        print("   DO NOT send raw text - it will show as Chinese!")
//        return Data([0x0A])
//    }
//    
//    // MARK: - ASCII Text Rendering (Raw Commands)
//    static func printEnglishText(_ text: String, style: TextStyle) -> Data {
//        // The check inside this function is now redundant but kept for safety.
//        guard text.allSatisfy({ $0.isASCII }) else {
//            // This case should ideally not be reached if printText() is used.
//            print("⚠️ Non-ASCII text detected, falling back to image rendering.")
//            return renderTextAsImage(text, style: style)
//        }
//        
//        var data = Data()
//        
//        // Set alignment
//        switch style.alignment {
//        case .left:
//            data.append(Data([0x1B, 0x61, 0x00]))
//        case .center:
//            data.append(Data([0x1B, 0x61, 0x01]))
//        case .right:
//            data.append(Data([0x1B, 0x61, 0x02]))
//        case .justified:
//            data.append(Data([0x1B, 0x61, 0x00]))
//        }
//        
//        // Set bold
//        if style.isBold {
//            data.append(Data([0x1B, 0x45, 0x01]))
//        }
//        
//        // Set font size
//        var sizeValue: UInt8 = 0x00
//        if style.fontSize > 28 {
//            sizeValue = 0x11 // Double width and height
//        } else if style.fontSize > 22 {
//            sizeValue = 0x10 // Double width
//        }
//        if sizeValue != 0x00 {
//            data.append(Data([0x1D, 0x21, sizeValue]))
//        }
//        
//        // Add ASCII text only
//        if let textData = text.data(using: .ascii) {
//            data.append(textData)
//        }
//        data.append(Data([0x0A])) // Line feed
//        
//        // Reset formatting
//        data.append(Data([0x1B, 0x45, 0x00])) // Bold off
//        data.append(Data([0x1D, 0x21, 0x00])) // Size normal
//        data.append(Data([0x1B, 0x61, 0x00])) // Left align
//        
//        return data
//    }
//    
//    // MARK: - Add Padding Helper
//    private static func addVerticalPadding(to image: UIImage, padding: CGFloat) -> UIImage {
//        // ... (unchanged)
//        let newSize = CGSize(
//            width: image.size.width,
//            height: image.size.height + (padding * 2)
//        )
//        
//        let format = UIGraphicsImageRendererFormat()
//        format.opaque = false
//        format.scale = image.scale
//        
//        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
//        return renderer.image { context in
//            // Fill with white background
//            UIColor.white.setFill()
//            context.fill(CGRect(origin: .zero, size: newSize))
//            
//            // Draw original image with padding offset
//            image.draw(at: CGPoint(x: 0, y: padding))
//        }
//    }
//    
//    // MARK: - Image Support
//    static func imageRaster(_ image: UIImage, width: Int = 384) -> Data {
//        // ... (unchanged)
//        guard let resizedImage = resizeImage(image, targetWidth: width),
//              let cgImage = resizedImage.cgImage else {
//            print("❌ Failed to resize/prepare image")
//            return Data()
//        }
//        
//        let imageWidth = cgImage.width
//        let imageHeight = cgImage.height
//        let widthBytes = (imageWidth + 7) / 8
//        
//        print("📐 Image dimensions: \(imageWidth)x\(imageHeight), widthBytes: \(widthBytes)")
//        
//        var bitmap = [UInt8](repeating: 0, count: widthBytes * imageHeight)
//        
//        guard let context = CGContext(
//            data: nil,
//            width: imageWidth,
//            height: imageHeight,
//            bitsPerComponent: 8,
//            bytesPerRow: imageWidth,
//            space: CGColorSpaceCreateDeviceGray(),
//            bitmapInfo: CGImageAlphaInfo.none.rawValue
//        ) else {
//            print("❌ Failed to create CGContext")
//            return Data()
//        }
//        
//        // High quality rendering
//        context.interpolationQuality = .high
//        context.setShouldAntialias(true)
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
//        
//        guard let pixelData = context.data else {
//            print("❌ No pixel data")
//            return Data()
//        }
//        
//        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: imageWidth * imageHeight)
//        
//        // Convert to 1-bit bitmap
//        let threshold: UInt8 = 128
//        for y in 0..<imageHeight {
//            let rowOffset = y * widthBytes
//            let pixelRowOffset = y * imageWidth
//            
//            for byteX in 0..<widthBytes {
//                var byte: UInt8 = 0
//                let startX = byteX * 8
//                
//                for bit in 0..<8 {
//                    let x = startX + bit
//                    if x < imageWidth {
//                        if pixels[pixelRowOffset + x] < threshold {
//                            byte |= (1 << (7 - bit))
//                        }
//                    }
//                }
//                
//                bitmap[rowOffset + byteX] = byte
//            }
//        }
//        
//        var data = Data()
//        data.reserveCapacity(8 + bitmap.count)
//        
//        // GS v 0 (Raster bit image)
//        data.append(contentsOf: [0x1D, 0x76, 0x30, 0x00])
//        data.append(UInt8(widthBytes & 0xFF))
//        data.append(UInt8((widthBytes >> 8) & 0xFF))
//        data.append(UInt8(imageHeight & 0xFF))
//        data.append(UInt8((imageHeight >> 8) & 0xFF))
//        data.append(contentsOf: bitmap)
//        
//        print("✅ ESC/POS raster created: \(data.count) bytes")
//        return data
//    }
//    
//    static func resizeImage(_ image: UIImage, targetWidth: Int) -> UIImage? {
//        // ... (unchanged)
//        let scale = CGFloat(targetWidth) / image.size.width
//        let newHeight = image.size.height * scale
//        let newSize = CGSize(width: CGFloat(targetWidth), height: newHeight)
//        
//        let format = UIGraphicsImageRendererFormat()
//        format.opaque = true
//        format.scale = 1.0
//        
//        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
//        return renderer.image { context in
//            // High quality scaling
//            context.cgContext.interpolationQuality = .high
//            context.cgContext.setShouldAntialias(true)
//            image.draw(in: CGRect(origin: .zero, size: newSize))
//        }
//    }
//}
//
//// MARK: - Receipt Builder Extension
//extension ESCPOSGenerator {
//    
//    /// Helper to create TextStyle from parameters
//    static func createTextStyle(
//        fontSize: CGFloat = 20,
//        bold: Bool = false,
//        alignment: TextAlignment = .left,
//        monospace: Bool = false
//    ) -> TextStyle {
//        let style = TextStyle()
//        style.fontSize = fontSize
//        style.isBold = bold
//        style.alignment = alignment
//        style.monospace = monospace
//        return style
//    }
//    
//}
//
//// MARK: - Supporting Types
//struct ReceiptItem {
//    let description: String
//    let quantity: Int
//    let price: String
//    let discount: String
//    let amount: String
//}
//
//
//
//
