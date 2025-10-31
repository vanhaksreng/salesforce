class ESCPOSGenerator {
    static func reset() -> Data {
        return Data([0x1B, 0x40]) // ESC @
    }
    
    static func cut() -> Data {
        return Data([0x1D, 0x56, 0x00]) // GS V 0
    }
    
    static func feedLines(_ lines: Int = 3) -> Data {
        return Data([0x1B, 0x64, UInt8(lines)]) // ESC d n
    }
    
    // OPTIMIZED: Use column format (3-5x faster than raster)
    static func imageColumn(_ image: UIImage, width: Int = 576) -> Data {
        guard let resizedImage = resizeImage(image, targetWidth: width),
              let cgImage = resizedImage.cgImage else {
            return Data()
        }
        
        let imageWidth = cgImage.width
        let imageHeight = cgImage.height
        
        // Convert to bitmap
        var bitmap = [UInt8](repeating: 0, count: (imageWidth + 7) / 8 * imageHeight)
        
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
        
        // Convert to monochrome bitmap
        for y in 0..<imageHeight {
            for x in 0..<imageWidth {
                let pixelIndex = y * imageWidth + x
                let byteIndex = y * ((imageWidth + 7) / 8) + (x / 8)
                let bitIndex = 7 - (x % 8)
                
                if pixels[pixelIndex] < 128 { // Black pixel
                    bitmap[byteIndex] |= (1 << bitIndex)
                }
            }
        }
        
        // ESC * m nL nH (Bit image mode - more compact than raster)
        var data = Data()
        
        let widthBytes = (imageWidth + 7) / 8
        let stripeHeight = 8 // Process 8 rows at a time
        
        for y in Swift.stride(from: 0, to: imageHeight, by: stripeHeight) {
            let rowsInStripe = min(stripeHeight, imageHeight - y)
            
            // ESC * 33 (24-dot double-density)
            data.append(contentsOf: [0x1B, 0x2A, 0x21])
            
            // Width in bytes
            data.append(UInt8(imageWidth & 0xFF))
            data.append(UInt8((imageWidth >> 8) & 0xFF))
            
            // Column data
            for x in 0..<imageWidth {
                var columnByte: UInt8 = 0
                for bit in 0..<min(8, rowsInStripe) {
                    let pixelY = y + bit
                    if pixelY < imageHeight {
                        let byteIndex = pixelY * widthBytes + (x / 8)
                        let bitIndex = 7 - (x % 8)
                        if bitmap[byteIndex] & (1 << bitIndex) != 0 {
                            columnByte |= (1 << (7 - bit))
                        }
                    }
                }
                data.append(columnByte)
            }
            
            // Line feed
            data.append(0x0A)
        }
        
        return data
    }
    
    // FAST: Use raster format but optimized
    static func imageRaster(_ image: UIImage, width: Int = 576) -> Data {
        guard let resizedImage = resizeImage(image, targetWidth: width),
              let cgImage = resizedImage.cgImage else {
            return Data()
        }
        
        let imageWidth = cgImage.width
        let imageHeight = cgImage.height
        let widthBytes = (imageWidth + 7) / 8
        
        // Pre-allocate bitmap
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
        
        // OPTIMIZED: Process 8 pixels at once
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
        
        // Create ESC/POS raster image command
        var data = Data()
        data.reserveCapacity(8 + bitmap.count) // Pre-allocate
        
        // GS v 0 (Raster bit image)
        data.append(contentsOf: [0x1D, 0x76, 0x30, 0x00])
        
        // Width (in bytes)
        data.append(UInt8(widthBytes & 0xFF))
        data.append(UInt8((widthBytes >> 8) & 0xFF))
        
        // Height
        data.append(UInt8(imageHeight & 0xFF))
        data.append(UInt8((imageHeight >> 8) & 0xFF))
        
        // Bitmap data
        data.append(contentsOf: bitmap)
        
        return data
    }
    
    static func resizeImage(_ image: UIImage, targetWidth: Int) -> UIImage? {
        let scale = CGFloat(targetWidth) / image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSize(width: CGFloat(targetWidth), height: newHeight)
        
        // Use optimized rendering
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
