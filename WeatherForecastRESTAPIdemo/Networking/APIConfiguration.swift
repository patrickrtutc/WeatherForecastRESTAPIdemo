import Foundation

/// Environment for API connections
enum APIEnvironment {
    case development
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://api.open-meteo.com")!
        case .staging:
            return URL(string: "https://api.open-meteo.com")!
        case .production:
            return URL(string: "https://api.open-meteo.com")!
        }
    }
}

/// Configuration for the API client
struct APIConfiguration {
    static var environment: APIEnvironment = .production
    static var apiKey: String?
    
    // Default parameters used in weather requests
    struct WeatherAPI {
        static let weatherPath = "/v1/forecast"
        
        // Parameters for temperature unit (celsius or fahrenheit)
        static func temperatureUnit(useMetric: Bool) -> String {
            return useMetric ? "celsius" : "fahrenheit"
        }
        
        // Parameters for wind speed unit
        static func windSpeedUnit(useMetric: Bool) -> String {
            return useMetric ? "kmh" : "mph"
        }
        
        // Parameters for precipitation unit
        static func precipitationUnit(useMetric: Bool) -> String {
            return useMetric ? "mm" : "inch"
        }
        
        // Get the complete URL string for daily forecast
        static func getDailyForecastURL(
            latitude: Double,
            longitude: Double,
            startDate: Date,
            endDate: Date,
            useMetric: Bool = false
        ) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startDateStr = dateFormatter.string(from: startDate)
            let endDateStr = dateFormatter.string(from: endDate)
            
            return "\(APIConfiguration.environment.baseURL)\(weatherPath)?latitude=\(latitude)&longitude=\(longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=\(temperatureUnit(useMetric: useMetric))&wind_speed_unit=\(windSpeedUnit(useMetric: useMetric))&precipitation_unit=\(precipitationUnit(useMetric: useMetric))&timezone=auto&start_date=\(startDateStr)&end_date=\(endDateStr)&format=flatbuffers"
        }
        
        // Get the complete URL string for hourly forecast
        static func getHourlyForecastURL(
            latitude: Double,
            longitude: Double,
            startDate: Date,
            endDate: Date,
            useMetric: Bool = false
        ) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let startDateStr = dateFormatter.string(from: startDate)
            let endDateStr = dateFormatter.string(from: endDate)
            
            return "\(APIConfiguration.environment.baseURL)\(weatherPath)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,is_day,weather_code&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,showers,snowfall,weather_code,is_day&temperature_unit=\(temperatureUnit(useMetric: useMetric))&wind_speed_unit=\(windSpeedUnit(useMetric: useMetric))&precipitation_unit=\(precipitationUnit(useMetric: useMetric))&timezone=auto&start_date=\(startDateStr)&end_date=\(endDateStr)&models=best_match&format=flatbuffers"
        }
        
        // Create query parameters for daily forecast
        static func dailyForecastQueryItems(
            latitude: Double,
            longitude: Double,
            startDate: Date,
            endDate: Date,
            useMetric: Bool = false
        ) -> [URLQueryItem] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
                URLQueryItem(name: "temperature_unit", value: temperatureUnit(useMetric: useMetric)),
                URLQueryItem(name: "wind_speed_unit", value: windSpeedUnit(useMetric: useMetric)),
                URLQueryItem(name: "precipitation_unit", value: precipitationUnit(useMetric: useMetric)),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)),
                URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate)),
                URLQueryItem(name: "format", value: "flatbuffers")
            ]
        }
        
        // Create query parameters for hourly forecast
        static func hourlyForecastQueryItems(
            latitude: Double,
            longitude: Double,
            startDate: Date,
            endDate: Date,
            useMetric: Bool = false
        ) -> [URLQueryItem] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "current", value: "temperature_2m,is_day,weather_code"),
                URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,showers,snowfall,weather_code,is_day"),
                URLQueryItem(name: "temperature_unit", value: temperatureUnit(useMetric: useMetric)),
                URLQueryItem(name: "wind_speed_unit", value: windSpeedUnit(useMetric: useMetric)),
                URLQueryItem(name: "precipitation_unit", value: precipitationUnit(useMetric: useMetric)),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)),
                URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate)),
                URLQueryItem(name: "models", value: "best_match"),
                URLQueryItem(name: "format", value: "flatbuffers")
            ]
        }
    }
} 