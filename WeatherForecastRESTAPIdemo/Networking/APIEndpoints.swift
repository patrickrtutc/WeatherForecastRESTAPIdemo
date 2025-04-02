//
//  APIEndpoints.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/6/25.
//

import Foundation
import SwiftUI

struct APIEndpoints {
    @State private var latitude: Double = 33.884 // Default: Smyrna, GA
    @State private var longitude: Double = -84.5144
    
    func setLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getURLdaily() -> String {
        return "https://api.open-meteo.com/v1/forecast?latitude=\(self.latitude)&longitude=\(self.longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&start_date=2025-03-10&end_date=2025-03-15&format=flatbuffers"
    }
    
    func getURLdaily(latitude: Double, longitude: Double) -> String {
        return "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&start_date=2025-03-10&end_date=2025-03-15&format=flatbuffers"
    }
    
    func getURLhourly() -> String {
        return "https://api.open-meteo.com/v1/forecast?latitude=\(self.latitude)&longitude=\(self.longitude)&current=temperature_2m,is_day,weather_code&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,showers,snowfall,weather_code,is_day&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&start_date=2025-03-07&end_date=2025-03-12&models=best_match&format=flatbuffers"
    }
    
    func getURLhourly(latitude: Double, longitude: Double) -> String {
        return "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,is_day,weather_code&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,showers,snowfall,weather_code,is_day&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto&start_date=2025-03-07&end_date=2025-03-12&models=best_match&format=flatbuffers"
    }
}
