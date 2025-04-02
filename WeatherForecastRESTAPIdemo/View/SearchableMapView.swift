//
//  SearchableMapView.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

// SearchableMapView.swift (example)
import SwiftUI
import MapKit

struct SearchableMapView: View {
    @State private var position = MapCameraPosition.automatic
    @State private var isSheetPresented: Bool = true
    @State private var selectedCoordinate: CLLocationCoordinate2D? // Tracks selection for navigation
    var viewModel: WeatherDetailsView.ViewModel
    
    var body: some View {
        ZStack {
            Map(position: $position)
                .ignoresSafeArea(edges: [.horizontal, .bottom]) // Keep top safe area for navigation bar
                .sheet(isPresented: $isSheetPresented) {
                    SheetView(onSelectLocation: { coordinate in
                        viewModel.setLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        selectedCoordinate = coordinate // Trigger navigation
                    })
                }
                .background(
                    NavigationLink(
                        destination: WeatherDetailsView(viewModel: viewModel),
                        isActive: Binding(
                            get: { selectedCoordinate != nil },
                            set: { if !$0 { selectedCoordinate = nil } } // Reset when navigation pops
                        )
                    ) {
                        EmptyView()
                    }
                )
                .onChange(of: selectedCoordinate) { newValue in
                    if newValue == nil {
                        isSheetPresented = true // Re-present sheet when back button is pressed
                    }
                }
        }
        .navigationTitle("Weather Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Example preview (adjust as needed)
#Preview {
    NavigationStack {
        SearchableMapView(viewModel: WeatherDetailsView.ViewModel())
    }
}
