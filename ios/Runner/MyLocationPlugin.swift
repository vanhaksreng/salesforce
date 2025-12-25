import Flutter
import UIKit
import CoreLocation
import BackgroundTasks

// MyLocationPlugin serves as the bridge between Flutter and the native iOS code.
@objc public class MyLocationPlugin: NSObject, FlutterPlugin {
    
    // Use a singleton for the native location manager to ensure a single, consistent state.
    private let locationManager = MyLocationManager.shared
    
    // MARK: - FlutterPlugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.clearviewerp.salesforce/background_service", binaryMessenger: registrar.messenger())
        let instance = MyLocationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Pass the channel to the MyLocationManager for native-to-Flutter communication.
        MyLocationManager.shared.setup(with: channel)
    }

    // MARK: - Flutter Method Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startService":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = MyLocationManager.TrackingMode(rawValue: modeStr) {
                locationManager.startTracking(mode: mode)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid tracking mode.", details: nil))
            }
        
        case "stopService":
            locationManager.stopTracking()
            result(true)
            
        case "requestPermissions":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = MyLocationManager.TrackingMode(rawValue: modeStr) {
                locationManager.requestPermissions(for: mode) { granted in
                    result(granted)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid tracking mode.", details: nil))
            }
        
        case "checkPermissions":
            result(locationManager.getPermissionStatus())
            
        case "syncPendingLocations":
            locationManager.syncPendingLocations()
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
