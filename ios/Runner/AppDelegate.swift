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
        
        // MUST be called first
        
        
        // Get the root view controller
//        guard let controller = window?.rootViewController as? FlutterViewController else {
//            print("❌ Failed to get FlutterViewController")
//            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//        }
//        
//        // ============================================
//        // MARK: - Khmer Text Renderer Plugin
//        // ============================================
//        KhmerRendererPlugin.register(with: self.registrar(forPlugin: "khmer_text_renderer")!)
//        print("✅ KhmerRendererPlugin registered")
//        
//        // ============================================
//        // MARK: - Bluetooth Printer Channel
//        // ============================================
//        let printerChannel = FlutterMethodChannel(
//            name: "native_bluetooth_printer",
//            binaryMessenger: controller.binaryMessenger
//        )
//        
//        printerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
//            guard let self = self else {
//                result(FlutterError(code: "NO_INSTANCE", message: "AppDelegate instance lost", details: nil))
//                return
//            }
//            
//            switch call.method {
//            case "scanDevices":
//                self.handleScanForDevices(result: result)
//            case "connect":
//                self.handleConnectToDevice(call: call, result: result)
//            case "disconnect":
//                self.handleDisconnectDevice(result: result)
//            case "isConnected":
//                self.handleGetConnectionStatus(result: result)
//            case "printRaw":
//                self.handlePrintRaw(call: call, result: result)
//            default:
//                result(FlutterMethodNotImplemented)
//            }
//        }
//        print("✅ Bluetooth printer channel registered")
//        
//        // ============================================
//        // MARK: - ESC/POS Receipt Generator Channel (Optional)
//        // ============================================
//        let escposChannel = FlutterMethodChannel(
//            name: "escpos_receipt_generator",
//            binaryMessenger: controller.binaryMessenger
//        )
//        
//        escposChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
//            guard let self = self else {
//                result(FlutterError(code: "NO_INSTANCE", message: "AppDelegate instance lost", details: nil))
//                return
//            }
//            result(FlutterMethodNotImplemented)
//           
//        }
//        print("✅ ESC/POS channel registered")
        
        // ============================================
        // MARK: - Other Plugins
        // ============================================

        //GOOGLE MAP KEY
        GMSServices.provideAPIKey("AIzaSyC3pUau1zh5lLPMEKG8-WanuIKMb8895sg")
        
        FlutterHtmlToPdfPlugin.register(with: self.registrar(forPlugin: "flutter_html_to_pdf")!)
        MyLocationPlugin.register(with: self.registrar(forPlugin: "com.clearviewerp.salesforce/background_service")!)
        BluetoothPrinterPlugin.register(with: self.registrar(forPlugin: "com.clearviewerp.salesforce/bluetoothprinter")!)

        
        // BluetoothPrinterHandler.register(
        //     with: self.registrar(forPlugin: "BluetoothPrinterHandler")!
        // )

//        let controller = window?.rootViewController as! FlutterViewController
//        let registrar = controller.engine.registrar(forPlugin: "BluetoothPrinterHandler")
//
//        BluetoothPrinterHandler.register(with: registrar!)
        
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "com.clearviewerp.salesforce.periodic_task",
            frequency: NSNumber(value: 20 * 60)  // 20 minutes
        )

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // ============================================
    // MARK: - ESC/POS Receipt Generator
    // ============================================
    
    
    // ============================================
    // MARK: - Validation Helpers
    // ============================================
    
    /// Check if data has valid ESC/POS image header
    private func isValidESCPOS(_ data: Data) -> Bool {
        guard data.count >= 4 else { return false }
        return data[0] == 0x1D &&
               data[1] == 0x76 &&
               data[2] == 0x30 &&
               data[3] == 0x00
    }
    
    /// Check if data contains raw UTF-8 text (causes Chinese)
    private func containsRawUtf8(_ data: Data) -> Bool {
        // Khmer UTF-8 range: E1 9E 80 to E1 9F BF
        for i in 0..<(data.count - 2) {
            if data[i] == 0xE1 && data[i + 1] >= 0x9E && data[i + 1] <= 0x9F {
                // Check if it's NOT inside an image block
                if i > 8 {
                    let hasImageHeader = data[i-8] == 0x1D && data[i-7] == 0x76
                    if !hasImageHeader {
                        return true
                    }
                } else {
                    return true
                }
            }
        }
        return false
    }
    
    // ============================================
    // MARK: - Bluetooth Printer Handlers
    // ============================================
    
    private func handleScanForDevices(result: @escaping FlutterResult) {
        print("🔍 Scanning for Bluetooth devices...")
        BluetoothPrinterManager.shared.scanForDevices { devices in
            print("✅ Found ssss \(devices.count) devices")
            result(devices)
        }
    }
    
    private func handleConnectToDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let address = args["address"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing address parameter", details: nil))
            return
        }
        
        print("🔌 Connecting to: \(address)")
        BluetoothPrinterManager.shared.connect(address: address) { success, error in
            if success {
                print("✅ Connected successfully")
                result(true)
            } else {
                print("❌ Connection failed: \(error ?? "Unknown")")
                result(FlutterError(code: "CONNECTION_FAILED", message: error, details: nil))
            }
        }
    }
    
    private func handleDisconnectDevice(result: @escaping FlutterResult) {
        print("🔌 Disconnecting...")
        BluetoothPrinterManager.shared.disconnect()
        print("✅ Disconnected")
        result(true)
    }
    
    private func handleGetConnectionStatus(result: @escaping FlutterResult) {
        let status = BluetoothPrinterManager.shared.getConnectionStatus()
        print("📊 Connection status: \(status)")
        result(status)
    }
    
    private func handlePrintRaw(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let data = args["data"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing data parameter", details: nil))
            return
        }
        
        guard !data.data.isEmpty else {
            result(FlutterError(code: "INVALID_DATA", message: "Empty data", details: nil))
            return
        }
        
        print("🖨️ Printing \(data.data.count) bytes...")
        
        // Validate data before printing
        let previewBytes = data.data.prefix(min(20, data.data.count))
            .map { String(format: "%02X", $0) }
            .joined(separator: " ")
        print("📄 First bytes: \(previewBytes)")
        
        // Check for valid ESC/POS commands
        var hasValidCommands = false
        for i in 0..<min(data.data.count - 1, 100) {
            let byte = data.data[i]
            if byte == 0x1B || byte == 0x1D {
                hasValidCommands = true
                break
            }
        }
        
        if !hasValidCommands {
            print("⚠️ Warning: No ESC/POS commands detected in data")
        }
        
        // Check for raw UTF-8
        if containsRawUtf8(data.data) {
            print("⚠️ WARNING: Data contains raw UTF-8 text!")
            print("   This will print as Chinese characters!")
            // Don't fail, but warn
        }
        
        // Send to printer
        BluetoothPrinterManager.shared.sendData(data.data) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Print completed successfully")
                    result(true)
                } else {
                    let errorMsg = error ?? "Unknown error"
                    print("❌ Print failed: \(errorMsg)")
                    result(FlutterError(code: "PRINT_FAILED", message: errorMsg, details: nil))
                }
            }
        }
    }
}
