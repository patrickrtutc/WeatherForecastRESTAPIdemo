//
//  File.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/6/25.
//

import Foundation

struct WeatherData {
//    let current: Current
    
//    let hourly: Hourly
    
    let daily: Daily
    
//    struct Current {
//        let time: Date
//        let temperature2m: Float
//        let isDay: Float
//        let weatherCode: Float
//    }
//    
//    struct Hourly {
//        let time: [Date]
//        let temperature2m: [Float]
//        let relativeHumidity2m: [Float]
//        let precipitationProbability: [Float]
//        let precipitation: [Float]
//        let rain: [Float]
//        let showers: [Float]
//        let snowfall: [Float]
//        let weatherCode: [Float]
//        let isDay: [Float]
//    }
    
    struct Daily {
            let time: [Date]
            let weatherCode: [Float]
            let temperature2mMax: [Float]
            let temperature2mMin: [Float]
        }
}
