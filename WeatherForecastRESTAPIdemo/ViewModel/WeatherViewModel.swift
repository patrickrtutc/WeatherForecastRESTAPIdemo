//
//  WeatherViewModel.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/6/25.
//

import Foundation
import OpenMeteoSdk
import SwiftUI
import CoreLocation
import Combine

// Enum to represent the state of the forecast data
enum ForecastState {
    case loading
    case success([WeatherApiResponse])
    case error(String)
}

extension WeatherDetailsView {
    
    @Observable @MainActor
    class ViewModel {
        var state: ForecastState = .loading
        var longitude: Double?
        var latitude: Double?
        var selectedMetric: Bool = false
        var favoriteLocations: [SavedLocation] = []
        
        private let repository: WeatherRepositoryProtocol
        private var cancellables = Set<AnyCancellable>()
        
        init(repository: WeatherRepositoryProtocol = DIContainer.shared.resolve(WeatherRepositoryProtocol.self)) {
            self.repository = repository
            loadFavoriteLocations()
        }
        
        func fetchForecast() {
            Task {
                await _fetchForecast()
            }
        }
        
        @MainActor
        private func _fetchForecast() async {
            state = .loading
            
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
            
            repository.getDailyForecast(
                latitude: latitude ?? 33.884,
                longitude: longitude ?? -84.5144,
                startDate: startDate,
                endDate: endDate,
                useMetric: selectedMetric
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] responses in
                    self?.state = .success(responses)
                }
            )
            .store(in: &cancellables)
        }
        
        func setLocation(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
            fetchForecast()
        }
        
        func saveCurrentLocationToFavorites(name: String) {
            guard let latitude = latitude, let longitude = longitude else { return }
            
            repository.saveLocationToFavorites(
                name: name,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadFavoriteLocations()
                }
            )
            .store(in: &cancellables)
        }
        
        func loadFavoriteLocations() {
            repository.getFavoriteLocations()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] locations in
                        self?.favoriteLocations = locations
                    }
                )
                .store(in: &cancellables)
        }
        
        func removeFromFavorites(id: String) {
            repository.removeLocationFromFavorites(id: id)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] _ in
                        self?.loadFavoriteLocations()
                    }
                )
                .store(in: &cancellables)
        }
        
        func useFavoriteLocation(_ location: SavedLocation) {
            setLocation(latitude: location.latitude, longitude: location.longitude)
        }
        
        func toggleUnits() {
            selectedMetric.toggle()
            fetchForecast()
        }
        
        func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, MMM d"  // Displays as "Mon, Mar 10"
            return formatter.string(from: date)
        }
        
        func weatherIcon(for code: Float) -> String {
            switch Int(code) {
            case 0: return "sun.max"
            case 1...3: return "cloud.sun"
            case 45, 48: return "cloud.fog"
            case 51...67: return "cloud.rain"
            case 71...77: return "snow"
            case 80...82: return "cloud.heavyrain"
            case 95: return "cloud.bolt"
            default: return "cloud"
            }
        }
        
        func weatherDescription(for code: Float) -> String {
            switch Int(code) {
            case 0: return "Clear"
            case 1...3: return "Partly Cloudy"
            case 45, 48: return "Fog"
            case 51...55: return "Drizzle"
            case 61...65: return "Rain"
            case 71...75: return "Snow"
            case 80...82: return "Showers"
            case 95: return "Thunderstorm"
            default: return "Unknown"
            }
        }
    }
}
