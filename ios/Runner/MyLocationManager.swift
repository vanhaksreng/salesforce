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

    private let locationManager = CLLocationManager()
    private static var channel: FlutterMethodChannel?
    private static var isTracking = false
    private static var isFlutterEngineActive = false

    // Tracking config
    private var trackingMode: TrackingMode = .foreground
    private var distanceFilter: Double = 10.0
    private let accuracyThreshold: CLLocationDistance = 100.0
    private var lastLocationTime: TimeInterval = 0
    private let minUpdateInterval: TimeInterval = 30.0
    private let maxLocationAge: TimeInterval = 60.0

    // Background task management
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private let backgroundTaskTimeout: TimeInterval = 25.0
    private var persistentTimer: Timer?
    
    // Background App Refresh registration
    private let backgroundTaskIdentifier = "com.clearviewerp.salesforce.location"
    
    // App restart detection
    private var appKilledFlag: Bool = false
    
    // Periodic mode - region monitoring
    private var currentRegion: CLCircularRegion?
    private let periodicRadius: CLLocationDistance = 100.0
    private var regionIdentifierCounter = 0
    
    // Local Storage - Similar to Android SharedPreferences
    private let localStorageManager = LocalStorageManager()

    // MARK: - Plugin registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.clearviewerp.salesforce/background_service", binaryMessenger: registrar.messenger())
        let instance = MyLocationManager()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
        // Flutter engine is active when plugin is registered
        isFlutterEngineActive = true
    }

    override init() {
        super.init()
        setupLocationManager()
        setupNotifications()
        setupBackgroundAppRefresh()
        detectAppRestart()
    }
    
    deinit {
        persistentTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        endBackgroundTaskIfNeeded()
        stopTracking()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = distanceFilter
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(flutterEngineDestroyed),
            name: NSNotification.Name("FlutterEngineDestroyed"),
            object: nil
        )
    }
    
    @objc private func flutterEngineDestroyed() {
        MyLocationManager.isFlutterEngineActive = false
        MyLocationManager.channel = nil
        print("Flutter engine destroyed, channel cleared")
    }
    
    // MARK: - Safe Flutter Communication
    private func safeInvokeMethod(_ method: String, arguments: Any?) {
        guard MyLocationManager.isFlutterEngineActive, let channel = MyLocationManager.channel else {
            print("Flutter engine not active, skipping method: \(method)")
            return
        }
        
        DispatchQueue.main.async {
            channel.invokeMethod(method, arguments: arguments) { result in
                if let error = result as? FlutterError {
                    print("Flutter method \(method) failed: \(error.code) - \(error.message ?? "Unknown error")")
                    MyLocationManager.isFlutterEngineActive = false
                }
            }
        }
    }
    
    // MARK: - Location Storage and Sync
    private func processLocationUpdate(_ location: CLLocation) {
        let locationData = locationDict(from: location)
    
        if MyLocationManager.isFlutterEngineActive {
            safeInvokeMethod("locationUpdate", arguments: locationData)
        } else {
            localStorageManager.saveLocation(locationData)
        }
    }
    
    private func syncPendingLocations() {
        guard MyLocationManager.isFlutterEngineActive else { return }
        
        let pendingLocations = localStorageManager.getPendingLocations()
        if !pendingLocations.isEmpty {
            safeInvokeMethod("syncLocations", arguments: ["data": pendingLocations])
            localStorageManager.clearPendingLocations()
            print("Synced \(pendingLocations.count) pending locations to Flutter")
        }
    }
    
    // MARK: - Background App Refresh Setup
    private func setupBackgroundAppRefresh() {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
                self.handleBackgroundLocationTask(task: task as! BGAppRefreshTask)
            }
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
    
    @available(iOS 13.0, *)
    private func scheduleBackgroundLocationTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    // MARK: - App Restart Detection
    private func detectAppRestart() {
        let userDefaults = UserDefaults.standard
        let wasTrackingKey = "was_tracking_before_kill"
        
        if userDefaults.bool(forKey: wasTrackingKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.restartTrackingAfterKill()
            }
        }
    }
    
    private func restartTrackingAfterKill() {
        startTracking(mode: .alwaysOn)
    }
    
    private func setTrackingFlag(_ tracking: Bool) {
        UserDefaults.standard.set(tracking, forKey: "was_tracking_before_kill")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Background Task Management
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

    // MARK: - Flutter Method Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Flutter engine is active if we receive method calls
        MyLocationManager.isFlutterEngineActive = true
        
        switch call.method {
        case "startService":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = TrackingMode(rawValue: modeStr) {
                if let filter = args["filter"] as? Double {
                    distanceFilter = max(filter, 10.0)
                }
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

        case "updateDistanceFilter":
            if let args = call.arguments as? [String: Any], let filter = args["filter"] as? Double {
                updateDistanceFilter(max(filter, 10.0))
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing filter", details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Tracking Control
    private func startTracking(mode: TrackingMode) {
        trackingMode = mode
        let status = locationManager.authorizationStatus
        
        print("Starting persistent tracking mode: \(mode.rawValue)")
        setTrackingFlag(true)
        
        // Validate permissions
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

        // Configure based on mode
        switch mode {
        case .foreground:
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = distanceFilter
            locationManager.startUpdatingLocation()

        case .background:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = max(distanceFilter, 50.0)
            locationManager.startUpdatingLocation()

        case .significant:
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.startMonitoringSignificantLocationChanges()
            
        case .periodic:
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.startMonitoringSignificantLocationChanges()
            setupPeriodicRegionMonitoring()
            
        case .alwaysOn:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 50.0
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            setupPeriodicRegionMonitoring()
            startPersistentTimer()
            
            if #available(iOS 13.0, *) {
                scheduleBackgroundLocationTask()
            }
        }

        MyLocationManager.isTracking = true
        safeInvokeMethod("trackingStarted", arguments: [
            "mode": mode.rawValue,
            "filter": distanceFilter
        ])
    }

    private func stopTracking() {
        MyLocationManager.isTracking = false
        setTrackingFlag(false)
        
        persistentTimer?.invalidate()
        persistentTimer = nil
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = false
        
        stopPeriodicRegionMonitoring()
        endBackgroundTaskIfNeeded()
        
        safeInvokeMethod("trackingStopped", arguments: nil)
    }

    // MARK: - Permissions
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

    // MARK: - Helpers
    private func updateDistanceFilter(_ filter: Double) {
        distanceFilter = filter
        if MyLocationManager.isTracking && (trackingMode == .foreground || trackingMode == .background) {
            locationManager.distanceFilter = filter
        }
        safeInvokeMethod("distanceFilterUpdated", arguments: ["filter": filter])
    }

    private func isLocationAcceptable(_ location: CLLocation) -> Bool {
        let now = Date().timeIntervalSince1970

        if abs(now - location.timestamp.timeIntervalSince1970) > maxLocationAge {
            return false
        }

        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > accuracyThreshold {
            return false
        }

        let interval = (trackingMode == .foreground) ? 5.0 : minUpdateInterval
        if now - lastLocationTime < interval {
            return false
        }

        lastLocationTime = now
        return true
    }

    private func locationDict(from location: CLLocation) -> [String: Any] {
        return [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp),
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "speed": max(location.speed, 0),
            "provider": "CoreLocation",
            "trackingMode": trackingMode.rawValue,
            "persistent": trackingMode == .alwaysOn
        ]
    }

    // MARK: - Periodic Region Monitoring
    private func setupPeriodicRegionMonitoring() {
        locationManager.requestLocation()
    }
    
    private func createRegionAroundLocation(_ location: CLLocation) {
        stopPeriodicRegionMonitoring()
        
        regionIdentifierCounter += 1
        let regionIdentifier = "periodic_region_\(regionIdentifierCounter)"
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: periodicRadius,
            identifier: regionIdentifier
        )
        region.notifyOnEntry = false
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        currentRegion = region
        
        safeInvokeMethod("log", arguments: [
            "message": "Created periodic region at \(location.coordinate.latitude), \(location.coordinate.longitude)"
        ])
    }
    
    private func stopPeriodicRegionMonitoring() {
        if let region = currentRegion {
            locationManager.stopMonitoring(for: region)
            currentRegion = nil
        }
        
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix("periodic_region") {
                locationManager.stopMonitoring(for: region)
            }
        }
    }

    // MARK: - App Lifecycle
    @objc private func appDidEnterBackground() {
        guard MyLocationManager.isTracking else { return }

        switch trackingMode {
        case .foreground:
            locationManager.stopUpdatingLocation()
            safeInvokeMethod("log", arguments: [
                "message": "Foreground tracking paused in background"
            ])

        case .background, .alwaysOn:
            beginBackgroundTask()
            startPersistentTimer()
            safeInvokeMethod("log", arguments: [
                "message": "Persistent background tracking active"
            ])

        case .significant:
            safeInvokeMethod("log", arguments: [
                "message": "Significant location monitoring active in background"
            ])
            
        case .periodic:
            startPersistentTimer()
            safeInvokeMethod("log", arguments: [
                "message": "Periodic location monitoring active in background"
            ])
        }
    }

    @objc private func appWillEnterForeground() {
        // Flutter engine becomes active again
        MyLocationManager.isFlutterEngineActive = true
        
        endBackgroundTaskIfNeeded()
        
        // Sync any pending locations stored while Flutter was inactive
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.syncPendingLocations()
        }
        
        if MyLocationManager.isTracking && trackingMode == .foreground {
            locationManager.startUpdatingLocation()
            safeInvokeMethod("log", arguments: [
                "message": "Foreground tracking resumed"
            ])
        }
        
        detectAppRestart()
    }

    @objc private func appWillTerminate() {
        // Flutter engine will be destroyed
        MyLocationManager.isFlutterEngineActive = false
        
        if MyLocationManager.isTracking, let last = locationManager.location {
            let locationData = locationDict(from: last)
            localStorageManager.saveLocation(locationData, isTerminationLocation: true)
        }
        
        if MyLocationManager.isTracking && locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startMonitoringSignificantLocationChanges()
            if let location = locationManager.location {
                createRegionAroundLocation(location)
            }
        }
        
        endBackgroundTaskIfNeeded()
    }
}

// MARK: - CLLocationManagerDelegate
extension MyLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard MyLocationManager.isTracking else { return }

        if isLocationAcceptable(location) {
            processLocationUpdate(location)
            
            if trackingMode == .periodic {
                createRegionAroundLocation(location)
                regionIdentifierCounter += 1
            }
            
            if trackingMode == .background && backgroundTaskId != .invalid {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.endBackgroundTaskIfNeeded()
                }
            }
        }
        
        if trackingMode == .periodic && currentRegion == nil {
            createRegionAroundLocation(location)
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
            case .authorizedAlways:
                if trackingMode == .background || trackingMode == .significant || trackingMode == .periodic {
                    if trackingMode == .background {
                        manager.startUpdatingLocation()
                    }
                }
                
            case .authorizedWhenInUse:
                if trackingMode == .background || trackingMode == .significant || trackingMode == .periodic {
                    safeInvokeMethod("error", arguments: [
                        "message": "Permission downgraded - background tracking disabled"
                    ])
                    
                    manager.startUpdatingLocation()
                    stopTracking()
                }
    
            case .denied, .restricted:
                stopTracking()
                safeInvokeMethod("error", arguments: [
                    "message": "Location permission denied - tracking stopped"
                ])
                
            default:
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

// MARK: - Region Monitoring Delegate
extension MyLocationManager {
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard MyLocationManager.isTracking, trackingMode == .periodic else { return }
        guard region.identifier.hasPrefix("periodic_region") else { return }
        
        beginBackgroundTask()
        manager.requestLocation()
        
        safeInvokeMethod("log", arguments: [
            "message": "Exited periodic region - requesting new location"
        ])
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        safeInvokeMethod("error", arguments: [
            "message": "Region monitoring failed: \(error.localizedDescription)"
        ])
    }
}

// MARK: - Local Storage Manager
class LocalStorageManager {
    private let userDefaults = UserDefaults.standard
    private let pendingLocationsKey = "pending_locations"
    private let maxStoredLocations = 1000 // Prevent unlimited growth
    
    func saveLocation(_ locationData: [String: Any], isTerminationLocation: Bool = false) {
        var pendingLocations = getPendingLocations()
        
        // Add termination flag if needed
        var locationWithMetadata = locationData
        if isTerminationLocation {
            locationWithMetadata["isTerminationLocation"] = true
        }
        
        pendingLocations.append(locationWithMetadata)
        
        // Limit storage to prevent memory issues
        if pendingLocations.count > maxStoredLocations {
            pendingLocations = Array(pendingLocations.suffix(maxStoredLocations))
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: pendingLocations),
           let jsonString = String(data: data, encoding: .utf8) {
            userDefaults.set(jsonString, forKey: pendingLocationsKey)
            userDefaults.synchronize()
            print("Saved location to local storage. Total: \(pendingLocations.count)")
        } else {
            print("Failed to save location to local storage")
        }
    }
    
    func getPendingLocations() -> [[String: Any]] {
        guard let jsonString = userDefaults.string(forKey: pendingLocationsKey),
              let data = jsonString.data(using: .utf8),
              let locations = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return locations
    }
    
    func clearPendingLocations() {
        userDefaults.removeObject(forKey: pendingLocationsKey)
        userDefaults.synchronize()
        print("Cleared all pending locations from local storage")
    }
    
    func getPendingLocationCount() -> Int {
        return getPendingLocations().count
    }
}
