//
//  CLLocationCoordinate2Dextension.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

import MapKit

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
