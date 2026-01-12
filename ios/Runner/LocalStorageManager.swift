import Foundation
import CoreLocation

class LocalStorageManager {
    private let defaultFileName = "locations.json"
    private let maxStoredLocations = 10000
    private var locationBuffer: [[String: Any]] = []
    private let maxBufferSize = 10
    
    private func getDocumentsDirectory() -> URL {
       let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
       return paths[0]
    }
    
    private func getLocationFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent(defaultFileName)
    }
    
    private func loadExistingLocations() -> [String: Any] {
        let fileURL = getLocationFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return createEmptyLocationFile()
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
        } catch {
            // print("Error loading location file: \(error)")
        }
        
        return createEmptyLocationFile()
    }
    
    private func createEmptyLocationFile() -> [String: Any] {
        return [
            "version": "1.0",
            "created": ISO8601DateFormatter().string(from: Date()),
            "locations": [],
            "count": 0
        ]
    }
    
    private func saveLocationsToFile(_ locationData: [String: Any]) {
        let fileURL = getLocationFileURL()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
        } catch {
            // print("Error saving location file: \(error)")
        }
    }
    
    func saveLocation(_ locationData: [String: Any], isTerminationLocation: Bool = false) {
        var locationWithMetadata = locationData
        if isTerminationLocation {
            locationWithMetadata["isTerminationLocation"] = true
        }
        locationWithMetadata["source"] = "ios_native"
        
        locationBuffer.append(locationWithMetadata)
        
        if locationBuffer.count >= maxBufferSize {
            saveBufferedLocations()
        }
    }
    
    private func saveBufferedLocations() {
        guard !locationBuffer.isEmpty else { return }
        
        var locationData = loadExistingLocations()
        
        if var existingLocations = locationData["locations"] as? [[String: Any]] {
            existingLocations.append(contentsOf: locationBuffer)
            
            // Keep only last maxStoredLocations
            if existingLocations.count > maxStoredLocations {
                existingLocations = Array(existingLocations.suffix(maxStoredLocations))
            }
            
            locationData["locations"] = existingLocations
            locationData["updated"] = ISO8601DateFormatter().string(from: Date())
            locationData["count"] = existingLocations.count
            
            saveLocationsToFile(locationData)
        }
        
        locationBuffer.removeAll()
    }
    
    func getPendingLocations() -> [[String: Any]] {
        saveBufferedLocations()
        
        let locationData = loadExistingLocations()
        return (locationData["locations"] as? [[String: Any]]) ?? []
    }
    
    func clearPendingLocations() {
        let emptyData = createEmptyLocationFile()
        saveLocationsToFile(emptyData)
        locationBuffer.removeAll()
    }
    
    func getPendingLocationCount() -> Int {
        return getPendingLocations().count + locationBuffer.count
    }
}
