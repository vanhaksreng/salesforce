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

    // Tracking config
    private var trackingMode: TrackingMode = .foreground
    private var distanceFilter: Double = 10.0 // Reasonable default for battery life
    private let accuracyThreshold: CLLocationDistance = 100.0 // More lenient for background
    private var lastLocationTime: TimeInterval = 0
    private let minUpdateInterval: TimeInterval = 30.0 // Longer interval for background
    private let maxLocationAge: TimeInterval = 60.0

    // Background task management
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private let backgroundTaskTimeout: TimeInterval = 25.0 // Well under 30 seconds
    private var persistentTimer: Timer?
    
    // Background App Refresh registration
    private let backgroundTaskIdentifier = "com.clearviewerp.salesforce.location"
    
    // App restart detection
    private var appKilledFlag: Bool = false
    
    // Periodic mode - region monitoring for scheduled-like behavior
    private var currentRegion: CLCircularRegion?
    private let periodicRadius: CLLocationDistance = 100.0 // 200m radius
    private var regionIdentifierCounter = 0

    // MARK: - Plugin registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "com.clearviewerp.salesforce/background_service", binaryMessenger: registrar.messenger())
        let instance = MyLocationManager()
        registrar.addMethodCallDelegate(instance, channel: channel!)
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
    }
    
    // MARK: - Background App Refresh Setup (Critical for persistence)
    private func setupBackgroundAppRefresh() {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
                self.handleBackgroundLocationTask(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func handleBackgroundLocationTask(task: BGAppRefreshTask) {
        // Schedule next background refresh
        scheduleBackgroundLocationTask()
        
        // Perform location update
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Get location update and process
        beginBackgroundTask()
        locationManager.requestLocation()
        
        // Give some time for location to be received
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.endBackgroundTaskIfNeeded()
            task.setTaskCompleted(success: true)
        }
    }
    
    @available(iOS 13.0, *)
    private func scheduleBackgroundLocationTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \\(error)")
        }
    }
    
    // MARK: - App Restart Detection
    private func detectAppRestart() {
        let userDefaults = UserDefaults.standard
        let wasTrackingKey = "was_tracking_before_kill"
        
        if userDefaults.bool(forKey: wasTrackingKey) {
            // App was killed while tracking - restart automatically
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.restartTrackingAfterKill()
            }
        }
    }
    
    private func restartTrackingAfterKill() {
        MyLocationManager.channel?.invokeMethod("appRestartedAfterKill", arguments: [
            "message": "Location tracking resumed after app restart"
        ])
        
        // Restart with persistent mode
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
        
        // Force location update
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
        
        // Schedule background app refresh if available
        if #available(iOS 13.0, *) {
            scheduleBackgroundLocationTask()
        }
    }

    // MARK: - Flutter Method Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startService":
            if let args = call.arguments as? [String: Any],
               let modeStr = args["mode"] as? String,
               let mode = TrackingMode(rawValue: modeStr) {
                if let filter = args["filter"] as? Double {
                    distanceFilter = max(filter, 10.0) // Minimum 10m for battery life
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

        case "updateDistanceFilter":
            if let args = call.arguments as? [String: Any], let filter = args["filter"] as? Double {
                updateDistanceFilter(max(filter, 10.0)) // Enforce minimum
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
        
        print("Starting persistent tracking mode: \\(mode.rawValue)")
        setTrackingFlag(true)
        
        // Validate permissions
        switch mode {
        case .background, .significant, .periodic, .alwaysOn:
            guard status == .authorizedAlways else {
                MyLocationManager.channel?.invokeMethod("error", arguments: [
                    "message": "\(mode.rawValue) tracking requires 'Always' location permission"
                ])
                return
            }
        case .foreground:
            guard status == .authorizedAlways || status == .authorizedWhenInUse else {
                MyLocationManager.channel?.invokeMethod("error", arguments: [
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
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Battery friendly
            locationManager.distanceFilter = max(distanceFilter, 50.0) // Minimum 50m for background
            locationManager.startUpdatingLocation()

        case .significant:
            // Most battery efficient and reliable for background
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.startMonitoringSignificantLocationChanges()
            
        case .periodic:
            // Hybrid approach: significant changes + region monitoring for more frequent updates
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.startMonitoringSignificantLocationChanges()
            setupPeriodicRegionMonitoring()
            
        case .alwaysOn:
            // MOST PERSISTENT MODE - Combines everything
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 50.0
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            setupPeriodicRegionMonitoring()
            startPersistentTimer()
            
            // Schedule background app refresh
            if #available(iOS 13.0, *) {
                scheduleBackgroundLocationTask()
            }
        }

        MyLocationManager.isTracking = true
        MyLocationManager.channel?.invokeMethod("trackingStarted", arguments: [
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
        
        // Stop region monitoring
        stopPeriodicRegionMonitoring()
        endBackgroundTaskIfNeeded()
        
        MyLocationManager.channel?.invokeMethod("trackingStopped", arguments: nil)
    }

    // MARK: - Permissions
    private func requestPermissions(for mode: TrackingMode, completion: @escaping (Bool) -> Void) {
        switch mode {
        case .background, .significant, .periodic, .alwaysOn:
            locationManager.requestAlwaysAuthorization()
        case .foreground:
            locationManager.requestWhenInUseAuthorization()
        }

        // Wait for user response
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
        MyLocationManager.channel?.invokeMethod("distanceFilterUpdated", arguments: ["filter": filter])
    }

    private func isLocationAcceptable(_ location: CLLocation) -> Bool {
        let now = Date().timeIntervalSince1970

        // Check age
        if abs(now - location.timestamp.timeIntervalSince1970) > maxLocationAge {
            return false
        }

        // Check accuracy
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > accuracyThreshold {
            return false
        }

        // Throttle updates (more lenient for background modes)
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

    // MARK: - Periodic Region Monitoring (Scheduled-like behavior)
    private func setupPeriodicRegionMonitoring() {
        locationManager.requestLocation()
    }
    
    private func createRegionAroundLocation(_ location: CLLocation) {
        // Stop monitoring previous region
        stopPeriodicRegionMonitoring()
        
        regionIdentifierCounter += 1
        let regionIdentifier = "periodic_region_\(regionIdentifierCounter)"
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: periodicRadius,
            identifier: regionIdentifier
        )
        region.notifyOnEntry = false
        region.notifyOnExit = true // Trigger when user leaves the area
        
        locationManager.startMonitoring(for: region)
        currentRegion = region
        
        MyLocationManager.channel?.invokeMethod("log", arguments: [
            "message": "Created periodic region at \(location.coordinate.latitude), \(location.coordinate.longitude)"
        ])
    }
    
    private func stopPeriodicRegionMonitoring() {
        if let region = currentRegion {
            locationManager.stopMonitoring(for: region)
            currentRegion = nil
        }
        
        // Stop monitoring all regions if needed
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
            // Stop foreground tracking in background
            locationManager.stopUpdatingLocation()
            MyLocationManager.channel?.invokeMethod("log", arguments: [
                "message": "Foreground tracking paused in background"
            ])

        case .background, .alwaysOn:
            // Continue background tracking if permitted
            // if locationManager.authorizationStatus == .authorizedAlways {
            //     beginBackgroundTask()
            //     MyLocationManager.channel?.invokeMethod("log", arguments: [
            //         "message": "Background tracking active"
            //     ])
            // }
            beginBackgroundTask()
            startPersistentTimer()
            MyLocationManager.channel?.invokeMethod("log", arguments: [
                "message": "Persistent background tracking active"
            ])

        case .significant:
            // Significant location changes work automatically in background
            MyLocationManager.channel?.invokeMethod("log", arguments: [
                "message": "Significant location monitoring active in background"
            ])
            
        case .periodic:
            startPersistentTimer()
            MyLocationManager.channel?.invokeMethod("log", arguments: [
                "message": "Periodic location monitoring active in background"
            ])
        }
    }

    @objc private func appWillEnterForeground() {
        endBackgroundTaskIfNeeded() // Clean up background task
        
        if MyLocationManager.isTracking && trackingMode == .foreground {
            // Restart foreground tracking
            locationManager.startUpdatingLocation()
            MyLocationManager.channel?.invokeMethod("log", arguments: [
                "message": "Foreground tracking resumed"
            ])
        }
        
        // Check if we're continuing from a kill
        detectAppRestart()
    }

    @objc private func appWillTerminate() {
        if MyLocationManager.isTracking, let last = locationManager.location {
            MyLocationManager.channel?.invokeMethod("terminationLocation", arguments: locationDict(from: last))
        }
        
        // Ensure we're in most persistent mode possible
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
            let locationData = locationDict(from: location)
            MyLocationManager.channel?.invokeMethod("locationUpdate", arguments: locationData)
            
            // For periodic mode, create a new region around this location
            if trackingMode == .periodic {
                createRegionAroundLocation(location)
                regionIdentifierCounter += 1
            }
            
            // For background modes, end background task after sending location
            if trackingMode == .background && backgroundTaskId != .invalid {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.endBackgroundTaskIfNeeded()
                }
            }
        }
        
        // For periodic mode during setup, create initial region
        if trackingMode == .periodic && currentRegion == nil {
            createRegionAroundLocation(location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MyLocationManager.channel?.invokeMethod("error", arguments: [
            "message": "Location error: \(error.localizedDescription)"
        ])
        
        // End background task on error
        endBackgroundTaskIfNeeded()
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        MyLocationManager.channel?.invokeMethod("permissionChanged", arguments: [
            "status": authorizationStatusString(status)
        ])
        
        // Handle permission changes during tracking
        if MyLocationManager.isTracking {
            switch status {
            case .authorizedAlways:
                if trackingMode == .background || trackingMode == .significant || trackingMode == .periodic {
                    // Can continue background tracking
                    if trackingMode == .background {
                        manager.startUpdatingLocation()
                    }
                }
                
            case .authorizedWhenInUse:
                if trackingMode == .background || trackingMode == .significant || trackingMode == .periodic {
                    MyLocationManager.channel?.invokeMethod("error", arguments: [
                        "message": "Permission downgraded - background tracking disabled"
                    ])
                    
                    manager.startUpdatingLocation()
                    stopTracking()
                }
    
            case .denied, .restricted:
                stopTracking()
                MyLocationManager.channel?.invokeMethod("error", arguments: [
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
        
        // User left the region, get new location and create new region
        beginBackgroundTask()
        manager.requestLocation()
        
        MyLocationManager.channel?.invokeMethod("log", arguments: [
            "message": "Exited periodic region - requesting new location"
        ])
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        MyLocationManager.channel?.invokeMethod("error", arguments: [
            "message": "Region monitoring failed: \(error.localizedDescription)"
        ])
    }
}
