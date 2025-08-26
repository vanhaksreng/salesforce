import CoreLocation

class KalmanLocationFilter {
    private var isInitialized = false
    private var latitude: Double = 0
    private var longitude: Double = 0
    private var variance: Double = 0
    
    // Activity-specific noise parameters
    private var processNoise: Double {
        switch activityType {
        case .stationary: return 0.05 // Low movement expected
        case .walking: return 0.25   // Moderate movement
        case .driving: return 0.5    // High movement
        case .unknown: return 0.125  // Default
        }
    }
    
    private var measurementNoise: Double {
        switch activityType {
        case .stationary: return 0.75 // Trust measurements less
        case .walking: return 0.5    // Balanced trust
        case .driving: return 0.3    // Trust measurements more
        case .unknown: return 0.5    // Default
        }
    }
    
    private var activityType: MyLocationManager.DetectedActivity = .unknown
    
    func setActivityType(_ activity: MyLocationManager.DetectedActivity) {
        self.activityType = activity
    }
    
    func filter(location: CLLocation) -> CLLocation {
        let accuracy = max(location.horizontalAccuracy, 1.0)
        
        if !isInitialized {
            initialize(with: location)
            return location
        }
        
        variance += processNoise
        let gain = variance / (variance + accuracy * accuracy)
        
        latitude += gain * (location.coordinate.latitude - latitude)
        longitude += gain * (location.coordinate.longitude - longitude)
        
        variance = (1 - gain) * variance
        
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )
    }
    
    private func initialize(with location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        variance = location.horizontalAccuracy * location.horizontalAccuracy
        isInitialized = true
    }
    
    func reset() {
        isInitialized = false
        variance = 0
        activityType = .unknown
    }
}