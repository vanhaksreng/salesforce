import Flutter
import UIKit
import CoreLocation
import BackgroundTasks

@objc public class MyLocationManager: NSObject, FlutterPlugin {
    enum TrackingMode: String {
        case foreground
        case background
        case significant
        case periodic
        case alwaysOn
    }
    
    public enum DetectedActivity {
        case stationary
        case walking
        case driving
        case unknown
        
        var activityType: CLActivityType {
            switch self {
            case .walking: return .fitness
            case .driving: return .automotiveNavigation
            case .stationary: return .other
            case .unknown: return .otherNavigation
            }
        }
        
        var distanceFilter: CLLocationDistance {
            switch self {
            case .stationary: return 10.0
            case .walking: return 2.0
            case .driving: return 3.0
            case .unknown: return 3.0
            }
        }
        
        var desiredAccuracy: CLLocationAccuracy {
            switch self {
            case .stationary: return kCLLocationAccuracyNearestTenMeters
            case .walking: return kCLLocationAccuracyBest
            case .driving: return kCLLocationAccuracyBest
            case .unknown: return kCLLocationAccuracyBest
            }
        }
    }

    private let locationManager = CLLocationManager()
    private static var channel: FlutterMethodChannel?
    private static var isTracking = false
    private static var isFlutterEngineActive = false

    // Internal activity detection (hidden from Flutter)
    private var currentActivity: DetectedActivity = .unknown
    private var lastActivityUpdate: Date = Date()
    private var speedHistory: [Double] = []
    private let speedHistorySize = 10
    
    // Activity thresholds
    private let walkingSpeedThreshold: Double = 2.0  // m/s
    private let drivingSpeedThreshold: Double = 5.0  // m/s
    private let stationaryThreshold: Double = 0.5    // m/s
    private let activityChangeMinInterval: TimeInterval = 30.0

    // Tracking config
    private var trackingMode: TrackingMode = .foreground
    private var lastLocationTime: TimeInterval = 0
    private let maxLocationAge: TimeInterval = 10.0
    private var lastValidLocation: CLLocation?
    
    // Internal location smoothing (hidden from Flutter)
    private var kalmanFilter: KalmanLocationFilter?
    private var locationBuffer: [CLLocation] = []
    private let bufferSize = 7
    private var smoothingEnabled = true

    // Background task management
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private let backgroundTaskTimeout: TimeInterval = 25.0
    private var persistentTimer: Timer?
    
    private let backgroundTaskIdentifier = "com.clearviewerp.salesforce.location"
    private let localStorageManager = LocalStorageManager()

    // MARK: - Plugin registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.clearviewerp.salesforce/background_service", binaryMessenger: registrar.messenger())
        let instance = MyLocationManager()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        isFlutterEngineActive = true
    }

    override init() {
        super.init()
        setupLocationManager()
        setupNotifications()
        setupBackgroundAppRefresh()
        detectAppRestart()
        kalmanFilter = KalmanLocationFilter()
    }
    
    deinit {
        persistentTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        endBackgroundTaskIfNeeded()
        stopTracking()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3.0
        locationManager.activityType = .otherNavigation // Start with mixed activity
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - INTERNAL ACTIVITY DETECTION (Hidden from Flutter)
    private func detectAndAdaptToActivity(from location: CLLocation) {
        let speed = max(location.speed, 0.0)
        
        speedHistory.append(speed)
        if speedHistory.count > speedHistorySize {
            speedHistory.removeFirst()
        }
        
        guard speedHistory.count >= 5 else { return }
        
        let avgSpeed = speedHistory.reduce(0, +) / Double(speedHistory.count)
        let maxSpeed = speedHistory.max() ?? 0
        
        let newActivity: DetectedActivity
        if maxSpeed < stationaryThreshold && avgSpeed < stationaryThreshold {
            newActivity = .stationary
        } else if avgSpeed < walkingSpeedThreshold && maxSpeed < walkingSpeedThreshold * 1.5 {
            newActivity = .walking
        } else if avgSpeed > drivingSpeedThreshold || maxSpeed > drivingSpeedThreshold {
            newActivity = .driving
        } else {
            newActivity = avgSpeed < walkingSpeedThreshold ? .walking : .driving
        }
        
        let timeSinceLastChange = Date().timeIntervalSince(lastActivityUpdate)
        if newActivity != currentActivity && timeSinceLastChange > activityChangeMinInterval {
            adaptLocationSettingsToActivity(newActivity, avgSpeed: avgSpeed, maxSpeed: maxSpeed)
        }
    }
    
    private func adaptLocationSettingsToActivity(_ activity: DetectedActivity, avgSpeed: Double, maxSpeed: Double) {
        let previousActivity = currentActivity
        currentActivity = activity
        lastActivityUpdate = Date()
        
        // Silently update iOS location manager settings
        locationManager.activityType = activity.activityType
        locationManager.distanceFilter = activity.distanceFilter
        locationManager.desiredAccuracy = activity.desiredAccuracy
        
        // Internal logging only (not sent to Flutter)
        myLog("Activity adapted: \(previousActivity) → \(activity) (avg: \(String(format: "%.1f", avgSpeed * 3.6))km/h)")
        
        // Restart location updates with new settings
        if MyLocationManager.isTracking {
            locationManager.stopUpdatingLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    // MARK: - LOCATION PROCESSING (Output only lat/lng to Flutter)
    private func processLocationUpdate(_ location: CLLocation) {
        // 1. Internal activity detection and adaptation
        detectAndAdaptToActivity(from: location)
        
        // // 2. Internal smoothing based on detected activity
        let smoothedLocation = applySmoothingBasedOnActivity(location)
        
        // 3. Send ONLY lat/lng to Flutter (no activity info)
        let locationData = locationDict(from: smoothedLocation)
        
        if MyLocationManager.isFlutterEngineActive {
            safeInvokeMethod("locationUpdate", arguments: locationData)
        } else {
            localStorageManager.saveLocation(locationData)
        }
    }
    
    private func applySmoothingBasedOnActivity(_ location: CLLocation) -> CLLocation {
        guard smoothingEnabled else { return location }
        
        // Disable smoothing in foreground for responsiveness
        if trackingMode == .foreground {
            return location
        }
        
        locationBuffer.append(location)
        if locationBuffer.count > bufferSize {
            locationBuffer.removeFirst()
        }
        
        // Apply activity-specific smoothing internally
        switch currentActivity {
        case .stationary:
            return applyHeavySmoothing() // Reduce GPS drift
        case .walking:
            return applyMediumSmoothing() // Preserve walking paths
        case .driving:
            return applyLightSmoothing() // Preserve route changes
        case .unknown:
            return kalmanFilter?.filter(location: location) ?? location
        }
    }
    
    private func applyHeavySmoothing() -> CLLocation {
        guard locationBuffer.count >= 3 else { return locationBuffer.last! }
        let weights = [0.05, 0.1, 0.15, 0.2, 0.25, 0.25]
        return applySmoothingWithWeights(weights)
    }
    
    private func applyMediumSmoothing() -> CLLocation {
        guard locationBuffer.count >= 3 else { return locationBuffer.last! }
        let weights = [0.1, 0.15, 0.2, 0.25, 0.3]
        return applySmoothingWithWeights(weights)
    }
    
    private func applyLightSmoothing() -> CLLocation {
        guard locationBuffer.count >= 2 else { return locationBuffer.last! }
        let weights = [0.2, 0.3, 0.5]
        return applySmoothingWithWeights(weights)
    }
    
    private func applySmoothingWithWeights(_ weights: [Double]) -> CLLocation {
        let recentLocations = Array(locationBuffer.suffix(weights.count))
        guard let lastLocation = recentLocations.last else {
            return locationBuffer.last ?? CLLocation()
        }

        let count = min(weights.count, recentLocations.count)
        let usedWeights = Array(weights.suffix(count))
        let usedLocations = Array(recentLocations.suffix(count))

        var weightedLat: Double = 0
        var weightedLng: Double = 0
        var totalWeight: Double = 0

        for (index, location) in usedLocations.enumerated() {
            let weight = usedWeights[index]
            weightedLat += location.coordinate.latitude * weight
            weightedLng += location.coordinate.longitude * weight
            totalWeight += weight
        }

        // safety: avoid division by zero
        guard totalWeight > 0 else { return lastLocation }

        let smoothedLat = weightedLat / totalWeight
        let smoothedLng = weightedLng / totalWeight

        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: smoothedLat, longitude: smoothedLng),
            altitude: lastLocation.altitude,
            horizontalAccuracy: lastLocation.horizontalAccuracy,
            verticalAccuracy: lastLocation.verticalAccuracy,
            timestamp: lastLocation.timestamp
        )
    }
    
    // MARK: - ACTIVITY-AWARE LOCATION VALIDATION
    private func isLocationAcceptable(_ location: CLLocation) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let age = abs(currentTime - location.timestamp.timeIntervalSince1970)
        let accuracy = location.horizontalAccuracy
        
        // Activity-based validation thresholds (internal)
        let maxAge: TimeInterval
        let maxAccuracy: CLLocationDistance
        
        myLog("Checking: accuracy (\(String(format: "%.1f", accuracy))m)")
        
        switch currentActivity {
        case .stationary:
            maxAge = 30.0
            maxAccuracy = 20.0
        case .walking:
            maxAge = 10.0
            maxAccuracy = 10.0
        case .driving:
            maxAge = 5.0
            maxAccuracy = 15.0
        case .unknown:
            maxAge = 10.0
            maxAccuracy = 15.0
        }
        
        if age > maxAge {
            myLog("Rejected: Location too old (\(String(format: "%.1f", age))s)")
            return false
        }
        
        if accuracy <= 0 || accuracy > maxAccuracy {
            myLog("Rejected: Poor accuracy (\(String(format: "%.1f", accuracy))m)")
            return false
        }
        
        // Validate against impossible speed changes
        if let lastLocation = lastValidLocation {
            let distance = location.distance(from: lastLocation)
            let timeInterval = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            
            if timeInterval > 0 {
                let calculatedSpeed = distance / timeInterval
                let maxReasonableSpeed: Double
                
                switch currentActivity {
                case .stationary: maxReasonableSpeed = 5.0
                case .walking: maxReasonableSpeed = 15.0
                case .driving: maxReasonableSpeed = 50.0
                case .unknown: maxReasonableSpeed = 30.0
                }
                
                if calculatedSpeed > maxReasonableSpeed {
                    myLog("Rejected: Impossible speed (\(String(format: "%.1f", calculatedSpeed * 3.6))km/h)")
                    return false
                }
            }
        }
        
        myLog("Accepted: accuracy (\(String(format: "%.1f", accuracy))m)")
        
        lastValidLocation = location
        lastLocationTime = currentTime
        return true
    }

    // MARK: - SIMPLIFIED OUTPUT TO FLUTTER (Only lat/lng + essential data)
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

    // MARK: - Flutter Method Handler (Simplified)
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        MyLocationManager.isFlutterEngineActive = true
        
        switch call.method {
        case "startService":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = TrackingMode(rawValue: modeStr) {
                startTracking(mode: mode)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing mode", details: nil))
            }
            
        case "startPersistentTracking":
            startTracking(mode: .alwaysOn)
            result(true)

        case "stopService":
            stopTracking()
            result(true)

        case "requestPermissions":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = TrackingMode(rawValue: modeStr) {
                requestPermissions(for: mode) { granted in
                    result(granted)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing mode", details: nil))
            }

        case "checkPermissions":
            result(getPermissionStatus())
            
        case "syncPendingLocations":
            syncPendingLocations()
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - TRACKING CONTROL (Internal optimization)
    private func startTracking(mode: TrackingMode) {
        trackingMode = mode
        let status = locationManager.authorizationStatus
        
        setTrackingFlag(true)
        
        // Reset internal state
        currentActivity = .unknown
        speedHistory.removeAll()
        locationBuffer.removeAll()
        kalmanFilter?.reset()
        
        // Permission validation
        switch mode {
        case .background, .significant, .periodic, .alwaysOn:
            guard status == .authorizedAlways else {
                safeInvokeMethod("error", arguments: [
                    "message": "\(mode.rawValue) tracking requires 'Always' location permission"
                ])
                return
            }
        case .foreground:
            guard status == .authorizedAlways || status == .authorizedWhenInUse else {
                safeInvokeMethod("error", arguments: [
                    "message": "Location permission required"
                ])
                return
            }
        }

        // Configure for sales mixed activity (internal optimization)
        switch mode {
        case .foreground:
            if locationManager.authorizationStatus == .authorizedAlways {
                locationManager.allowsBackgroundLocationUpdates = false
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 3.0
            locationManager.activityType = .otherNavigation
            smoothingEnabled = true
            locationManager.startUpdatingLocation()

        case .background, .alwaysOn:
            if status == .authorizedAlways {
                locationManager.allowsBackgroundLocationUpdates = true
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 5.0
            locationManager.activityType = .otherNavigation
            smoothingEnabled = true
            locationManager.startUpdatingLocation()
            
            if mode == .alwaysOn {
                startPersistentTimer()
                if #available(iOS 13.0, *) {
                    scheduleBackgroundLocationTask()
                }
            }

        case .significant:
            locationManager.startMonitoringSignificantLocationChanges()
            smoothingEnabled = false
            
        case .periodic:
            locationManager.startMonitoringSignificantLocationChanges()
            setupPeriodicRegionMonitoring()
            smoothingEnabled = true
        }

        MyLocationManager.isTracking = true
        // Only send simple tracking confirmation to Flutter
        safeInvokeMethod("trackingStarted", arguments: [
            "mode": mode.rawValue
        ])
    }

    private func stopTracking() {
        MyLocationManager.isTracking = false
        setTrackingFlag(false)
        
        persistentTimer?.invalidate()
        persistentTimer = nil
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = false
        }
        
        stopPeriodicRegionMonitoring()
        endBackgroundTaskIfNeeded()
        
        safeInvokeMethod("trackingStopped", arguments: nil)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(flutterEngineDestroyed), name: NSNotification.Name("FlutterEngineDestroyed"), object: nil)
    }
    
    @objc private func flutterEngineDestroyed() {
        MyLocationManager.isFlutterEngineActive = false
        MyLocationManager.channel = nil
    }
    
    private func myLog(_ text: String) {
        if MyLocationManager.isFlutterEngineActive {
            // safeInvokeMethod("log", arguments: ["message": text])
        }
    }
    
    private func safeInvokeMethod(_ method: String, arguments: Any?) {
        guard MyLocationManager.isFlutterEngineActive, let channel = MyLocationManager.channel else {
            return
        }
        
        DispatchQueue.main.async {
            channel.invokeMethod(method, arguments: arguments) { result in
                if result is FlutterError {
                    MyLocationManager.isFlutterEngineActive = false
                }
            }
        }
    }
    
    private func syncPendingLocations() {
        guard MyLocationManager.isFlutterEngineActive else { return }
        let pendingLocations = localStorageManager.getPendingLocations()
        if !pendingLocations.isEmpty {
            safeInvokeMethod("syncLocations", arguments: ["data": pendingLocations])
            localStorageManager.clearPendingLocations()
        }
    }
    
    private func requestPermissions(for mode: TrackingMode, completion: @escaping (Bool) -> Void) {
        switch mode {
        case .background, .significant, .periodic, .alwaysOn:
            locationManager.requestAlwaysAuthorization()
        case .foreground:
            locationManager.requestWhenInUseAuthorization()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let status = self.getPermissionStatus()
            let granted = mode == .foreground ?
                (status["canTrackForeground"] == true) :
                (status["background"] == true)
            completion(granted)
        }
    }

    private func getPermissionStatus() -> [String: Bool] {
        let status = locationManager.authorizationStatus
        return [
            "canTrackForeground": status == .authorizedAlways || status == .authorizedWhenInUse,
            "background": status == .authorizedAlways
        ]
    }
    
    private func setTrackingFlag(_ tracking: Bool) {
        UserDefaults.standard.set(tracking, forKey: "was_tracking_before_kill")
        UserDefaults.standard.synchronize()
    }
    
    private func detectAppRestart() {
        let userDefaults = UserDefaults.standard
        let wasTrackingKey = "was_tracking_before_kill"
        
        if userDefaults.bool(forKey: wasTrackingKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startTracking(mode: .alwaysOn)
            }
        }
    }
    
    // Background task methods, region monitoring, etc. remain the same...
    private func setupBackgroundAppRefresh() {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
                self.handleBackgroundLocationTask(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    private func setupPeriodicRegionMonitoring() {
        locationManager.requestLocation()
    }
    
    private func stopPeriodicRegionMonitoring() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix("periodic_region") {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    private func beginBackgroundTask() {
        guard backgroundTaskId == .invalid else { return }
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "LocationUpdate") {
            self.endBackgroundTaskIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + backgroundTaskTimeout) {
            self.endBackgroundTaskIfNeeded()
        }
    }

    private func endBackgroundTaskIfNeeded() {
        guard backgroundTaskId != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = .invalid
    }
    
    private func startPersistentTimer() {
        persistentTimer?.invalidate()
        persistentTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.performPersistentLocationUpdate()
        }
    }
    
    private func performPersistentLocationUpdate() {
        guard MyLocationManager.isTracking else { return }
        beginBackgroundTask()
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
        if #available(iOS 13.0, *) {
            scheduleBackgroundLocationTask()
        }
    }
    
    @available(iOS 13.0, *)
    private func scheduleBackgroundLocationTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            myLog("Could not schedule app refresh: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    private func handleBackgroundLocationTask(task: BGAppRefreshTask) {
        scheduleBackgroundLocationTask()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        beginBackgroundTask()
        locationManager.requestLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.endBackgroundTaskIfNeeded()
            task.setTaskCompleted(success: true)
        }
    }
    
    @objc private func appDidEnterBackground() {
        guard MyLocationManager.isTracking else { return }
        // startTracking(mode: .alwaysOn)
    }

    @objc private func appWillEnterForeground() {
        MyLocationManager.isFlutterEngineActive = true
        endBackgroundTaskIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.syncPendingLocations()
        }
    }

    @objc private func appWillTerminate() {
        MyLocationManager.isFlutterEngineActive = false
        if MyLocationManager.isTracking, let last = locationManager.location {
            let locationData = locationDict(from: last)
            localStorageManager.saveLocation(locationData, isTerminationLocation: true)
        }
        endBackgroundTaskIfNeeded()
    }
}

// MARK: - CLLocationManagerDelegate
extension MyLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard MyLocationManager.isTracking else { return }
        
        if !isLocationAcceptable(location) {
            return
        }
        
        processLocationUpdate(location)
        
        if trackingMode == .background && backgroundTaskId != .invalid {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.endBackgroundTaskIfNeeded()
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        safeInvokeMethod("error", arguments: [
            "message": "Location error: \(error.localizedDescription)"
        ])
        endBackgroundTaskIfNeeded()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        safeInvokeMethod("permissionChanged", arguments: [
            "status": authorizationStatusString(status)
        ])
        
        if MyLocationManager.isTracking {
            switch status {
            case .denied, .restricted:
                stopTracking()
                safeInvokeMethod("error", arguments: [
                    "message": "Location permission denied - tracking stopped"
                ])
                break
            default:
                startTracking(mode: .alwaysOn)
                break
            }
        }
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
