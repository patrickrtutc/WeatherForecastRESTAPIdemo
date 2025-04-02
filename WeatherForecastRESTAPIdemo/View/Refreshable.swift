//
//  Refreshable.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/9/25.
//

import SwiftUI

struct Refreshable<Content: View>: View {
    
    let onRefresh: () async -> Void
    let content: Content
    
    @State private var isRefreshing = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack(alignment: .top) {
                    LoadingIndicator(isRefreshing: isRefreshing, dragOffset: dragOffset)
                        .frame(height: 50)
                        .offset(y: dragOffset - 50)
                    content
                        .offset(y: isRefreshing ? 50 : dragOffset)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isRefreshing && value.translation.height > 0 {
                            dragOffset = min(value.translation.height, 150) // Cap the pull distance
                        }
                    }
                    .onEnded { value in
                        if dragOffset > 100 && !isRefreshing {
                            Task {
                                isRefreshing = true
                                await onRefresh()
                                isRefreshing = false
                            }
                        }
                        withAnimation(.easeOut) {
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}
