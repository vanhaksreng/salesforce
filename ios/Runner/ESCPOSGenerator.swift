import UIKit

class ESCPOSGenerator {
    // MARK: - Character Detection
    static func containsKhmerCharacters(_ text: String) -> Bool {
        return text.unicodeScalars.contains { scalar in
            let codePoint = scalar.value
            // Khmer Unicode range: U+1780 to U+17FF and U+19E0 to U+19FF
            return (0x1780...0x17FF).contains(codePoint) ||
                   (0x19E0...0x19FF).contains(codePoint)
        }
    }
    
    // MARK: - Control Commands
    static func reset() -> Data {
        return Data([0x1B, 0x40]) // ESC @
    }
    
    static func cut() -> Data {
        return Data([0x1D, 0x56, 0x00]) // GS V 0
    }
    
    static func feedLines(_ lines: Int = 3) -> Data {
        return Data([0x1B, 0x64, UInt8(lines)]) // ESC d n
    }
    
    // MARK: - Text Formatting
    static func setAlignment(_ alignment: TextAlignment) -> Data {
        var cmd: UInt8
        switch alignment {
        case .left:
            cmd = 0x00
        case .center:
            cmd = 0x01
        case .right:
            cmd = 0x02
        }
        return Data([0x1B, 0x61, cmd]) // ESC a n
    }
    
    static func setBold(_ enabled: Bool) -> Data {
        return Data([0x1B, 0x45, enabled ? 0x01 : 0x00]) // ESC E n
    }
    
    static func setFontSize(_ size: FontSize) -> Data {
        var value: UInt8 = 0x00
        switch size {
        case .normal:
            value = 0x00
        case .wide:
            value = 0x10
        case .tall:
            value = 0x01
        case .large:
            value = 0x11
        case .extraLarge:
            value = 0x22
        }
        return Data([0x1D, 0x21, value]) // GS ! n
    }
    
    static func setUnderline(_ enabled: Bool) -> Data {
        return Data([0x1B, 0x2D, enabled ? 0x01 : 0x00]) // ESC - n
    }
    
    // MARK: - Text Printing
    static func printText(_ text: String, encoding: String.Encoding = .utf8) -> Data {
        // Don't print Khmer text as raw text
        if containsKhmerCharacters(text) {
            print("⚠️ Skipping raw Khmer text: \(text.prefix(20))...")
            return Data()
        }
        
        guard let data = text.data(using: encoding) else {
            return Data()
        }
        return data
    }
    
    static func printLine(_ text: String = "", encoding: String.Encoding = .utf8) -> Data {
        // Don't print Khmer text lines as raw text
        if containsKhmerCharacters(text) {
            print("⚠️ Skipping raw Khmer line: \(text.prefix(20))...")
            return Data()
        }
        
        var data = printText(text, encoding: encoding)
        data.append(Data([0x0A])) // LF
        return data
    }
    
    // MARK: - Khmer Text as Image - FIXED
    static func printKhmerTextAsImage(_ text: String, width: Int = 384, fontSize: CGFloat = 16) -> Data {
        print("🖼️ Converting Khmer text to image: \(text.prefix(30))...")
        
        // Use KhmerTextRenderer to convert text to image - FIXED CALL
        if let renderedData = KhmerTextRenderer.renderTextSync(text, width: CGFloat(width), fontSize: fontSize) {
            if let image = UIImage(data: renderedData.data) {
                let imageData = imageRaster(image, width: width)
                print("✅ Khmer text converted to image: \(imageData.count) bytes")
                return imageData
            }
        }
        
        print("❌ Failed to convert Khmer text to image")
        return Data()
    }
    
    // MARK: - Table/Column Support (UPDATED)
    static func printColumns(_ columns: [String], widths: [Int], encoding: String.Encoding = .utf8) -> Data {
        guard columns.count == widths.count else { return Data() }
        
        var data = Data()
        var hasKhmerText = false
        
        // Check if any column contains Khmer text
        for column in columns {
            if containsKhmerCharacters(column) {
                hasKhmerText = true
                break
            }
        }
        
        if hasKhmerText {
            // Handle Khmer text - render each Khmer column as image
            for (index, column) in columns.enumerated() {
                if containsKhmerCharacters(column) {
                    // Render Khmer text as image
                    let imageWidth = widths[index] * 8 // Convert character width to pixels
                    data.append(printKhmerTextAsImage(column, width: imageWidth, fontSize: 12))
                    data.append(feedLines(1))
                } else {
                    // Print regular text normally
                    let width = widths[index]
                    let truncated = column.count > width ? String(column.prefix(width)) : column
                    let padded = truncated.padding(toLength: width, withPad: " ", startingAt: 0)
                    
                    if let textData = padded.data(using: encoding) {
                        data.append(textData)
                    }
                }
            }
            data.append(Data([0x0A])) // LF
        } else {
            // Original implementation for non-Khmer text
            var line = ""
            for (index, column) in columns.enumerated() {
                let width = widths[index]
                let truncated = column.count > width ? String(column.prefix(width)) : column
                let padded = truncated.padding(toLength: width, withPad: " ", startingAt: 0)
                line += padded
            }
            data.append(printLine(line, encoding: encoding))
        }
        
        return data
    }
    
    // MARK: - Separator Lines
    static func printSeparator(char: String = "-", width: Int = 48) -> Data {
        let separator = String(repeating: char, count: width)
        return printLine(separator)
    }
    
    static func printDoubleSeparator(width: Int = 48) -> Data {
        let separator = String(repeating: "=", count: width)
        return printLine(separator)
    }
    
    // MARK: - Receipt Builder (UPDATED)
    static func buildReceiptData(
        companyName: String?,
        companyAddress: String?,
        companyEmail: String?,
        customerName: String?,
        invoiceNo: String?,
        items: [ReceiptItem],
        subtotal: String?,
        discount: String?,
        total: String?,
        logo: UIImage? = nil
    ) -> Data {
        var data = Data()
        
        // Initialize
        data.append(reset())
        data.append(setAlignment(.center))
        
        // Logo (if provided)
        if let logo = logo {
            data.append(imageRaster(logo, width: 200))
            data.append(feedLines(1))
        }
        
        // Company Name (handle Khmer)
        if let name = companyName, !name.isEmpty {
            if containsKhmerCharacters(name) {
                data.append(printKhmerTextAsImage(name, width: 300, fontSize: 18))
                data.append(feedLines(1))
            } else {
                data.append(setBold(true))
                data.append(setFontSize(.large))
                data.append(printLine(name))
                data.append(setBold(false))
                data.append(setFontSize(.normal))
            }
        }
        
        // Company Address (handle Khmer)
        if let address = companyAddress, !address.isEmpty {
            if containsKhmerCharacters(address) {
                data.append(printKhmerTextAsImage(address, width: 300, fontSize: 14))
                data.append(feedLines(1))
            } else {
                data.append(printLine(address))
            }
        }
        
        // Company Email
        if let email = companyEmail, !email.isEmpty {
            data.append(printLine(email))
        }
        
        data.append(feedLines(1))
        data.append(printSeparator())
        
        // Customer Info
        data.append(setAlignment(.left))
        if let customer = customerName, !customer.isEmpty {
            data.append(printLine("Customer: \(customer)"))
        }
        
        if let invoice = invoiceNo, !invoice.isEmpty {
            data.append(printLine("Invoice No: \(invoice)"))
        }
        
        data.append(printSeparator(char: "-", width: 48))
        
        // Table Header
        data.append(setBold(true))
        data.append(printColumns(
            ["#", "Item", "Qty", "Price", "Total"],
            widths: [3, 20, 5, 10, 10]
        ))
        data.append(setBold(false))
        data.append(printSeparator(char: "-", width: 48))
        
        // Items (UPDATED - handle Khmer in items)
        for (index, item) in items.enumerated() {
            let itemData = printColumns(
                ["\(index + 1)", item.description, "\(item.quantity)", item.price, item.amount],
                widths: [3, 20, 5, 10, 10]
            )
            data.append(itemData)
        }
        
        data.append(printSeparator(char: "-", width: 48))
        
        // Totals
        data.append(setAlignment(.right))
        
        if let subtotal = subtotal {
            data.append(printLine("Subtotal: \(subtotal)"))
        }
        
        if let discount = discount {
            data.append(printLine("Discount: \(discount)"))
        }
        
        data.append(printDoubleSeparator())
        data.append(setBold(true))
        data.append(setFontSize(.wide))
        
        if let total = total {
            data.append(printLine("TOTAL: \(total)"))
        }
        
        data.append(setBold(false))
        data.append(setFontSize(.normal))
        data.append(printDoubleSeparator())
        
        // Footer
        data.append(setAlignment(.center))
        data.append(feedLines(1))
        data.append(printLine("Thank you for your business!"))
        data.append(printLine("Powered by Blue Technology Co., Ltd."))
        
        // Cut
        data.append(feedLines(3))
        data.append(cut())
        
        return data
    }
    
    // MARK: - Image Support
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
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        guard let pixelData = context.data else {
            return Data()
        }
        
        let pixels = pixelData.bindMemory(to: UInt8.self, capacity: imageWidth * imageHeight)
        
        for y in 0..<imageHeight {
            let rowOffset = y * widthBytes
            let pixelRowOffset = y * imageWidth
            
            for byteX in 0..<widthBytes {
                var byte: UInt8 = 0
                let startX = byteX * 8
                
                for bit in 0..<8 {
                    let x = startX + bit
                    if x < imageWidth {
                        if pixels[pixelRowOffset + x] < 128 {
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
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Supporting Types
enum TextAlignment {
    case left
    case center
    case right
}

enum FontSize {
    case normal
    case wide
    case tall
    case large
    case extraLarge
}

struct ReceiptItem {
    let description: String
    let quantity: Int
    let price: String
    let amount: String
}
