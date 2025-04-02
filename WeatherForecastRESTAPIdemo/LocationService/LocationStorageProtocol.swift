import Foundation
import Combine

protocol LocationStorageProtocol {
    /// Save a location to the storage
    func saveLocation(_ location: SavedLocation) -> AnyPublisher<Bool, Error>
    
    /// Get all saved locations
    func getLocations() -> AnyPublisher<[SavedLocation], Error>
    
    /// Remove a location from storage
    func removeLocation(id: String) -> AnyPublisher<Bool, Error>
} 