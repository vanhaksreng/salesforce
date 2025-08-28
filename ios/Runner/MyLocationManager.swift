import Flutter
import UIKit
import CoreLocation
import BackgroundTasks

class MyLocationManager: NSObject, CLLocationManagerDelegate {
    
    enum TrackingMode: String {
        case foreground
        case background
    }
    
    static let shared = MyLocationManager()
    
    private let locationManager = CLLocationManager()
    private var channel: FlutterMethodChannel?
    private let localStorageManager = LocalStorageManager()
    private var isFlutterEngineActive: Bool = false

    private override init() {
        super.init()
        setupLocationManager()
    }
    
    func setup(with flutterChannel: FlutterMethodChannel) {
        self.channel = flutterChannel
        isFlutterEngineActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5.0
    }
    
    @objc private func appDidBecomeActive() {
        isFlutterEngineActive = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    @objc private func appWillTerminate() {
        isFlutterEngineActive = false
    }
    
    // MARK: - Location Control
    func requestPermissions(for mode: TrackingMode, completion: @escaping (Bool) -> Void) {
        switch mode {
        case .foreground:
            locationManager.requestWhenInUseAuthorization()
        case .background:
            locationManager.requestAlwaysAuthorization()
        }
        // This completion is not robust. For a real app, rely on `locationManagerDidChangeAuthorization`.
        // This is simplified for demonstration.
        completion(true)
    }
    
    func startTracking(mode: TrackingMode) {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if(mode == .background) {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func getPermissionStatus() -> [String: Bool] {
        let status = locationManager.authorizationStatus
        return [
            "canTrackForeground": status == .authorizedAlways || status == .authorizedWhenInUse,
            "background": status == .authorizedAlways
        ]
    }
    
    func syncPendingLocations() {
        let pendingLocations = localStorageManager.getPendingLocations()
        if !pendingLocations.isEmpty {
            invokeMethodOnChannel(method: "syncLocations", arguments: pendingLocations)
            localStorageManager.clearPendingLocations()
        }
    }
    
    // MARK: - Flutter Communication
    private func invokeMethodOnChannel(method: String, arguments: Any?) {
        guard let channel = channel else {
            return
        }
                
        DispatchQueue.main.async {
            channel.invokeMethod(method, arguments: arguments) { [weak self] result in
                guard let self = self else { return }
                if result is FlutterError {
                    self.isFlutterEngineActive = false
                }
            }
        }
    }
    
    // MARK: - Location Data Processing
    private func processLocationUpdate(_ location: CLLocation) {
        let locationData = locationDict(from: location)
                
        if isFlutterEngineActive {
            invokeMethodOnChannel(method: "locationUpdate", arguments: locationData)
        } else {
            // Store location data if the Flutter engine is not active.
            localStorageManager.saveLocation(locationData)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        processLocationUpdate(latestLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        invokeMethodOnChannel(method: "error", arguments: ["message": "Location error: \(error.localizedDescription)"])
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Restart tracking if authorization is granted.
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
        if manager.authorizationStatus == .authorizedAlways {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startMonitoringSignificantLocationChanges()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func locationDict(from location: CLLocation) -> [String: Any] {
        return [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp),
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "speed": max(location.speed, 0),
            "provider": "CoreLocation"
        ]
    }
    
    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }
}
