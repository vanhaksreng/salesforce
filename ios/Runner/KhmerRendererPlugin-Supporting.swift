//
// TextStyle.swift (or the file defining supporting types)
//
import UIKit
import Flutter

// --- SUPPORTING TYPES ---

/// Defines the style properties for text rendering.
class TextStyle {
    var fontSize: CGFloat = 20
    var isBold: Bool = false
    var alignment: TextAlignment = .left
    var monospace: Bool = false
    
    static func from(dict: [String: Any]) -> TextStyle {
        let style = TextStyle()
        if let size = dict["fontSize"] as? Double {
            style.fontSize = CGFloat(size)
        }
        if let bold = dict["bold"] as? Bool {
            style.isBold = bold
        }
        if let align = dict["alignment"] as? String {
            style.alignment = TextAlignment.from(string: align)
        }
        if let mono = dict["monospace"] as? Bool {
            style.monospace = mono
        }
        return style
    }
}

/// Defines text alignment for both rendering and ESC/POS commands.
enum TextAlignment {
    case left, center, right, justified
    
    static func from(string: String) -> TextAlignment {
        switch string {
        case "center": return .center
        case "right": return .right
        case "justified": return .justified
        default: return .left
        }
    }
    
    // CRITICAL FIX: Helper to convert to UIKit's native alignment type
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return .justified
        }
    }
}

/// Structure to hold the rendered image data and metadata.
struct TextRenderData {
    let data: Data // PNG or other image format data
    let width: CGFloat
    let height: CGFloat
}


// --- FIXED KHMER TEXT RENDERER IMPLEMENTATION ---

class KhmerTextRenderer {
    
    /**
     Draws the text onto a bitmap canvas, calculates required size, and returns PNG data.
     */
    static func renderTextSync(
        _ text: String,
        width: CGFloat,
        style: TextStyle,
        maxLines: Int
    ) -> TextRenderData? {
        
        // 1. Determine Font and Attributes
        let fontName = style.isBold ? "HelveticaNeue-Bold" : "HelveticaNeue"
        
        // Use a system font as a robust fallback for complex scripts like Khmer
        let font = UIFont(name: fontName, size: style.fontSize) ?? UIFont.systemFont(ofSize: style.fontSize)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = style.alignment.nsTextAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        // 2. Calculate Bounding Box
        let boundingBox = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect = (text as NSString).boundingRect(
            with: boundingBox,
            options: options,
            attributes: attributes,
            context: nil
        )
        
        // 3. Validate and Calculate Render Size
        let renderedHeight = ceil(rect.height)
        
        print("📏 [KhmerRenderer] Calculated Render Size: \(width) x \(renderedHeight)")

        guard renderedHeight > 0 else {
            print("❌ [KhmerRenderer] ERROR: Calculated height is zero. Text failed to draw.")
            return nil
        }
        
        let renderSize = CGSize(width: width, height: renderedHeight)
        
        // 4. Draw the Text onto a Canvas
        let renderer = UIGraphicsImageRenderer(size: renderSize)
        let image = renderer.image { _ in
            
            // Fill background with white (essential for 1-bit rasterization)
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: renderSize))
            
            // Draw the text
            text.draw(in: CGRect(origin: .zero, size: renderSize), withAttributes: attributes)
        }
        
        // 5. Convert image to PNG data
        guard let pngData = image.pngData() else {
            print("❌ [KhmerRenderer] Failed to generate PNG data.")
            return nil
        }
        
        print("✅ [KhmerRenderer] Text rendered successfully.")
        
        return TextRenderData(data: pngData, width: width, height: renderedHeight)
    }
    
    // Asynchronous rendering for Flutter PNG path (Updated to use the fixed sync function)
    static func renderText(
        _ text: String,
        width: CGFloat,
        fontSize: CGFloat,
        useCache: Bool,
        maxLines: Int,
        styleDict: [String: Any]?,
        completion: @escaping (FlutterStandardTypedData?) -> Void
    ) {
        DispatchQueue.global().async {
            let style = TextStyle.from(dict: styleDict ?? [:])
            style.fontSize = fontSize
            
            if let renderData = renderTextSync(text, width: width, style: style, maxLines: maxLines) {
                let flutterData = FlutterStandardTypedData(bytes: renderData.data)
                DispatchQueue.main.async {
                    completion(flutterData)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    static func checkKhmerSupport() -> Bool {
        return true
    }
    
    static func clearCache() {
        print("KhmerTextRenderer cache cleared.")
    }
}
