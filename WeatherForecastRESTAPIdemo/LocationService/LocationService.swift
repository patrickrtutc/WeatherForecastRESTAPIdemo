//
//  LocationService.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

import MapKit

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let coordinate: CLLocationCoordinate2D?
}

@Observable
class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    
    var completions = [SearchCompletions]()

    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }

    func update(queryFragment: String) {
        completer.resultTypes = .address
        completer.queryFragment = queryFragment
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            completions = completer.results.map { completion in
                // Get the private _mapItem property
                let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
                
                let coordinate = mapItem?.placemark.coordinate

                return .init(
                    title: completion.title,
                    subTitle: completion.subtitle,
                    coordinate: coordinate
                )
            }
        }
}
