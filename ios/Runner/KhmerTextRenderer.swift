//import Flutter
//import UIKit
//import CoreText
//
//// MARK: - Text Alignment
//@objc enum TextAlignment: Int {
//    case left = 0
//    case center = 1
//    case right = 2
//    case justified = 3
//}
//
//// MARK: - Text Style
//@objc class TextStyle: NSObject {
//    var fontSize: CGFloat = 24
//    var isBold: Bool = false
//    var isItalic: Bool = false
//    var isUnderline: Bool = false
//    var textColor: UIColor = .black
//    var backgroundColor: UIColor = .white
//    var alignment: TextAlignment = .left
//    var lineSpacing: CGFloat = 0
//    var letterSpacing: CGFloat = 0
//    var opacity: CGFloat = 1.0
//    var monospace: Bool = false
//    
//    static func from(dict: [String: Any]) -> TextStyle {
//        let style = TextStyle()
//        
//        // Font size (handle both Double and CGFloat)
//        if let fontSize = dict["fontSize"] as? CGFloat {
//            style.fontSize = fontSize
//        } else if let fontSize = dict["fontSize"] as? Double {
//            style.fontSize = CGFloat(fontSize)
//        }
//        
//        // Boolean properties
//        if let isBold = dict["bold"] as? Bool { style.isBold = isBold }
//        if let isItalic = dict["italic"] as? Bool { style.isItalic = isItalic }
//        if let isUnderline = dict["underline"] as? Bool { style.isUnderline = isUnderline }
//        if let monospace = dict["monospace"] as? Bool { style.monospace = monospace }
//        
//        // FIXED: Handle alignment as both String and Int
//        if let alignmentString = dict["alignment"] as? String {
//            switch alignmentString.lowercased() {
//            case "left":
//                style.alignment = .left
//            case "center", "centre":
//                style.alignment = .center
//            case "right":
//                style.alignment = .right
//            case "justified", "justify":
//                style.alignment = .justified
//            default:
//                style.alignment = .left
//            }
//        } else if let alignmentInt = dict["alignment"] as? Int {
//            style.alignment = TextAlignment(rawValue: alignmentInt) ?? .left
//        }
//        
//        // Spacing (handle both Double and CGFloat)
//        if let lineSpacing = dict["lineSpacing"] as? CGFloat {
//            style.lineSpacing = lineSpacing
//        } else if let lineSpacing = dict["lineSpacing"] as? Double {
//            style.lineSpacing = CGFloat(lineSpacing)
//        }
//        
//        if let letterSpacing = dict["letterSpacing"] as? CGFloat {
//            style.letterSpacing = letterSpacing
//        } else if let letterSpacing = dict["letterSpacing"] as? Double {
//            style.letterSpacing = CGFloat(letterSpacing)
//        }
//        
//        // Opacity
//        if let opacity = dict["opacity"] as? CGFloat {
//            style.opacity = max(0, min(1, opacity))
//        } else if let opacity = dict["opacity"] as? Double {
//            style.opacity = CGFloat(max(0, min(1, opacity)))
//        }
//        
//        // Colors
//        if let colorHex = dict["textColor"] as? String {
//            style.textColor = UIColor.from(hex: colorHex)
//        } else if let colorHex = dict["color"] as? String {
//            // Support both "textColor" and "color"
//            style.textColor = UIColor.from(hex: colorHex)
//        }
//        
//        if let bgColorHex = dict["backgroundColor"] as? String {
//            style.backgroundColor = UIColor.from(hex: bgColorHex)
//        }
//        
//        return style
//    }
//}
//
//// MARK: - Khmer Text Renderer
//@objc class KhmerTextRenderer: NSObject {
//    
//    private static var renderCache = NSCache<NSString, FlutterStandardTypedData>()
//    private static let cacheQueue = DispatchQueue(label: "com.khmer.render.cache", attributes: .concurrent)
//    private static var khmerFont: UIFont?
//    
//    private static let khmerFontNames = [
//        "Noto Sans Khmer",
//        "NotoSansKhmer-Regular",
//        "Hanuman",
//        "Khmer Sangam MN",
//        "KhmerOSSystem",
//        "KhmerOS"
//    ]
//    
//    private static let monospaceFontNames = [
//        "Menlo-Regular",
//        "Monaco",
//        "Courier New",
//        "Courier",
//        "Andale Mono"
//    ]
//    
//    private static func getFont(size: CGFloat, style: TextStyle) -> UIFont {
//        var baseFont: UIFont
//        
//        if style.monospace {
//            for fontName in monospaceFontNames {
//                if let font = UIFont(name: fontName, size: size) {
//                    baseFont = font
//                    if style.isBold && style.isItalic { return baseFont.withTraits([.traitBold, .traitItalic]) }
//                    if style.isBold { return baseFont.withTraits([.traitBold]) }
//                    if style.isItalic { return baseFont.withTraits([.traitItalic]) }
//                    return baseFont
//                }
//            }
//            return UIFont.monospacedSystemFont(ofSize: size, weight: style.isBold ? .bold : .regular)
//        }
//        
//        if let existingKhmer = khmerFont {
//            baseFont = existingKhmer.withSize(size)
//        } else {
//            for fontName in khmerFontNames {
//                if let font = UIFont(name: fontName, size: size) {
//                    khmerFont = font
//                    baseFont = font
//                    break
//                }
//            }
//            if khmerFont == nil { baseFont = UIFont.systemFont(ofSize: size) }
//            else { baseFont = khmerFont!.withSize(size) }
//        }
//        
//        if style.isBold && style.isItalic { return baseFont.withTraits([.traitBold, .traitItalic]) }
//        if style.isBold { return baseFont.withTraits([.traitBold]) }
//        if style.isItalic { return baseFont.withTraits([.traitItalic]) }
//        
//        return baseFont
//    }
//    
//    // MARK: - Public render method
//    @objc static func renderText(
//        _ text: String,
//        width: CGFloat = 384,
//        fontSize: CGFloat = 24,
//        useCache: Bool = true,
//        maxLines: Int = 0,
//        styleDict: [String: Any]? = nil,
//        completion: @escaping (FlutterStandardTypedData?) -> Void
//    ) {
//        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        if cleanText.isEmpty { completion(nil); return }
//        
//        // FIXED: Proper optional handling
//        let style: TextStyle
//        if let dict = styleDict {
//            style = TextStyle.from(dict: dict)
//        } else {
//            style = TextStyle()
//        }
//        style.fontSize = fontSize
//        
//        let cacheKey = generateCacheKey(text: cleanText, width: width, style: style, maxLines: maxLines)
//        if useCache, let cached = renderCache.object(forKey: cacheKey) { completion(cached); return }
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let result = renderTextSync(cleanText, width: width, style: style, maxLines: maxLines) {
//                if useCache { cacheQueue.async(flags: .barrier) { renderCache.setObject(result, forKey: cacheKey) } }
//                completion(result)
//            } else { completion(nil) }
//        }
//    }
//    
//    // MARK: - Synchronous rendering (used for ESC/POS conversion)
//    static func renderTextSync(_ text: String, width: CGFloat, style: TextStyle, maxLines: Int = 0) -> FlutterStandardTypedData? {
//        let font = getFont(size: style.fontSize, style: style)
//        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineBreakMode = .byWordWrapping
//        
//        // IMPROVED: Better line spacing calculation
//        let baseLineSpacing = max(style.lineSpacing, style.fontSize * 0.3)
//        paragraphStyle.lineSpacing = baseLineSpacing
//        paragraphStyle.lineHeightMultiple = 1.2
//        paragraphStyle.minimumLineHeight = font.lineHeight
//        paragraphStyle.maximumLineHeight = font.lineHeight * 1.2 + baseLineSpacing
//        
//        switch style.alignment {
//        case .left: paragraphStyle.alignment = .left
//        case .center: paragraphStyle.alignment = .center
//        case .right: paragraphStyle.alignment = .right
//        case .justified: paragraphStyle.alignment = .justified
//        }
//        
//        var attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .paragraphStyle: paragraphStyle,
//            .foregroundColor: style.textColor.withAlphaComponent(style.opacity)
//        ]
//        if style.letterSpacing != 0 { attributes[.kern] = style.letterSpacing }
//        if style.isUnderline { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue; attributes[.underlineColor] = style.textColor }
//        
//        let attrString = NSAttributedString(string: text, attributes: attributes)
//        let textStorage = NSTextStorage(attributedString: attrString)
//        let layoutManager = NSLayoutManager()
//        
//        let lineHeight = font.lineHeight * 1.2 + baseLineSpacing
//        let maxHeight: CGFloat = (maxLines > 0) ? lineHeight * CGFloat(maxLines) : .greatestFiniteMagnitude
//        
//        let horizontalPadding: CGFloat = 10
//        let textContainer = NSTextContainer(size: CGSize(width: width - horizontalPadding * 2, height: maxHeight))
//        textContainer.lineFragmentPadding = 0
//        if maxLines > 0 { textContainer.maximumNumberOfLines = maxLines }
//        
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//        
//        _ = layoutManager.glyphRange(for: textContainer)
//        let usedRect = layoutManager.usedRect(for: textContainer)
//        let clampedHeight = min(usedRect.height, maxHeight)
//        
//        // IMPROVED: Better padding calculation to prevent clipping
//        let verticalPadding: CGFloat = max(10, style.fontSize * 0.4)
//        let extraBuffer: CGFloat = style.fontSize * 0.2
//        let imageSize = CGSize(
//            width: width,
//            height: ceil(clampedHeight) + verticalPadding * 2 + extraBuffer
//        )
//        
//        UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
//        defer { UIGraphicsEndImageContext() }
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        
//        // HIGH QUALITY rendering settings
//        context.setAllowsAntialiasing(true)
//        context.setShouldAntialias(true)
//        context.interpolationQuality = .high
//        
//        context.setFillColor(style.backgroundColor.cgColor)
//        context.fill(CGRect(origin: .zero, size: imageSize))
//        
//        let textOrigin = CGPoint(x: horizontalPadding, y: verticalPadding)
//        layoutManager.drawBackground(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), at: textOrigin)
//        layoutManager.drawGlyphs(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), at: textOrigin)
//        
//        guard let image = UIGraphicsGetImageFromCurrentImageContext(), let pngData = image.pngData() else { return nil }
//        return FlutterStandardTypedData(bytes: pngData)
//    }
//    
//    private static func generateCacheKey(text: String, width: CGFloat, style: TextStyle, maxLines: Int) -> NSString {
//        return "\(text)_\(Int(width))_\(Int(style.fontSize))_\(style.isBold)_\(style.isItalic)_\(style.alignment.rawValue)_\(style.monospace)_\(maxLines)" as NSString
//    }
//    
//    @objc static func clearCache() {
//        cacheQueue.async(flags: .barrier) { renderCache.removeAllObjects() }
//    }
//    
//    @objc static func checkKhmerSupport() -> [String: Any] {
//        let testText = "សួស្តី Hello ជំរាបសួរ 123"
//        let font = getFont(size: 24, style: TextStyle())
//        let attributed = NSAttributedString(string: testText, attributes: [.font: font])
//        let size = attributed.size()
//        
//        var monoStyle = TextStyle()
//        monoStyle.monospace = true
//        let monoFont = getFont(size: 24, style: monoStyle)
//        
//        return [
//            "fontName": font.fontName,
//            "fontFamily": font.familyName,
//            "supportsKhmer": true,
//            "supportsEnglish": true,
//            "renderedWidth": size.width,
//            "renderedHeight": size.height,
//            "isValid": size.width > 0 && size.height > 0,
//            "supportsMonospace": true,
//            "monospaceFontName": monoFont.fontName
//        ]
//    }
//}
//
//// MARK: - UIFont Extensions
//extension UIFont {
//    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
//        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
//        return UIFont(descriptor: descriptor, size: 0)
//    }
//}
//
//// MARK: - UIColor Extensions
//extension UIColor {
//    static func from(hex: String) -> UIColor {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//        
//        let length = hexSanitized.count
//        let red, green, blue: CGFloat
//        
//        if length == 6 {
//            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            blue = CGFloat(rgb & 0x0000FF) / 255.0
//        } else if length == 8 {
//            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
//            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
//            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
//        } else {
//            return UIColor.black
//        }
//        
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//}
