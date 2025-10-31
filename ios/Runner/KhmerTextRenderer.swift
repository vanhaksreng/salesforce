import Flutter
import UIKit

@objc class KhmerTextRenderer: NSObject {
    
    private static var renderCache = NSCache<NSString, FlutterStandardTypedData>()
    private static let cacheQueue = DispatchQueue(label: "com.khmer.render.cache", attributes: .concurrent)
    
    // Pre-load fonts once
    private static let khmerFont24 = UIFont(name: "NotoSansKhmer-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
    private static let khmerFont20 = UIFont(name: "NotoSansKhmer-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
    
    // Reusable paragraph style
    private static let paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return style
    }()
    
    @objc static func renderText(
        _ text: String,
        width: CGFloat = 384,
        fontSize: CGFloat = 24,
        useCache: Bool = true,
        completion: @escaping (FlutterStandardTypedData?) -> Void
    ) {
        let cacheKey = "\(text)_\(Int(width))_\(Int(fontSize))" as NSString
        
        // Check cache first (on current queue, no thread switch)
        if useCache, let cached = renderCache.object(forKey: cacheKey) {
            completion(cached)
            return
        }
        
        // Render on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            if let result = renderTextSync(text, width: width, fontSize: fontSize) {
                if useCache {
                    cacheQueue.async(flags: .barrier) {
                        renderCache.setObject(result, forKey: cacheKey)
                    }
                }
                // Return directly without main thread switch
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    // Synchronous rendering (no callbacks)
    private static func renderTextSync(
        _ text: String,
        width: CGFloat,
        fontSize: CGFloat
    ) -> FlutterStandardTypedData? {
        let font: UIFont
        if fontSize == 24 {
            font = khmerFont24
        } else if fontSize == 20 {
            font = khmerFont20
        } else {
            font = UIFont(name: "NotoSansKhmer-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle,
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        let padding: CGFloat = 10
        let maxWidth = width - (padding * 2)
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = attributedText.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let imageWidth = width
        let imageHeight = ceil(boundingBox.height) + (padding * 2)
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // Fill white background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw text
        let textRect = CGRect(
            x: padding,
            y: padding,
            width: maxWidth,
            height: boundingBox.height
        )
        attributedText.draw(in: textRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        // Use JPEG for much faster compression (3-5x faster than PNG)
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        
        return FlutterStandardTypedData(bytes: imageData)
    }
    
    // OPTIMIZED: True parallel batch rendering
    static func renderTextBatch(
        _ texts: [String],
        widths: [CGFloat],
        fontSize: CGFloat = 24,
        completion: @escaping ([FlutterStandardTypedData?]) -> Void
    ) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Use concurrent queue for parallel processing
        let renderQueue = DispatchQueue(label: "com.khmer.batch.render", attributes: .concurrent)
        let group = DispatchGroup()
        var results: [FlutterStandardTypedData?] = Array(repeating: nil, count: texts.count)
        let resultsLock = NSLock()
        
        for (index, text) in texts.enumerated() {
            group.enter()
            
            renderQueue.async {
                let width = index < widths.count ? widths[index] : 384
                let cacheKey = "\(text)_\(Int(width))_\(Int(fontSize))" as NSString
                
                // Check cache first
                if let cached = renderCache.object(forKey: cacheKey) {
                    resultsLock.lock()
                    results[index] = cached
                    resultsLock.unlock()
                    group.leave()
                    return
                }
                
                // Render synchronously on this background thread
                if let rendered = renderTextSync(text, width: width, fontSize: fontSize) {
                    // Cache it
                    cacheQueue.async(flags: .barrier) {
                        renderCache.setObject(rendered, forKey: cacheKey)
                    }
                    
                    resultsLock.lock()
                    results[index] = rendered
                    resultsLock.unlock()
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            print("✅ Batch rendered \(texts.count) texts in \(String(format: "%.1f", elapsed))ms")
            completion(results)
        }
    }
    
    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            renderCache.removeAllObjects()
            print("🗑️ Khmer render cache cleared")
        }
    }
    
    static func getCacheInfo() -> String {
        return "Cache items: \(renderCache.totalCostLimit)"
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


//import Flutter
//import UIKit
//
//@objc class KhmerTextRenderer: NSObject {
//    @objc static func renderText(
//        _ text: String,
//        width: CGFloat = 384,
//        completion: @escaping (FlutterStandardTypedData?) -> Void
//    ) {
//        // Increase font size for better clarity
//        let fontSize: CGFloat = 24
//        let font = UIFont(name: "NotoSansKhmer-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
//        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .left
//        paragraphStyle.lineBreakMode = .byWordWrapping
//        
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .foregroundColor: UIColor.black,
//            .paragraphStyle: paragraphStyle,
//        ]
//
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        
//        // Calculate size with padding
//        let padding: CGFloat = 10
//        let maxWidth = width - (padding * 2)
//        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
//        let boundingBox = attributedText.boundingRect(
//            with: constraintRect,
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            context: nil
//        )
//        
//        let imageWidth = width
//        let imageHeight = ceil(boundingBox.height) + (padding * 2)
//        let size = CGSize(width: imageWidth, height: imageHeight)
//
//        // Create opaque context with white background
//        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
//        
//        guard let context = UIGraphicsGetCurrentContext() else {
//            completion(nil)
//            return
//        }
//        
//        // Fill entire background with white
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(CGRect(origin: .zero, size: size))
//        
//        // Draw text with padding
//        let textRect = CGRect(
//            x: padding,
//            y: padding,
//            width: maxWidth,
//            height: boundingBox.height
//        )
//        attributedText.draw(in: textRect)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        guard let cgImage = image?.cgImage else {
//            completion(nil)
//            return
//        }
//
//        // Convert to PNG data
//        let uiImage = UIImage(cgImage: cgImage)
//        if let data = uiImage.pngData() {
//            completion(FlutterStandardTypedData(bytes: data))
//        } else {
//            completion(nil)
//        }
//    }
//}
