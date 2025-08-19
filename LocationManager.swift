import CoreLocation
import Flutter
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?
    private var shouldRequestAlwaysOnBackground = false

    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10.0
        locationManager?.pausesLocationUpdatesAutomatically = false
    }

    func startLocationUpdates() {
        guard let manager = locationManager else { return }
        
        if canTrackLocation() {
            // Enable background location if we have "Always" permission
            if manager.authorizationStatus == .authorizedAlways {
                manager.allowsBackgroundLocationUpdates = true
            }
            
            manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
        } else {
            requestPermissions()
        }
    }

    func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.allowsBackgroundLocationUpdates = false
    }

    func canTrackLocation() -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        return locationServicesEnabled && (status == .authorizedAlways || status == .authorizedWhenInUse)
    }

    func requestPermissions() {
        guard let manager = locationManager else { return }
        
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            eventSink?(FlutterError(
                code: "PERMISSION_DENIED",
                message: "Location access denied. Please enable in Settings.",
                details: nil
            ))
        case .authorizedWhenInUse:
            // showAlwaysPermissionAlert()
            startLocationUpdates()
        case .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func requestAlwaysPermission() {
        guard let manager = locationManager else { return }

        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse {
            // showAlwaysPermissionAlert()
        } else if status == .notDetermined {
            shouldRequestAlwaysOnBackground = true
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    // private func showAlwaysPermissionAlert() {
    //     DispatchQueue.main.async {
    //         let alert = UIAlertController(
    //             title: "Background Location Required",
    //             message: "This app needs your location to track check-ins, check-outs and optimize sales routes, even when in the background.",
    //             preferredStyle: .alert
    //         )
            
    //         alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
    //             if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
    //                 UIApplication.shared.open(settingsUrl)
    //             }
    //         })
            
    //         alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
            
    //         if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
    //            let viewController = windowScene.windows.first?.rootViewController {
    //             // Prevent presenting when another modal is on top
    //             if viewController.presentedViewController == nil {
    //                 viewController.present(alert, animated: true)
    //             } else {
    //                 print("A view controller is already presented; skipping permission alert")
    //             }
    //         }
    //     }
    // }
    
    // Handle app lifecycle events
    func handleAppBackground() {
        stopLocationUpdates()
        eventSink = nil
        locationManager?.delegate = nil
        locationManager = nil
        UserDefaults.standard.set(true, forKey: "shouldRequestAlwaysPermission")
    }
    
    func handleAppTermination() {
        guard let manager = locationManager else { return }
        let status = manager.authorizationStatus
        if status != .authorizedAlways {
            UserDefaults.standard.set(true, forKey: "shouldRequestAlwaysPermission")
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let eventSink = eventSink else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Int64(location.timestamp.timeIntervalSince1970 * 1000),
            "accuracy": location.horizontalAccuracy
        ]
        
        eventSink(locationData)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse:
            if shouldRequestAlwaysOnBackground {
                shouldRequestAlwaysOnBackground = false
                // Automatically request Always permission
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // self.showAlwaysPermissionAlert()
                }
            }
            startLocationUpdates()
            
        case .authorizedAlways:
            startLocationUpdates()
            
        case .denied, .restricted:
            eventSink?(FlutterError(
                code: "PERMISSION_DENIED",
                message: "Location permissions denied",
                details: nil
            ))
            
        case .notDetermined:
            // Wait for user decision
            break
            
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        eventSink?(FlutterError(
            code: "LOCATION_ERROR",
            message: error.localizedDescription,
            details: nil
        ))
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Check if we should request always permission from previous app termination
        if UserDefaults.standard.bool(forKey: "shouldRequestAlwaysPermission") {
            UserDefaults.standard.removeObject(forKey: "shouldRequestAlwaysPermission")
            requestAlwaysPermission()
        } else {
            requestPermissions()
        }
        
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopLocationUpdates()
        eventSink = nil
        return nil
    }
}
