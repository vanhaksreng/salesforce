import Flutter
import UIKit

public class KhmerRendererPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "khmer_text_renderer",
            binaryMessenger: registrar.messenger()
        )
        let instance = KhmerRendererPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
            return
        }
        
        switch call.method {
        case "renderText":
            handleRenderText(args: args, result: result)
        case "checkKhmerSupport":
            result(KhmerTextRenderer.checkKhmerSupport())
        case "clearCache":
            KhmerTextRenderer.clearCache()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleRenderText(args: [String: Any], result: @escaping FlutterResult) {
        guard let text = args["text"] as? String,
              let format = args["format"] as? String,
              let width = args["width"] as? Double,
              let fontSize = args["fontSize"] as? Double else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
            return
        }
        
        let maxLines = args["maxLines"] as? Int ?? 0
        let styleDict = args["style"] as? [String: Any]
        // let padding = args["padding"] as? Double ?? 10 // Handled in ESCPOSGenerator
        
        // Create style object
        let style: TextStyle
        if let dict = styleDict {
            style = TextStyle.from(dict: dict)
        } else {
            style = TextStyle()
        }
        style.fontSize = CGFloat(fontSize)
        
        if format == "escpos" {
            print("🔄 Dynamic ESC/POS generation requested for: \(text.prefix(30))...")
            
            // CRITICAL: Use the dynamic handler
            let escposData = ESCPOSGenerator.generatePrintData(
                text,
                style: style,
                width: Int(width)
            )

            if escposData.isEmpty {
                print("❌ ESC/POS conversion returned empty data")
                result(nil)
            } else {
                result(FlutterStandardTypedData(bytes: escposData))
            }
            
        } else if format == "png" {
            print("🖼️ Rendering as PNG...")
            
            // For PNG format, return the PNG directly (using async call)
            KhmerTextRenderer.renderText(
                text,
                width: CGFloat(width),
                fontSize: CGFloat(fontSize),
                useCache: args["useCache"] as? Bool ?? true,
                maxLines: maxLines,
                styleDict: styleDict
            ) { data in
                if let data = data {
                    result(data)
                } else {
                    result(nil)
                }
            }
        } else {
            result(FlutterError(
                code: "INVALID_FORMAT",
                message: "Unknown format: \(format). Use 'png' or 'escpos'",
                details: nil
            ))
        }
    }
}


//import Flutter
//import UIKit
//
//public class KhmerRendererPlugin: NSObject, FlutterPlugin {
//    
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(
//            name: "khmer_text_renderer",
//            binaryMessenger: registrar.messenger()
//        )
//        let instance = KhmerRendererPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//    
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let args = call.arguments as? [String: Any] else {
//            result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
//            return
//        }
//        
//        switch call.method {
//        case "renderText":
//            handleRenderText(args: args, result: result)
//            
//        case "checkKhmerSupport":
//            result(KhmerTextRenderer.checkKhmerSupport())
//            
//        case "clearCache":
//            KhmerTextRenderer.clearCache()
//            result(nil)
//            
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//    
//    private func handleRenderText(args: [String: Any], result: @escaping FlutterResult) {
//        guard let text = args["text"] as? String,
//              let format = args["format"] as? String,
//              let width = args["width"] as? Double,
//              let fontSize = args["fontSize"] as? Double else {
//            result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
//            return
//        }
//        
//        let maxLines = args["maxLines"] as? Int ?? 0
//        let styleDict = args["style"] as? [String: Any]
//        let useCache = args["useCache"] as? Bool ?? true
//        let padding = args["padding"] as? Double ?? 10
//        
//        print("📝 renderText called:")
//        print("   Text: \(text.prefix(30))...")
//        print("   Format: \(format)")
//        print("   Width: \(width), FontSize: \(fontSize)")
//        
//        // FIXED: Create style with proper optional handling
//        let style: TextStyle
//        if let dict = styleDict {
//            style = TextStyle.from(dict: dict)
//        } else {
//            style = TextStyle()
//        }
//        style.fontSize = CGFloat(fontSize)
//        
//        // CRITICAL: Check format and handle accordingly
//        if format == "escpos" {
//            print("🔄 Converting to ESC/POS format...")
//            
//            // First render to PNG
//            if let pngData = KhmerTextRenderer.renderTextSync(
//                text,
//                width: CGFloat(width),
//                style: style,
//                maxLines: maxLines
//            ) {
//                print("✅ Rendered to PNG: \(pngData.data.count) bytes")
//                
//                // Then convert PNG to ESC/POS raster
//                if let image = UIImage(data: pngData.data) {
//                    print("✅ Decoded PNG image: \(image.size)")
//                    
//                    // CRITICAL: Add padding to prevent clipping
//                    let paddedImage = addVerticalPadding(to: image, padding: CGFloat(padding))
//                    print("✅ Added padding: \(paddedImage.size)")
//                    
//                    let escposData = ESCPOSGenerator.imageRaster(paddedImage, width: Int(width))
//                    
//                    if escposData.isEmpty {
//                        print("❌ ESC/POS conversion returned empty data")
//                        result(nil)
//                    } else {
//                        print("✅ Converted to ESC/POS: \(escposData.count) bytes")
//                        
//                        // Debug: Show first few bytes
//                        let preview = escposData.prefix(8).map { String(format: "%02X", $0) }.joined(separator: " ")
//                        print("📊 First bytes: \(preview)")
//                        
//                        // CRITICAL: Validate ESC/POS header
//                        if escposData.count >= 4 &&
//                           escposData[0] == 0x1D &&
//                           escposData[1] == 0x76 &&
//                           escposData[2] == 0x30 &&
//                           escposData[3] == 0x00 {
//                            print("✅ Valid ESC/POS header (GS v 0)")
//                            
//                            // Check for raw UTF-8 (would cause Chinese characters)
//                            if containsRawUtf8(escposData) {
//                                print("⚠️ WARNING: Data contains raw UTF-8 text!")
//                                print("   This will show as Chinese on printer")
//                            } else {
//                                print("✅ No raw UTF-8 detected - pure image data")
//                            }
//                            
//                            result(FlutterStandardTypedData(bytes: escposData))
//                        } else {
//                            print("❌ INVALID ESC/POS header!")
//                            print("   Expected: 1D 76 30 00")
//                            print("   Got: \(preview)")
//                            result(FlutterError(
//                                code: "INVALID_ESCPOS",
//                                message: "Invalid ESC/POS format generated",
//                                details: nil
//                            ))
//                        }
//                    }
//                } else {
//                    print("❌ Failed to decode PNG data")
//                    result(nil)
//                }
//            } else {
//                print("❌ Failed to render text to PNG")
//                result(nil)
//            }
//            
//        } else if format == "png" {
//            print("🖼️ Rendering as PNG...")
//            
//            // For PNG format, return the PNG directly
//            KhmerTextRenderer.renderText(
//                text,
//                width: CGFloat(width),
//                fontSize: CGFloat(fontSize),
//                useCache: useCache,
//                maxLines: maxLines,
//                styleDict: styleDict
//            ) { data in
//                if let data = data {
//                    print("✅ PNG rendered: \(data.data.count) bytes")
//                    result(data)
//                } else {
//                    print("❌ PNG rendering failed")
//                    result(nil)
//                }
//            }
//            
//        } else {
//            print("❌ Unknown format: \(format)")
//            result(FlutterError(
//                code: "INVALID_FORMAT",
//                message: "Unknown format: \(format). Use 'png' or 'escpos'",
//                details: nil
//            ))
//        }
//    }
//    
//    // MARK: - Helper Functions
//    
//    /// Add vertical padding to prevent text clipping
//    private func addVerticalPadding(to image: UIImage, padding: CGFloat) -> UIImage {
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
//    /// Check if data contains raw UTF-8 text (causes Chinese on printer)
//    private func containsRawUtf8(_ data: Data) -> Bool {
//        // Khmer UTF-8 range: E1 9E 80 to E1 9F BF
//        for i in 0..<(data.count - 2) {
//            if data[i] == 0xE1 && data[i + 1] >= 0x9E && data[i + 1] <= 0x9F {
//                // Found Khmer UTF-8 sequence
//                // Check if it's NOT inside an image data block
//                if i > 8 {
//                    // Check if we're after a GS v 0 command
//                    let hasImageHeader = data[i-8] == 0x1D && data[i-7] == 0x76
//                    if !hasImageHeader {
//                        return true // Raw UTF-8 found outside image
//                    }
//                } else {
//                    return true // UTF-8 at beginning (not in image)
//                }
//            }
//        }
//        return false
//    }
//}
