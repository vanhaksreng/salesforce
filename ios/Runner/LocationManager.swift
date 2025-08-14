import CoreLocation
import Flutter

class LocationManager: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10.0 // Update every 10 meters
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
    }

    func startLocationUpdates() {
        if canTrackLocation() {
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            eventSink?(FlutterError(
                code: "PERMISSION_DENIED",
                message: "Location permissions or services unavailable",
                details: nil
            ))
        }
    }

    func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
    }

    func canTrackLocation() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        return locationServicesEnabled && (status == .authorizedAlways || status == .authorizedWhenInUse)
    }

    func requestPermissions() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
    }

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
        if !canTrackLocation() {
            eventSink?(FlutterError(
                code: "PERMISSION_DENIED",
                message: "Location permissions or services unavailable",
                details: nil
            ))
        } else if eventSink != nil {
            startLocationUpdates()
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        requestPermissions()
        if canTrackLocation() {
            startLocationUpdates()
        } else {
            events(FlutterError(
                code: "PERMISSION_DENIED",
                message: "Location permissions or services unavailable",
                details: nil
            ))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopLocationUpdates()
        eventSink = nil
        return nil
    }
}
