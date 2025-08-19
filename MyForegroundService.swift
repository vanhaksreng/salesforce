import Flutter
import UIKit
import CoreLocation
import BackgroundTasks

@objc public class MyForegroundService: NSObject, FlutterPlugin {
    private let locationManager = CLLocationManager()
    private static var channel: FlutterMethodChannel?
    private static var isServiceRunning = false
    private var isTerminating = false
    private var currentLocationResult: FlutterResult?
    private var lastLocationTime: TimeInterval = 0
    private var consecutiveAccurateReadings = 0
    private let accuracyThreshold: CLLocationDistance = 30.0 // meters
    private var lastAccuracy: CLLocationAccuracy = CLLocationAccuracy.greatestFiniteMagnitude
    private var distanceFilter: Double = 5.0
    private let minUpdateInterval: TimeInterval = 1.0 // seconds
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(
            name: "com.clearviewerp.salesforce/background_service",
            binaryMessenger: registrar.messenger()
        )
        let instance = MyForegroundService()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    override init() {
        super.init()
        setupLocationManager()
        setupBackgroundTasks()
        setupTerminationHandler()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        
        // Maximum accuracy settings
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // Highest possible accuracy
        locationManager.distanceFilter = kCLDistanceFilterNone // No distance filtering initially
        
        // Background location settings
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false // Never pause
        locationManager.activityType = .otherNavigation // Best for general tracking
        
        // iOS 14+ accuracy settings
        if #available(iOS 14.0, *) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        // Request permissions if not determined
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        // Start updates immediately for better accuracy
        if locationManager.authorizationStatus == .authorizedAlways ||
           locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        
        MyForegroundService.channel?.invokeMethod("log", arguments: ["message": "Enhanced iOS location manager configured"])
    }

    private func setupBackgroundTasks() {
        if #available(iOS 13.0, *) {
            // Register for background app refresh
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.clearviewerp.salesforce.background-sync",
                using: nil
            ) { task in
                self.handleBackgroundSync(task: task as! BGAppRefreshTask)
            }
            
            // Register for background processing (longer running tasks)
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.clearviewerp.salesforce.background-location",
                using: nil
            ) { task in
                self.handleBackgroundLocation(task: task as! BGProcessingTask)
            }
        }
    }

    private func setupTerminationHandler() {
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
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if isTerminating && call.method != "stopService" {
            result(FlutterError(code: "TERMINATING", message: "Service is terminating", details: nil))
            return
        }
    
        switch call.method {
        case "startService":
            if let args = call.arguments as? [String: Any] {
                if let filter = args["filter"] as? Double {
                    distanceFilter = filter
                    locationManager.distanceFilter = filter
                }
            }
            startBackgroundService()
            result(true)

        case "stopService":
            stopBackgroundService()
            result(true)

        case "getCurrentLocation":
            if let args = call.arguments as? [String: Any],
               let timeout = args["timeout"] as? Int {
                getCurrentLocation(timeout: timeout, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
            }

        case "checkPermissions":
            result(getPermissionStatus())

        case "requestPermissions":
            requestLocationPermissions { granted in
                result(granted)
            }
            
        case "updateDistanceFilter":
            if let args = call.arguments as? [String: Any],
               let filter = args["filter"] as? Double {
                updateDistanceFilter(filter)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing filter argument", details: nil))
            }
            
        case "getAccuracyStats":
            result([
                "lastAccuracy": lastAccuracy,
                "consecutiveAccurateReadings": consecutiveAccurateReadings,
                "accuracyThreshold": accuracyThreshold,
                "currentFilter": distanceFilter
            ])

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startBackgroundService() {
        if isTerminating {
            MyForegroundService.channel?.invokeMethod("error", arguments: ["message": "Service is terminating"])
            return
        }
    
        guard locationManager.authorizationStatus == .authorizedAlways else {
            MyForegroundService.channel?.invokeMethod("error", arguments: ["message": "Location permission not granted for background use"])
            return
        }
        
        MyForegroundService.isServiceRunning = true
        consecutiveAccurateReadings = 0
        
        // Configure for maximum accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 0 // Get all updates initially for accuracy assessment
        
        // Start all available location services
        locationManager.startUpdatingLocation()
        
        // Use significant location changes as backup
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        // Schedule background tasks
        if #available(iOS 13.0, *) {
            scheduleBackgroundSync()
            scheduleBackgroundLocation()
        }
        
        MyForegroundService.channel?.invokeMethod("log", arguments: [
            "message": "Enhanced background service started",
            "accuracy": locationManager.desiredAccuracy,
            "filter": distanceFilter
        ])
    }

    private func stopBackgroundService() {
        MyForegroundService.isServiceRunning = false
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        MyForegroundService.channel?.invokeMethod("log", arguments: ["message": "Enhanced background service stopped"])
    }

    private func updateDistanceFilter(_ newFilter: Double) {
        distanceFilter = newFilter
        // Apply distance filter after we have good accuracy
        if consecutiveAccurateReadings >= 3 {
            locationManager.distanceFilter = newFilter
        }
        MyForegroundService.channel?.invokeMethod("log", arguments: [
            "message": "Distance filter updated to \(newFilter)m"
        ])
    }

    private func getCurrentLocation(timeout: Int, result: @escaping FlutterResult) {
        guard locationManager.authorizationStatus == .authorizedAlways ||
              locationManager.authorizationStatus == .authorizedWhenInUse else {
            result(FlutterError(code: "PERMISSION_DENIED", message: "Location permissions not granted", details: nil))
            return
        }

        // Store result for async handling
        currentLocationResult = result

        // Check if we have a recent, accurate location
        if let location = locationManager.location,
           -location.timestamp.timeIntervalSinceNow < 10.0,
           location.horizontalAccuracy <= accuracyThreshold && location.horizontalAccuracy > 0 {
            sendLocationResult(location)
            currentLocationResult = nil
            return
        }

        // Configure for single high-accuracy request
        let originalAccuracy = locationManager.desiredAccuracy
        let originalFilter = locationManager.distanceFilter
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // Request a single update
        locationManager.requestLocation()

        // Timeout handler with cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
            if self.currentLocationResult != nil {
                // Restore original settings
                self.locationManager.desiredAccuracy = originalAccuracy
                self.locationManager.distanceFilter = originalFilter
                
                self.currentLocationResult?(FlutterError(
                    code: "TIMEOUT",
                    message: "High accuracy location request timed out after \(timeout) seconds",
                    details: nil
                ))
                self.currentLocationResult = nil
            }
        }
    }

    @available(iOS 13.0, *)
    private func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.clearviewerp.salesforce.background-sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // 2 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            MyForegroundService.channel?.invokeMethod("log", arguments: [
                "message": "BGTaskScheduler: background-sync scheduled successfully"
            ])
        } catch {
            MyForegroundService.channel?.invokeMethod("error", arguments: [
                "message": "Could not schedule background sync: \(error.localizedDescription)"
            ])
        }
    }
    
    @available(iOS 13.0, *)
    private func scheduleBackgroundLocation() {
        let request = BGProcessingTaskRequest(identifier: "com.clearviewerp.salesforce.background-location")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // 5 minutes
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            MyForegroundService.channel?.invokeMethod("log", arguments: [
                "message": "BGTaskScheduler: background-location scheduled successfully"
            ])
        } catch {
            MyForegroundService.channel?.invokeMethod("error", arguments: [
                "message": "Could not schedule background location: \(error.localizedDescription)"
            ])
        }
    }

    @available(iOS 13.0, *)
    private func handleBackgroundSync(task: BGAppRefreshTask) {
        scheduleBackgroundSync() // Reschedule for next time
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Trigger a location update if service is running
        if MyForegroundService.isServiceRunning {
            locationManager.requestLocation()
        }
        
        DispatchQueue.main.async {
            MyForegroundService.channel?.invokeMethod("backgroundSync", arguments: [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "type": "app_refresh",
                "isServiceRunning": MyForegroundService.isServiceRunning
            ])
            task.setTaskCompleted(success: true)
        }
    }
    
    @available(iOS 13.0, *)
    private func handleBackgroundLocation(task: BGProcessingTask) {
        scheduleBackgroundLocation() // Reschedule for next time
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform background location processing
        if MyForegroundService.isServiceRunning {
            // Request multiple location updates for better accuracy
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(i * 2)) {
                    self.locationManager.requestLocation()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            MyForegroundService.channel?.invokeMethod("backgroundSync", arguments: [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "type": "background_processing",
                "isServiceRunning": MyForegroundService.isServiceRunning
            ])
            task.setTaskCompleted(success: true)
        }
    }

    @objc private func appDidEnterBackground() {
        if MyForegroundService.isServiceRunning {
            // Ensure location updates continue in background
            locationManager.startUpdatingLocation()
            if #available(iOS 13.0, *) {
                scheduleBackgroundSync()
                scheduleBackgroundLocation()
            }
        }
    }

    @objc private func appWillTerminate() {
        isTerminating = true
        
        if MyForegroundService.isServiceRunning {
            DispatchQueue.main.async {
                MyForegroundService.channel?.invokeMethod("terminationSync", arguments: [
                    "lastAccuracy": self.lastAccuracy,
                    "consecutiveAccurateReadings": self.consecutiveAccurateReadings
                ])
                
                // Send last known accurate location if available
                if let lastLocation = self.locationManager.location,
                   -lastLocation.timestamp.timeIntervalSinceNow < 30.0,
                   lastLocation.horizontalAccuracy <= self.accuracyThreshold,
                   lastLocation.horizontalAccuracy > 0 {
                    self.sendLocationUpdate(lastLocation, isTerminating: true)
                }
            }
        }
    }

    private func requestLocationPermissions(completion: @escaping (Bool) -> Void) {
        guard locationManager.authorizationStatus != .authorizedAlways else {
            completion(true)
            return
        }
        
        // Request always authorization for background tracking
        locationManager.requestAlwaysAuthorization()
        
        // Check status change after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let granted = self.locationManager.authorizationStatus == .authorizedAlways
            completion(granted)
            
            // Send permission status update to Dart
            let permissions = self.getPermissionStatus()
            MyForegroundService.channel?.invokeMethod("permissionStatus", arguments: permissions)
        }
    }

    private func getPermissionStatus() -> [String: Bool] {
        let status = locationManager.authorizationStatus
        return [
            "fine": status == .authorizedAlways || status == .authorizedWhenInUse,
            "coarse": status == .authorizedAlways || status == .authorizedWhenInUse,
            "background": status == .authorizedAlways,
            "canTrackForeground": status == .authorizedAlways || status == .authorizedWhenInUse,
            "canTrackBackground": status == .authorizedAlways
        ]
    }

    private func isLocationAccurate(_ location: CLLocation) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        
        // Check if location is too old (more than 30 seconds)
        if abs(currentTime - location.timestamp.timeIntervalSince1970) > 30.0 {
            return false
        }
        
        // Check horizontal accuracy (must be positive and within threshold)
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > accuracyThreshold {
            return false
        }
        
        // Check minimum time interval between updates
        if currentTime - lastLocationTime < minUpdateInterval {
            return false
        }
        
        // Update tracking variables
        lastLocationTime = currentTime
        lastAccuracy = location.horizontalAccuracy
        
        // Track consecutive accurate readings
        if location.horizontalAccuracy <= accuracyThreshold {
            consecutiveAccurateReadings += 1
            
            // After getting several accurate readings, apply distance filter
            if consecutiveAccurateReadings == 3 && distanceFilter > 0 {
                locationManager.distanceFilter = distanceFilter
            }
        } else {
            consecutiveAccurateReadings = 0
            // Remove distance filter to get more frequent updates for accuracy
            locationManager.distanceFilter = kCLDistanceFilterNone
        }
        
        return true
    }

    private func sendLocationResult(_ location: CLLocation) {
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp),
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "speed": location.speed >= 0 ? location.speed : 0,
            "isBackground": !UIApplication.shared.applicationState.isActive,
            "consecutiveAccurateReadings": consecutiveAccurateReadings,
            "provider": "CoreLocation"
        ]
        
        currentLocationResult?(locationData)
    }
    
    private func sendLocationUpdate(_ location: CLLocation, isTerminating: Bool = false) {
        guard !isTerminating || currentLocationResult != nil else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp),
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "speed": location.speed >= 0 ? location.speed : 0,
            "isBackground": !UIApplication.shared.applicationState.isActive,
            "isTerminating": isTerminating,
            "consecutiveAccurateReadings": consecutiveAccurateReadings,
            "provider": "CoreLocation"
        ]
        
        MyForegroundService.channel?.invokeMethod("locationUpdate", arguments: locationData)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopBackgroundService()
    }
}

extension MyForegroundService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Handle single location requests (getCurrentLocation)
        if let result = currentLocationResult {
            if isLocationAccurate(location) {
                sendLocationResult(location)
                currentLocationResult = nil
            }
            return
        }
        
        // Handle continuous tracking - allow updates during termination for final sync
        guard MyForegroundService.isServiceRunning || isTerminating else { return }

        if isLocationAccurate(location) {
            sendLocationUpdate(location, isTerminating: isTerminating)
        } else {
            // Log poor accuracy for debugging
            MyForegroundService.channel?.invokeMethod("log", arguments: [
                "message": "Location filtered - accuracy: \(String(format: "%.1f", location.horizontalAccuracy))m (threshold: \(accuracyThreshold)m)"
            ])
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let result = currentLocationResult {
            result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            currentLocationResult = nil
        }
        
        MyForegroundService.channel?.invokeMethod("error", arguments: [
            "message": "Location error: \(error.localizedDescription)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        // Reset accuracy tracking on error
        consecutiveAccurateReadings = 0
        locationManager.distanceFilter = kCLDistanceFilterNone
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let permissions = getPermissionStatus()
        MyForegroundService.channel?.invokeMethod("permissionStatus", arguments: permissions)
        
        switch status {
        case .authorizedAlways:
            if MyForegroundService.isServiceRunning {
                manager.startUpdatingLocation()
            }
        case .authorizedWhenInUse:
            MyForegroundService.channel?.invokeMethod("warning", arguments: [
                "message": "Only foreground location permission granted. Background tracking limited."
            ])
        case .denied, .restricted:
            if MyForegroundService.isServiceRunning {
                stopBackgroundService()
            }
            MyForegroundService.channel?.invokeMethod("error", arguments: [
                "message": "Location permission denied. GPS tracking disabled."
            ])
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

private extension UIApplication.State {
    var isActive: Bool { self == .active }
}
