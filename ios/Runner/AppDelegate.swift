import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let methodChannel = "com.clearviewerp.salesforce/location"
    private let eventChannel = "com.clearviewerp.salesforce/location_stream"
    private var locationManager: LocationManager?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        GMSServices.provideAPIKey("AIzaSyC3pUau1zh5lLPMEKG8-WanuIKMb8895sg")
            
        FlutterHtmlToPdfPlugin.register(with: self.registrar(forPlugin: "flutter_html_to_pdf")!)
        
        setupLocationFeatures()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  
    private func setupLocationFeatures() {
        // Only proceed if we can get the FlutterViewController
        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("⚠️ FlutterViewController not available for location setup")
            return
        }
        
        // Initialize LocationManager
        locationManager = LocationManager()
        
        // Set up MethodChannel for location commands
        let methodChannel = FlutterMethodChannel(name: self.methodChannel, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleLocationMethodCall(call: call, result: result)
        }
        
        // Set up EventChannel for location updates
        let eventChannel = FlutterEventChannel(name: self.eventChannel, binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(locationManager)
        
        print("✅ Location features initialized")
    }
    
    private func handleLocationMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let locationManager = self.locationManager else {
            result(FlutterError(code: "UNAVAILABLE", message: "LocationManager not initialized", details: nil))
            return
        }
        
        switch call.method {
        case "startTracking":
            if locationManager.canTrackLocation() {
                locationManager.startLocationUpdates()
                result("Tracking started")
            } else {
                locationManager.requestPermissions()
                result(FlutterError(code: "PERMISSION_DENIED", message: "Location permissions required", details: nil))
            }
        case "stopTracking":
            locationManager.stopLocationUpdates()
            result("Tracking stopped")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
  
}
