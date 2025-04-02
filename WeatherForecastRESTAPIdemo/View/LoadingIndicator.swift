//
//  LoadingIndicator.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

import SwiftUI

struct LoadingIndicator: View {
    let isRefreshing: Bool
    let dragOffset: CGFloat
    
    var body: some View {
        if isRefreshing {
            WeatherLoadingView()
        } else {
            Image(systemName: "arrow.down")
                .foregroundColor(.gray)
                .rotationEffect(.degrees(dragOffset > 100 ? 180 : 0))
                .opacity(dragOffset / 100) // Fade in as you pull
                .animation(.easeInOut, value: dragOffset > 100)
        }
    }
}

struct WeatherLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 40, height: 40)
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.system(size: 24))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
}
