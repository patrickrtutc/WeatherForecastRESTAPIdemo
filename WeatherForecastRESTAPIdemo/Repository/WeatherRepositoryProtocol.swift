import Foundation
import OpenMeteoSdk
import Combine
import CoreLocation

protocol WeatherRepositoryProtocol {
    /// Get daily weather forecast
    func getDailyForecast(
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date,
        useMetric: Bool
    ) -> AnyPublisher<[WeatherApiResponse], APIError>
    
    /// Get hourly weather forecast
    func getHourlyForecast(
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date,
        useMetric: Bool
    ) -> AnyPublisher<[WeatherApiResponse], APIError>
    
    /// Get weather data for a specific location
    func getWeatherForLocation(
        location: CLLocationCoordinate2D,
        startDate: Date,
        endDate: Date,
        useMetric: Bool
    ) -> AnyPublisher<WeatherData, APIError>
    
    /// Save a location to favorites
    func saveLocationToFavorites(
        name: String,
        coordinate: CLLocationCoordinate2D
    ) -> AnyPublisher<Bool, Error>
    
    /// Get all favorite locations
    func getFavoriteLocations() -> AnyPublisher<[SavedLocation], Error>
    
    /// Remove a location from favorites
    func removeLocationFromFavorites(id: String) -> AnyPublisher<Bool, Error>
}

/// Structure to represent a saved location
struct SavedLocation: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let dateAdded: Date
    
    init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double, dateAdded: Date = Date()) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.dateAdded = dateAdded
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
} 