import Flutter
import UIKit

@objc class KhmerTextRenderer: NSObject {
    
    private static var renderCache = NSCache<NSString, FlutterStandardTypedData>()
    private static let cacheQueue = DispatchQueue(label: "com.khmer.render.cache", attributes: .concurrent)
    
    // Track if fonts have been logged
    private static var hasLoggedFonts = false
    private static var khmerFontAvailable: UIFont?
    private static var fontCheckComplete = false
    
    // ✅ IMPROVED: Better font detection
    private static func getKhmerFont(size: CGFloat) -> UIFont {
        // Return cached font if available
        if let cachedFont = khmerFontAvailable {
            return cachedFont.withSize(size)
        }
        
        // Print all available fonts ONCE for debugging
        if !hasLoggedFonts {
            print("📋 ===== AVAILABLE FONTS =====")
            for family in UIFont.familyNames.sorted() {
                print("Family: \(family)")
                for name in UIFont.fontNames(forFamilyName: family) {
                    print("  - \(name)")
                }
            }
            print("📋 =============================")
            hasLoggedFonts = true
        }
        
        let fontNames = [
            "NotoSansKhmer-Regular",
            "NotoSansKhmer",
            "Noto Sans Khmer",
            "NotoSerifKhmer-Regular",
            "NotoSerifKhmer",
            "Noto Serif Khmer",
            "KhmerOSSystem",
            "KhmerOS",
            "Khmer Sangam MN",  // iOS built-in
            "KhmerUI",
            "Hanuman",
        ]
        
        for fontName in fontNames {
            if let font = UIFont(name: fontName, size: size) {
                print("✅ SUCCESS: Using Khmer font '\(fontName)' at size \(size)")
                khmerFontAvailable = font
                fontCheckComplete = true
                return font
            } else {
                print("❌ FAILED: Font '\(fontName)' not found")
            }
        }
        
        print("⚠️ CRITICAL: NO KHMER FONT FOUND! Text will be garbled!")
        print("⚠️ Please install NotoSansKhmer-Regular.ttf in Xcode:")
        print("   1. Add font file to project")
        print("   2. Add to 'Copy Bundle Resources' in Build Phases")
        print("   3. Add to Info.plist under UIAppFonts key")
        
        fontCheckComplete = true
        
        // Last resort - system font (will NOT render Khmer correctly)
        return UIFont.systemFont(ofSize: size)
    }
    
    // Pre-load fonts with different sizes
    private static let khmerFont24 = getKhmerFont(size: 24)
    private static let khmerFont20 = getKhmerFont(size: 20)
    private static let khmerFont18 = getKhmerFont(size: 18)
    private static let khmerFont16 = getKhmerFont(size: 16)
    private static let khmerFont14 = getKhmerFont(size: 14)
    private static let khmerFont13 = getKhmerFont(size: 13)
    
    @objc static func renderText(
        _ text: String,
        width: CGFloat = 384,
        fontSize: CGFloat = 24,
        useCache: Bool = true,
        maxLines: Int = 0,
        completion: @escaping (FlutterStandardTypedData?) -> Void
    ) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanText.isEmpty {
            print("⚠️ Empty text provided to renderText")
            completion(nil)
            return
        }
        
        let cacheKey = "\(cleanText)_\(Int(width))_\(Int(fontSize))_\(maxLines)" as NSString
        
        if useCache, let cached = renderCache.object(forKey: cacheKey) {
            print("✅ Cache hit for: \(cleanText.prefix(30))...")
            completion(cached)
            return
        }
        
        print("🔄 Rendering Khmer: '\(cleanText.prefix(50))'")
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let result = renderTextSync(cleanText, width: width, fontSize: fontSize, maxLines: maxLines) {
                if useCache {
                    cacheQueue.async(flags: .barrier) {
                        renderCache.setObject(result, forKey: cacheKey)
                    }
                }
                print("✅ Render successful")
                completion(result)
            } else {
                print("❌ FAILED to render text: '\(cleanText.prefix(30))...'")
                completion(nil)
            }
        }
    }
    
    // ✅ IMPROVED: Better error handling and validation
    static func renderTextSync(
        _ text: String,
        width: CGFloat,
        fontSize: CGFloat,
        maxLines: Int = 0
    ) -> FlutterStandardTypedData? {
        
        // Validate input
        guard !text.isEmpty else {
            print("❌ Cannot render empty text")
            return nil
        }
        
        guard width > 0 && fontSize > 0 else {
            print("❌ Invalid dimensions: width=\(width), fontSize=\(fontSize)")
            return nil
        }
        
        // Select font
        let font: UIFont
        switch Int(fontSize) {
        case 13: font = khmerFont13
        case 14: font = khmerFont14
        case 16: font = khmerFont16
        case 18: font = khmerFont18
        case 20: font = khmerFont20
        case 24: font = khmerFont24
        default: font = getKhmerFont(size: fontSize)
        }
        
        print("🔤 Rendering with font: \(font.fontName) (\(font.familyName)) at \(fontSize)pt")
        
        // Check if font supports Khmer
        if !font.fontName.lowercased().contains("khmer") &&
           !font.familyName.lowercased().contains("khmer") {
            print("⚠️ WARNING: Font '\(font.fontName)' may not support Khmer!")
        }
        
        // Paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = maxLines > 0 ? .byTruncatingTail : .byWordWrapping
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 2
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle,
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        let padding: CGFloat = 10
        let maxWidth = width - (padding * 2)
        
        guard maxWidth > 0 else {
            print("❌ Width too small after padding: \(maxWidth)")
            return nil
        }
        
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = attributedText.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let lineHeight = font.lineHeight
        var finalHeight = boundingBox.height
        
        if maxLines > 0 {
            let maxHeight = lineHeight * CGFloat(maxLines)
            finalHeight = min(finalHeight, maxHeight)
        }
        
        // Ensure minimum height
        if finalHeight < lineHeight {
            finalHeight = lineHeight
        }
        
        let imageWidth = width
        let imageHeight = ceil(finalHeight) + (padding * 2)
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        print("📐 Image dimensions: \(Int(imageWidth))x\(Int(imageHeight))px")
        
        // Validate final size
        guard imageWidth > 0 && imageHeight > 0 else {
            print("❌ Calculated image size is invalid: \(imageWidth)x\(imageHeight)")
            return nil
        }
        
        // High quality rendering
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            print("❌ Failed to create graphics context")
            return nil
        }
        
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Enable high-quality rendering
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        context.setShouldSmoothFonts(true)
        context.setAllowsFontSmoothing(true)
        context.interpolationQuality = .high
        
        // Draw text
        let textRect = CGRect(x: padding, y: padding, width: maxWidth, height: finalHeight)
        
        if maxLines > 0 {
            context.saveGState()
            context.clip(to: textRect)
        }
        
        attributedText.draw(in: textRect)
        
        if maxLines > 0 {
            context.restoreGState()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            print("❌ Failed to get CGImage from context")
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        // Use PNG for perfect quality
        guard let imageData = uiImage.pngData() else {
            print("❌ Failed to convert image to PNG data")
            return nil
        }
        
        let sizeKB = Double(imageData.count) / 1024.0
        print("✅ Rendered: \(Int(imageWidth))x\(Int(imageHeight))px, \(String(format: "%.1f", sizeKB))KB")
        
        return FlutterStandardTypedData(bytes: imageData)
    }
    
    // ✅ IMPROVED: Batch rendering with better error handling
    static func renderTextBatch(
        _ texts: [String],
        widths: [CGFloat],
        fontSizes: [CGFloat],
        maxLines: [Int],
        completion: @escaping ([FlutterStandardTypedData?]) -> Void
    ) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let renderQueue = DispatchQueue(label: "com.khmer.batch.render", attributes: .concurrent)
        let group = DispatchGroup()
        var results: [FlutterStandardTypedData?] = Array(repeating: nil, count: texts.count)
        let resultsLock = NSLock()
        
        print("🔄 Starting batch render of \(texts.count) items...")
        
        for (index, text) in texts.enumerated() {
            group.enter()
            renderQueue.async {
                let width = index < widths.count ? widths[index] : 384
                let fontSize = index < fontSizes.count ? fontSizes[index] : 24
                let maxLine = index < maxLines.count ? maxLines[index] : 0
                
                if let rendered = renderTextSync(text, width: width, fontSize: fontSize, maxLines: maxLine) {
                    resultsLock.lock()
                    results[index] = rendered
                    resultsLock.unlock()
                    print("  ✅ Item \(index + 1)/\(texts.count) rendered")
                } else {
                    print("  ❌ Item \(index + 1)/\(texts.count) FAILED")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            let successCount = results.filter { $0 != nil }.count
            print("✅ Batch render complete: \(successCount)/\(texts.count) successful in \(String(format: "%.1f", elapsed))ms")
            completion(results)
        }
    }
    
    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            renderCache.removeAllObjects()
            print("🗑️ Cache cleared")
        }
    }
    
    @objc static func listAvailableFonts() -> [String] {
        var fonts: [String] = []
        for family in UIFont.familyNames.sorted() {
            fonts.append("[\(family)]")
            for name in UIFont.fontNames(forFamilyName: family) {
                fonts.append("  \(name)")
            }
        }
        return fonts
    }
    
    // ✅ IMPROVED: Better Khmer support checking
    @objc static func checkKhmerSupport() -> [String: Any] {
        let testString = "សូស្តី ជំរាបសួរ" // "Hello" in Khmer
        let font = getKhmerFont(size: 24)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: testString, attributes: attributes)
        let size = attributedString.size()
        
        let supportsKhmer = font.fontName.lowercased().contains("khmer") ||
                           font.familyName.lowercased().contains("khmer")
        
        let isValid = size.width > 0 && size.height > 0 && supportsKhmer
        
        print("🔍 Font check results:")
        print("   Font: \(font.fontName) (\(font.familyName))")
        print("   Supports Khmer: \(supportsKhmer)")
        print("   Rendered size: \(size.width)x\(size.height)")
        print("   Is Valid: \(isValid)")
        
        return [
            "fontName": font.fontName,
            "fontFamily": font.familyName,
            "fontSize": font.pointSize,
            "testString": testString,
            "renderedWidth": size.width,
            "renderedHeight": size.height,
            "isValid": isValid,
            "supportsKhmer": supportsKhmer,
            "fontCheckComplete": fontCheckComplete
        ]
    }
}

//import Flutter
//import UIKit
//
//@objc class KhmerTextRenderer: NSObject {
//    
//    private static var renderCache = NSCache<NSString, FlutterStandardTypedData>()
//    private static let cacheQueue = DispatchQueue(label: "com.khmer.render.cache", attributes: .concurrent)
//    
//    // Track if fonts have been logged
//    private static var hasLoggedFonts = false
//    
//    // CRITICAL: List all possible Khmer font names
//    private static func getKhmerFont(size: CGFloat) -> UIFont {
//        // Print all available fonts ONCE for debugging
//        if !hasLoggedFonts {
//            print("📋 ===== AVAILABLE FONTS =====")
//            for family in UIFont.familyNames.sorted() {
//                print("Family: \(family)")
//                for name in UIFont.fontNames(forFamilyName: family) {
//                    print("  - \(name)")
//                }
//            }
//            print("📋 =============================")
//            hasLoggedFonts = true
//        }
//        
//        let fontNames = [
//            "NotoSansKhmer-Regular",
//            "NotoSansKhmer",
//            "Noto Sans Khmer",
//            "NotoSerifKhmer-Regular",
//            "NotoSerifKhmer",
//            "Noto Serif Khmer",
//            "KhmerOSSystem",
//            "KhmerOS",
//            "Khmer Sangam MN",  // iOS built-in
//            "KhmerUI",
//            "Hanuman",
//        ]
//        
//        for fontName in fontNames {
//            if let font = UIFont(name: fontName, size: size) {
//                print("✅ SUCCESS: Using Khmer font '\(fontName)' at size \(size)")
//                return font
//            } else {
//                print("❌ FAILED: Font '\(fontName)' not found")
//            }
//        }
//        
//        print("⚠️ CRITICAL: NO KHMER FONT FOUND! Text will be garbled!")
//        print("⚠️ Please install NotoSansKhmer-Regular.ttf in Xcode")
//        
//        // Last resort - system font (will NOT render Khmer correctly)
//        return UIFont.systemFont(ofSize: size)
//    }
//    
//    // Pre-load fonts
//    private static let khmerFont24 = getKhmerFont(size: 24)
//    private static let khmerFont20 = getKhmerFont(size: 20)
//    private static let khmerFont18 = getKhmerFont(size: 18)
//    private static let khmerFont16 = getKhmerFont(size: 16)
//    private static let khmerFont14 = getKhmerFont(size: 14)
//    private static let khmerFont13 = getKhmerFont(size: 13)
//    
//    @objc static func renderText(
//        _ text: String,
//        width: CGFloat = 384,
//        fontSize: CGFloat = 24,
//        useCache: Bool = true,
//        maxLines: Int = 0,
//        completion: @escaping (FlutterStandardTypedData?) -> Void
//    ) {
//        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        if cleanText.isEmpty {
//            completion(nil)
//            return
//        }
//        
//        let cacheKey = "\(cleanText)_\(Int(width))_\(Int(fontSize))_\(maxLines)" as NSString
//        
//        if useCache, let cached = renderCache.object(forKey: cacheKey) {
//            print("✅ Cache hit for: \(cleanText.prefix(30))...")
//            completion(cached)
//            return
//        }
//        
//        print("🔄 Rendering Khmer: '\(cleanText.prefix(50))'")
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let result = renderTextSync(cleanText, width: width, fontSize: fontSize, maxLines: maxLines) {
//                if useCache {
//                    cacheQueue.async(flags: .barrier) {
//                        renderCache.setObject(result, forKey: cacheKey)
//                    }
//                }
//                completion(result)
//            } else {
//                print("❌ FAILED to render text")
//                completion(nil)
//            }
//        }
//    }
//    
//     static func renderTextSync(
//        _ text: String,
//        width: CGFloat,
//        fontSize: CGFloat,
//        maxLines: Int = 0
//    ) -> FlutterStandardTypedData? {
//        // Select font
//        let font: UIFont
//        switch Int(fontSize) {
//        case 13: font = khmerFont13
//        case 14: font = khmerFont14
//        case 16: font = khmerFont16
//        case 18: font = khmerFont18
//        case 20: font = khmerFont20
//        case 24: font = khmerFont24
//        default: font = getKhmerFont(size: fontSize)
//        }
//        
//        print("📝 Rendering with font: \(font.fontName) (\(font.familyName)) at \(fontSize)pt")
//        
//        // Paragraph style
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .left
//        paragraphStyle.lineBreakMode = maxLines > 0 ? .byTruncatingTail : .byWordWrapping
//        paragraphStyle.lineSpacing = 4
//        paragraphStyle.paragraphSpacing = 2
//        
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .foregroundColor: UIColor.black,
//            .paragraphStyle: paragraphStyle,
//        ]
//        
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        
//        let padding: CGFloat = 10
//        let maxWidth = width - (padding * 2)
//        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
//        
//        let boundingBox = attributedText.boundingRect(
//            with: constraintRect,
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            context: nil
//        )
//        
//        let lineHeight = font.lineHeight
//        var finalHeight = boundingBox.height
//        
//        if maxLines > 0 {
//            let maxHeight = lineHeight * CGFloat(maxLines)
//            finalHeight = min(finalHeight, maxHeight)
//        }
//        
//        let imageWidth = width
//        let imageHeight = ceil(finalHeight) + (padding * 2)
//        let size = CGSize(width: imageWidth, height: imageHeight)
//        
//        // High quality rendering
//        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
//        
//        guard let context = UIGraphicsGetCurrentContext() else {
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        
//        // White background
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(CGRect(origin: .zero, size: size))
//        
//        // Enable high-quality rendering
//        context.setShouldAntialias(true)
//        context.setAllowsAntialiasing(true)
//        context.setShouldSmoothFonts(true)
//        context.setAllowsFontSmoothing(true)
//        
//        // Draw text
//        let textRect = CGRect(x: padding, y: padding, width: maxWidth, height: finalHeight)
//        
//        if maxLines > 0 {
//            context.saveGState()
//            context.clip(to: textRect)
//        }
//        
//        attributedText.draw(in: textRect)
//        
//        if maxLines > 0 {
//            context.restoreGState()
//        }
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        guard let cgImage = image?.cgImage else {
//            return nil
//        }
//        
//        let uiImage = UIImage(cgImage: cgImage)
//        
//        // Use PNG for perfect quality
//        guard let imageData = uiImage.pngData() else {
//            return nil
//        }
//        
//        let sizeKB = Double(imageData.count) / 1024.0
//        print("✅ Rendered: \(Int(imageWidth))x\(Int(imageHeight))px, \(String(format: "%.1f", sizeKB))KB")
//        
//        return FlutterStandardTypedData(bytes: imageData)
//    }
//    
//    static func renderTextBatch(
//        _ texts: [String],
//        widths: [CGFloat],
//        fontSizes: [CGFloat],
//        maxLines: [Int],
//        completion: @escaping ([FlutterStandardTypedData?]) -> Void
//    ) {
//        let startTime = CFAbsoluteTimeGetCurrent()
//        let renderQueue = DispatchQueue(label: "com.khmer.batch.render", attributes: .concurrent)
//        let group = DispatchGroup()
//        var results: [FlutterStandardTypedData?] = Array(repeating: nil, count: texts.count)
//        let resultsLock = NSLock()
//        
//        for (index, text) in texts.enumerated() {
//            group.enter()
//            renderQueue.async {
//                let width = index < widths.count ? widths[index] : 384
//                let fontSize = index < fontSizes.count ? fontSizes[index] : 24
//                let maxLine = index < maxLines.count ? maxLines[index] : 0
//                
//                if let rendered = renderTextSync(text, width: width, fontSize: fontSize, maxLines: maxLine) {
//                    resultsLock.lock()
//                    results[index] = rendered
//                    resultsLock.unlock()
//                }
//                group.leave()
//            }
//        }
//        
//        group.notify(queue: .main) {
//            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
//            print("✅ Batch rendered \(texts.count) texts in \(String(format: "%.1f", elapsed))ms")
//            completion(results)
//        }
//    }
//    
//    static func clearCache() {
//        cacheQueue.async(flags: .barrier) {
//            renderCache.removeAllObjects()
//            print("🗑️ Cache cleared")
//        }
//    }
//    
//    @objc static func listAvailableFonts() -> [String] {
//        var fonts: [String] = []
//        for family in UIFont.familyNames.sorted() {
//            fonts.append("[\(family)]")
//            for name in UIFont.fontNames(forFamilyName: family) {
//                fonts.append("  \(name)")
//            }
//        }
//        return fonts
//    }
//    
//    @objc static func checkKhmerSupport() -> [String: Any] {
//        let testString = "សួស្តី ជំរាបសួរ" // "Hello" in Khmer
//        let font = getKhmerFont(size: 24)
//        
//        let attributes: [NSAttributedString.Key: Any] = [.font: font]
//        let attributedString = NSAttributedString(string: testString, attributes: attributes)
//        let size = attributedString.size()
//        
//        return [
//            "fontName": font.fontName,
//            "fontFamily": font.familyName,
//            "fontSize": font.pointSize,
//            "testString": testString,
//            "renderedWidth": size.width,
//            "renderedHeight": size.height,
//            "isValid": size.width > 0 && size.height > 0,
//            "supportsKhmer": font.fontName.lowercased().contains("khmer")
//        ]
//    }
//}
