//
//  SheetView.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

import SwiftUI
import MapKit

struct SheetView: View {
    // 1
    @State private var locationService = LocationService(completer: .init())
    @State private var search: String = ""
    var onSelectLocation: (CLLocationCoordinate2D) -> Void // Callback to pass selected coordinate
    @Environment(\.dismiss) var dismiss // Access to dismiss the sheet
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for a restaurant", text: $search)
                    .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            Spacer()
            
            // 2
            List {
                ForEach(locationService.completions) { completion in
                    Button(action: {
                        if let coordinate = completion.coordinate {
                            print("Selected location: \(coordinate.latitude), \(coordinate.longitude)")
                            onSelectLocation(coordinate) // Notify parent of selection
                            dismiss() // Dismiss the sheet
                        } else {
                            print("No coordinate available for this completion")
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(completion.subTitle)
                        }
                    }
                    // 3
                    .listRowBackground(Color.clear)
                }
            }
            // 4
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        // 5
        .onChange(of: search) {
            locationService.update(queryFragment: search)
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}

struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.primary)
    }
}
