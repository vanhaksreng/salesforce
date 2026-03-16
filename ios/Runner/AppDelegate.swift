import CoreBluetooth
import Flutter
import GoogleMaps
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CBCentralManagerDelegate {

    private var bluetoothManager: CBCentralManager?
    private var bluetoothChannel: FlutterMethodChannel?
    private var pendingResult: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // let controller = window?.rootViewController as! FlutterViewController

        ThermalPrinterPlugin.register(with: self.registrar(forPlugin: "ThermalPrinterPlugin")!)

        // setupBluetoothPermissionChannel(controller: controller)
        
        //GOOGLE MAP KEY
        GMSServices.provideAPIKey("AIzaSyC3pUau1zh5lLPMEKG8-WanuIKMb8895sg")

        FlutterHtmlToPdfPlugin.register(with: self.registrar(forPlugin: "flutter_html_to_pdf")!)
        MyLocationPlugin.register(with: self.registrar(forPlugin: "com.clearviewerp.salesforce/background_service")!)

        //        BluetoothPrinterPlugin.register(
        //            with: self.registrar(forPlugin: "com.clearviewerp.salesforce/bluetoothprinter")!)

        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "com.clearviewerp.salesforce.periodic_task",
            frequency: NSNumber(value: 20 * 60)  // 20 minutes
        )

        // GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    // MARK: - Setup Bluetooth Permission Channel
    private func setupBluetoothPermissionChannel(controller: FlutterViewController) {
        bluetoothChannel = FlutterMethodChannel(
            name: "bluetooth_permissions",
            binaryMessenger: controller.binaryMessenger
        )

        bluetoothChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            switch call.method {
            case "requestBluetoothPermissions":
                self.requestBluetoothPermissions(result: result)

            case "checkBluetoothPermissions":
                self.checkBluetoothPermissions(result: result)

            case "enableBluetooth":
                // On iOS, users enable Bluetooth in Settings
                // We can only check status and guide them
                self.checkBluetoothEnabled(result: result)
            case "isBluetoothEnabled":
                //  NEW: Check if Bluetooth is ON/OFF
                self.isBluetoothEnabled(result: result)

            case "getBluetoothStatus":
                //  NEW: Get complete Bluetooth status
                self.getBluetoothStatus(result: result)
            case "openSettings":
                //  NEW: Open iOS Settings
                self.openSettings(result: result)

            case "openBluetoothSettings":
                //  NEW: Try to open Bluetooth Settings (may not work on all iOS versions)
                self.openBluetoothSettings(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // NEW: Open App Settings
    private func openSettings(result: @escaping FlutterResult) {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:]) { success in
                    result(success)
                }
            } else {
                result(false)
            }
        } else {
            result(false)
        }
    }

    //  NEW: Try to Open Bluetooth Settings (works on some iOS versions)
    private func openBluetoothSettings(result: @escaping FlutterResult) {
        // Try different URL schemes for Bluetooth settings
        let bluetoothURLs = [
            "App-Prefs:Bluetooth",  // iOS 10-13
            "prefs:root=Bluetooth",  // Older iOS
            UIApplication.openSettingsURLString,  // Fallback to app settings
        ]

        var opened = false

        for urlString in bluetoothURLs {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { success in
                        if success {
                            opened = true
                            result(true)
                            return
                        }
                    }
                    if opened {
                        break
                    }
                }
            }
        }

        // If none worked, open general settings
        if !opened {
            openSettings(result: result)
        }
    }

    //  NEW: Get Complete Bluetooth Status
    private func getBluetoothStatus(result: @escaping FlutterResult) {
        // Ensure manager is initialized
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        }

        guard let manager = bluetoothManager else {
            result([
                "hasPermissions": false,
                "isEnabled": false,
                "isSupported": false,
                "canUse": false,
            ])
            return
        }

        // Check permissions
        var hasPermissions = true
        if #available(iOS 13.1, *) {
            hasPermissions = CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            hasPermissions = manager.authorization == .allowedAlways
        }

        // Check if Bluetooth is enabled
        let isEnabled = manager.state == .poweredOn

        // Check if Bluetooth is supported
        let isSupported = manager.state != .unsupported

        // Can use if has permission AND is enabled
        let canUse = hasPermissions && isEnabled

        let status: [String: Any] = [
            "hasPermissions": hasPermissions,
            "isEnabled": isEnabled,
            "isSupported": isSupported,
            "canUse": canUse,
            "state": getStateString(manager.state),
        ]

        print("📱 iOS Bluetooth Status: \(status)")
        result(status)
    }

    // MARK: - Request Bluetooth Permissions
    private func requestBluetoothPermissions(result: @escaping FlutterResult) {
        pendingResult = result

        // Initialize Bluetooth manager (this triggers permission request on iOS 13+)
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        } else {
            // Already initialized, check status
            handleBluetoothAuthorization()
        }
    }
    //  NEW: Helper to get state as string
    private func getStateString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknown"
        }
    }

    // MARK: - Check Bluetooth Permissions
    private func checkBluetoothPermissions(result: @escaping FlutterResult) {
        if #available(iOS 13.1, *) {
            let authorization = CBCentralManager.authorization

            switch authorization {
            case .allowedAlways:
                result(true)
            case .denied, .restricted:
                result(false)
            case .notDetermined:
                result(false)
            @unknown default:
                result(false)
            }
        } else if #available(iOS 13.0, *) {
            // For iOS 13.0, we need to check the manager state
            if bluetoothManager == nil {
                bluetoothManager = CBCentralManager(delegate: self, queue: nil)
            }

            switch bluetoothManager?.authorization {
            case .allowedAlways:
                result(true)
            case .denied, .restricted:
                result(false)
            case .notDetermined:
                result(false)
            case .none:
                result(false)
            @unknown default:
                result(false)
            }
        } else {
            // For iOS 12 and below, Bluetooth permission is automatic
            result(true)
        }
    }

    // MARK: - Check if Bluetooth is Enabled
    private func checkBluetoothEnabled(result: @escaping FlutterResult) {
        isBluetoothEnabled(result: result)
    }

    private func isBluetoothEnabled(result: @escaping FlutterResult) {
        // Ensure manager is initialized
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        }

        let isEnabled = bluetoothManager?.state == .poweredOn
        result(isEnabled)
    }

    // MARK: - Handle Bluetooth Authorization
    private func handleBluetoothAuthorization() {
        if #available(iOS 13.1, *) {
            let authorization = CBCentralManager.authorization

            switch authorization {
            case .allowedAlways:
                print("Bluetooth permission granted")
                pendingResult?(true)
            case .denied, .restricted:
                print(" Bluetooth permission denied")
                pendingResult?(false)
            case .notDetermined:
                print(" Bluetooth permission not determined")
                pendingResult?(false)
            @unknown default:
                pendingResult?(false)
            }
        } else if #available(iOS 13.0, *) {
            switch bluetoothManager?.authorization {
            case .allowedAlways:
                print(" Bluetooth permission granted")
                pendingResult?(true)
            case .denied, .restricted:
                print(" Bluetooth permission denied")
                pendingResult?(false)
            case .notDetermined:
                print(" Bluetooth permission not determined")
                pendingResult?(false)
            case .none:
                pendingResult?(false)
            @unknown default:
                pendingResult?(false)
            }
        } else {
            // iOS 12 and below
            pendingResult?(true)
        }

        pendingResult = nil
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("📱 Bluetooth state updated: \(central.state.rawValue)")

        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is ON")
            handleBluetoothAuthorization()
        case .poweredOff:
            print("❌ Bluetooth is OFF")
            handleBluetoothAuthorization()
        case .unauthorized:
            print("❌ Bluetooth unauthorized")
            pendingResult?(false)
            pendingResult = nil
        case .unsupported:
            print("❌ Bluetooth not supported")
            pendingResult?(false)
            pendingResult = nil
        case .resetting:
            print("⏳ Bluetooth is resetting")
        case .unknown:
            print("⚠️ Bluetooth state unknown")
        @unknown default:
            print("⚠️ Unknown Bluetooth state")
        }
    }

    /// Check if data has valid ESC/POS image header
    private func isValidESCPOS(_ data: Data) -> Bool {
        guard data.count >= 4 else { return false }
        return data[0] == 0x1D && data[1] == 0x76 && data[2] == 0x30 && data[3] == 0x00
    }

    private func notifyFlutterStateChange(_ state: CBManagerState) {
        let isEnabled = state == .poweredOn
        let stateString = getStateString(state)

        bluetoothChannel?.invokeMethod(
            "onBluetoothStateChanged",
            arguments: [
                "isEnabled": isEnabled,
                "state": stateString,
            ])
    }

    /// Check if data contains raw UTF-8 text (causes Chinese)
    private func containsRawUtf8(_ data: Data) -> Bool {
        // Khmer UTF-8 range: E1 9E 80 to E1 9F BF
        for i in 0..<(data.count - 2) {
            if data[i] == 0xE1 && data[i + 1] >= 0x9E && data[i + 1] <= 0x9F {
                // Check if it's NOT inside an image block
                if i > 8 {
                    let hasImageHeader = data[i - 8] == 0x1D && data[i - 7] == 0x76
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
}
