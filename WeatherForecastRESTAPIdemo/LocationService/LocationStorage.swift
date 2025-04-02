import Foundation
import Combine

class LocationStorage: LocationStorageProtocol {
    private let userDefaults: UserDefaults
    private let locationsKey = "saved_locations"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveLocation(_ location: SavedLocation) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            do {
                var locations = self.getSavedLocations()
                
                // Check if location already exists
                if let index = locations.firstIndex(where: { $0.id == location.id }) {
                    locations[index] = location
                } else {
                    locations.append(location)
                }
                
                // Sort by date added (newest first)
                locations.sort { $0.dateAdded > $1.dateAdded }
                
                // Save to UserDefaults
                let data = try JSONEncoder().encode(locations)
                self.userDefaults.set(data, forKey: self.locationsKey)
                
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getLocations() -> AnyPublisher<[SavedLocation], Error> {
        return Future<[SavedLocation], Error> { promise in
                let locations = self.getSavedLocations()
                promise(.success(locations))
        }
        .eraseToAnyPublisher()
    }
    
    func removeLocation(id: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            do {
                var locations = self.getSavedLocations()
                locations.removeAll { $0.id == id }
                
                // Save to UserDefaults
                let data = try JSONEncoder().encode(locations)
                self.userDefaults.set(data, forKey: self.locationsKey)
                
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func getSavedLocations() -> [SavedLocation] {
        guard let data = userDefaults.data(forKey: locationsKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([SavedLocation].self, from: data)
        } catch {
            print("Error decoding saved locations: \(error)")
            return []
        }
    }
} 
