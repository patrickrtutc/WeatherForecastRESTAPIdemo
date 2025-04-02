import Foundation
import OpenMeteoSdk
import Combine
import CoreLocation

class WeatherRepository: WeatherRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let cacheManager: CacheManager
    private let locationStorage: LocationStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    private let session = URLSession.shared
    
    init(
        apiClient: APIClientProtocol = APIClient(),
        cacheManager: CacheManager = CacheManager.shared,
        locationStorage: LocationStorageProtocol = LocationStorage()
    ) {
        self.apiClient = apiClient
        self.cacheManager = cacheManager
        self.locationStorage = locationStorage
    }
    
    func getDailyForecast(
        latitude: Double,
        longitude: Double,
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        useMetric: Bool = false
    ) -> AnyPublisher<[WeatherApiResponse], APIError> {
        let cacheKey = "dailyForecast-\(latitude)-\(longitude)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)-\(useMetric)"
        
        // Check cache first
        if cacheManager.get(forKey: cacheKey) is Data {
            // We'll skip cache here for now since we're changing the approach
        }
        
        // Create the URL for fetching
        let urlString = APIConfiguration.WeatherAPI.getDailyForecastURL(
            latitude: latitude,
            longitude: longitude,
            startDate: startDate,
            endDate: endDate,
            useMetric: useMetric
        )
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Bridge async/await to Combine
        return Future<[WeatherApiResponse], APIError> { promise in
            Task {
                do {
                    let responses = try await WeatherApiResponse.fetch(url: url)
                    promise(.success(responses))
                } catch {
                    promise(.failure(APIError.networkError(error.localizedDescription)))
                }
            }
        }
        .handleEvents(receiveOutput: { responses in
            // Store the responses in cache if needed (not the raw data anymore)
            // For simplicity, we're not caching the responses here
        })
        .eraseToAnyPublisher()
    }
    
    func getHourlyForecast(
        latitude: Double,
        longitude: Double,
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        useMetric: Bool = false
    ) -> AnyPublisher<[WeatherApiResponse], APIError> {
        let cacheKey = "hourlyForecast-\(latitude)-\(longitude)-\(startDate.timeIntervalSince1970)-\(endDate.timeIntervalSince1970)-\(useMetric)"
        
        // Check cache first
        if cacheManager.get(forKey: cacheKey) is Data {
            // We'll skip cache here for now since we're changing the approach
        }
        
        // Create the URL for fetching
        let urlString = APIConfiguration.WeatherAPI.getHourlyForecastURL(
            latitude: latitude,
            longitude: longitude,
            startDate: startDate,
            endDate: endDate,
            useMetric: useMetric
        )
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Bridge async/await to Combine
        return Future<[WeatherApiResponse], APIError> { promise in
            Task {
                do {
                    let responses = try await WeatherApiResponse.fetch(url: url)
                    promise(.success(responses))
                } catch {
                    promise(.failure(APIError.networkError(error.localizedDescription)))
                }
            }
        }
        .handleEvents(receiveOutput: { responses in
            // Store the responses in cache if needed (not the raw data anymore)
            // For simplicity, we're not caching the responses here
        })
        .eraseToAnyPublisher()
    }
    
    func getWeatherForLocation(
        location: CLLocationCoordinate2D,
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        useMetric: Bool = false
    ) -> AnyPublisher<WeatherData, APIError> {
        return getDailyForecast(
            latitude: location.latitude,
            longitude: location.longitude,
            startDate: startDate,
            endDate: endDate,
            useMetric: useMetric
        )
        .tryMap { responses -> WeatherData in
            guard let response = responses.first else {
                throw APIError.noData
            }
            
            let daily = response.daily!
            let utcOffsetSeconds = response.utcOffsetSeconds
            
            // Map API response to WeatherData model
            return WeatherData(
                daily: .init(
                    time: daily.getDateTime(offset: utcOffsetSeconds),
                    weatherCode: daily.variables(at: 0)!.values,
                    temperature2mMax: daily.variables(at: 1)!.values,
                    temperature2mMin: daily.variables(at: 2)!.values
                )
            )
        }
        .mapError { error in
            if let apiError = error as? APIError {
                return apiError
            }
            return APIError.decodingFailed
        }
        .eraseToAnyPublisher()
    }
    
    func saveLocationToFavorites(name: String, coordinate: CLLocationCoordinate2D) -> AnyPublisher<Bool, Error> {
        let location = SavedLocation(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        return locationStorage.saveLocation(location)
    }
    
    func getFavoriteLocations() -> AnyPublisher<[SavedLocation], Error> {
        return locationStorage.getLocations()
    }
    
    func removeLocationFromFavorites(id: String) -> AnyPublisher<Bool, Error> {
        return locationStorage.removeLocation(id: id)
    }
} 
