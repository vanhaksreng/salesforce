import Flutter
import GoogleMaps
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //============================================
        let controller = window?.rootViewController as! FlutterViewController
        let khmerChannel = FlutterMethodChannel(
            name: "khmer_text_renderer", binaryMessenger: controller.binaryMessenger)

        khmerChannel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "renderText":
                guard let args = call.arguments as? [String: Any],
                      let text = args["text"] as? String
                else {
                    result(FlutterError(code: "BAD_ARGS", message: "Missing text", details: nil))
                    return
                }
                
                let width = args["width"] as? CGFloat ?? 384
                let fontSize = args["fontSize"] as? CGFloat ?? 24
                let useCache = args["useCache"] as? Bool ?? true
                
                KhmerTextRenderer.renderText(text, width: width, fontSize: fontSize, useCache: useCache) { data in
                    result(data)
                }
                
            case "renderTextBatch":
                guard let args = call.arguments as? [String: Any],
                      let texts = args["texts"] as? [String],
                      let widthsArray = args["widths"] as? [NSNumber]
                else {
                    result(FlutterError(code: "BAD_ARGS", message: "Missing texts or widths", details: nil))
                    return
                }
                
                let widths = widthsArray.map { CGFloat($0.doubleValue) }
                let fontSize = args["fontSize"] as? CGFloat ?? 24
                
                KhmerTextRenderer.renderTextBatch(texts, widths: widths, fontSize: fontSize) { results in
                    // Convert optionals to work with Flutter
                    let flutterResults = results.map { $0 as Any? ?? NSNull() }
                    result(flutterResults)
                }
                
            case "clearCache":
                KhmerTextRenderer.clearCache()
                result(nil)
                
            case "getCacheInfo":
                let info = KhmerTextRenderer.getCacheInfo()
                result(info)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // ==================== NATIVE BLUETOOTH PRINTER CHANNEL
                let printerChannel = FlutterMethodChannel(
                    name: "native_bluetooth_printer",
                    binaryMessenger: controller.binaryMessenger
                )
                
                printerChannel.setMethodCallHandler { (call, result) in
                    switch call.method {
                    case "scanDevices":
                        let timeout = (call.arguments as? [String: Any])?["timeout"] as? TimeInterval ?? 10
                        
                        BluetoothPrinterManager.shared.scanForDevices(timeout: timeout) { devices in
                            result(devices)
                        }
                        
                    case "connect":
                        guard let args = call.arguments as? [String: Any],
                              let address = args["address"] as? String
                        else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing address", details: nil))
                            return
                        }
                        
                        BluetoothPrinterManager.shared.connect(address: address) { success, error in
                            if success {
                                result(true)
                            } else {
                                result(FlutterError(code: "CONNECTION_FAILED", message: error, details: nil))
                            }
                        }
                        
                    case "disconnect":
                        BluetoothPrinterManager.shared.disconnect()
                        result(nil)
                        
                    case "isConnected":
                        let connected = BluetoothPrinterManager.shared.isConnected()
                        result(connected)
                        
                    case "getConnectionStatus":
                        let status = BluetoothPrinterManager.shared.getConnectionStatus()
                        result(status)
                        
                    case "printImage":
                        guard let args = call.arguments as? [String: Any],
                              let imageData = args["imageData"] as? FlutterStandardTypedData,
                              let image = UIImage(data: imageData.data)
                        else {
                            result(FlutterError(code: "BAD_ARGS", message: "Invalid image data", details: nil))
                            return
                        }
                        
                        // Generate ESC/POS commands
                        var printData = Data()
                        printData.append(ESCPOSGenerator.reset())
                        printData.append(ESCPOSGenerator.imageRaster(image, width: 576))
                        printData.append(ESCPOSGenerator.cut())
                        
                        // Send to printer
                        BluetoothPrinterManager.shared.sendData(printData) { success, error in
                            if success {
                                result(true)
                            } else {
                                result(FlutterError(code: "PRINT_FAILED", message: error, details: nil))
                            }
                        }
                        
                    case "printRaw":
                        guard let args = call.arguments as? [String: Any],
                              let rawData = args["data"] as? FlutterStandardTypedData
                        else {
                            result(FlutterError(code: "BAD_ARGS", message: "Invalid data", details: nil))
                            return
                        }
                        
                        BluetoothPrinterManager.shared.sendData(rawData.data) { success, error in
                            if success {
                                result(true)
                            } else {
                                result(FlutterError(code: "PRINT_FAILED", message: error, details: nil))
                            }
                        }
                        
                    default:
                        result(FlutterMethodNotImplemented)
                    }
                }

        //================================================
        GeneratedPluginRegistrant.register(with: self)

        GMSServices.provideAPIKey("AIzaSyC3pUau1zh5lLPMEKG8-WanuIKMb8895sg")

        FlutterHtmlToPdfPlugin.register(with: self.registrar(forPlugin: "flutter_html_to_pdf")!)
        MyLocationPlugin.register(
            with: self.registrar(forPlugin: "com.clearviewerp.salesforce/background_service")!)
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "com.clearviewerp.salesforce.periodic_task",
            frequency: NSNumber(value: 20 * 60)  // 20 minutes (15 min minimum)
        )

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
