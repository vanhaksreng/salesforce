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
        // Register Khmer Text Renderer Channel
                let khmerChannel = FlutterMethodChannel(
                    name: "khmer_text_renderer",
                    binaryMessenger: controller.binaryMessenger
                )
                
                khmerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
                    switch call.method {
                    case "renderText":
                        self?.handleRenderText(call: call, result: result)
                        
                    case "renderTextBatch":
                        self?.handleRenderTextBatch(call: call, result: result)
                        
                    case "clearCache":
                        KhmerTextRenderer.clearCache()
                        result(true)
                        
//                    case "getCacheInfo":
//                        let info = KhmerTextRenderer.getCacheInfo()
//                        result(info)
                        
                    case "listAvailableFonts":
                        let fonts = KhmerTextRenderer.listAvailableFonts()
                        result(fonts)
                        
                    case "checkKhmerSupport":
                        let support = KhmerTextRenderer.checkKhmerSupport()
                        result(support)
                        
                    default:
                        result(FlutterMethodNotImplemented)
                    }
                }
                
                // Register Bluetooth Printer Channel
                let printerChannel = FlutterMethodChannel(
                    name: "native_bluetooth_printer",
                    binaryMessenger: controller.binaryMessenger
                )
                
                printerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
                    switch call.method {
                    case "scanDevices":
                        self?.handleScanDevices(call: call, result: result)
                        
                    case "connect":
                        self?.handleConnect(call: call, result: result)
                        
                    case "disconnect":
                        self?.handleDisconnect(result: result)
                        
                    case "isConnected":
                        self?.handleIsConnected(result: result)
                        
                    case "printRaw":
                        self?.handlePrintRaw(call: call, result: result)
                        
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
    // MARK: - Khmer Renderer Handlers
       
       private func handleRenderText(call: FlutterMethodCall, result: @escaping FlutterResult) {
           guard let args = call.arguments as? [String: Any],
                 let text = args["text"] as? String else {
               result(FlutterError(code: "INVALID_ARGS", message: "Missing text parameter", details: nil))
               return
           }
           
           let width = args["width"] as? CGFloat ?? 384
           let fontSize = args["fontSize"] as? CGFloat ?? 24
           let maxLines = args["maxLines"] as? Int ?? 0
           let useCache = args["useCache"] as? Bool ?? true
           
           KhmerTextRenderer.renderText(
               text,
               width: width,
               fontSize: fontSize,
               useCache: useCache,
               maxLines: maxLines
           ) { data in
               result(data)
           }
       }
       
       private func handleRenderTextBatch(call: FlutterMethodCall, result: @escaping FlutterResult) {
           guard let args = call.arguments as? [String: Any],
                 let texts = args["texts"] as? [String] else {
               result(FlutterError(code: "INVALID_ARGS", message: "Missing texts parameter", details: nil))
               return
           }
           
           let widths = args["widths"] as? [CGFloat] ?? Array(repeating: 384, count: texts.count)
           let fontSizes = args["fontSizes"] as? [CGFloat] ?? Array(repeating: 24, count: texts.count)
           let maxLines = args["maxLines"] as? [Int] ?? Array(repeating: 0, count: texts.count)
           
           KhmerTextRenderer.renderTextBatch(
               texts,
               widths: widths,
               fontSizes: fontSizes,
               maxLines: maxLines
           ) { results in
               result(results)
           }
       }
       
       // MARK: - Bluetooth Printer Handlers
       
       private func handleScanDevices(call: FlutterMethodCall, result: @escaping FlutterResult) {
           let args = call.arguments as? [String: Any]
           let timeout = args?["timeout"] as? TimeInterval ?? 10
           
           BluetoothPrinterManager.shared.scanForDevices(timeout: timeout) { devices in
               result(devices)
           }
       }
       
       private func handleConnect(call: FlutterMethodCall, result: @escaping FlutterResult) {
           guard let args = call.arguments as? [String: Any],
                 let address = args["address"] as? String else {
               result(FlutterError(code: "INVALID_ARGS", message: "Missing address parameter", details: nil))
               return
           }
           
           BluetoothPrinterManager.shared.connect(address: address) { success, error in
               if success {
                   result(true)
               } else {
                   result(FlutterError(code: "CONNECTION_FAILED", message: error, details: nil))
               }
           }
       }
       
       private func handleDisconnect(result: @escaping FlutterResult) {
           BluetoothPrinterManager.shared.disconnect()
           result(true)
       }
       
       private func handleIsConnected(result: @escaping FlutterResult) {
           let connected = BluetoothPrinterManager.shared.isConnected()
           result(connected)
       }
       
       private func handlePrintRaw(call: FlutterMethodCall, result: @escaping FlutterResult) {
           guard let args = call.arguments as? [String: Any],
                 let data = args["data"] as? FlutterStandardTypedData else {
               result(FlutterError(code: "INVALID_ARGS", message: "Missing data parameter", details: nil))
               return
           }
           
           BluetoothPrinterManager.shared.sendData(data.data) { success, error in
               if success {
                   result(true)
               } else {
                   result(FlutterError(code: "PRINT_FAILED", message: error, details: nil))
               }
           }
       }
}
