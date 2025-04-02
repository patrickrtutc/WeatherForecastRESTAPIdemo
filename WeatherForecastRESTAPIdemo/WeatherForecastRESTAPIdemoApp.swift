//
//  WeatherForecastRESTAPIdemoApp.swift
//  WeatherForecastRESTAPIdemo
//
//  Created by Patrick Tung on 3/6/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// Creating a separate configureDependencies function outside of the app struct
func setupDependencyContainer() {
    let container = DIContainer.shared
    
    // Register NetworkClient
    container.registerSingleton(type: APIClientProtocol.self, instance: APIClient())
    
    // Register CacheManager
    container.registerSingleton(type: CacheManager.self, instance: CacheManager.shared)
    
    // Register LocationStorage
    container.registerSingleton(type: LocationStorageProtocol.self, instance: LocationStorage())
    
    // Register AuthRepository
    container.registerSingleton(type: AuthRepositoryProtocol.self, instance: AuthRepository())
    
    // Register WeatherRepository
    container.registerSingleton(type: WeatherRepositoryProtocol.self) {
        WeatherRepository(
            apiClient: container.resolve(APIClientProtocol.self),
            cacheManager: container.resolve(CacheManager.self),
            locationStorage: container.resolve(LocationStorageProtocol.self)
        )
    }
}

@main
struct WeatherForecastRESTAPIdemoApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    
    init() {
        // Configure Firebase first, before any other initializations
        FirebaseApp.configure()
        print("Firebase configured in app init")
        
        // Configure dependencies before any StateObjects are created
        setupDependencyContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.authViewModel.isAuthenticated {
                    // Show main app when authenticated
                    NavigationStack {
                        SearchableMapView(viewModel: appState.weatherViewModel)
                            .environmentObject(appState)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        print("Sign Out button pressed")
                                        appState.authViewModel.signOut()
                                    }) {
                                        Text("Sign Out")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                    }
                    .onAppear {
                        print("Main app view appeared - user is authenticated")
                    }
                    .id("MainAppView")  // Force view recreation when identity changes
                } else {
                    // Show authentication view when not authenticated
                    AuthenticationView(viewModel: appState.authViewModel)
                        .onAppear {
                            print("Auth view appeared - user is not authenticated")
                        }
                        .id("AuthView")  // Force view recreation when identity changes
                }
            }
            // Use implicit animation instead of animation modifier
            .onChange(of: appState.authViewModel.isAuthenticated) { newValue in
                print("Authentication state changed in app root: \(newValue)")
            }
            .onAppear {
                // Force refresh user state when app appears
                Task {
                    await appState.authViewModel.refreshUserState()
                    print("App appeared - auth state: \(appState.authViewModel.isAuthenticated)")
                }
            }
        }
    }
}

/// Global app state
@MainActor // Make the whole class MainActor-isolated
class AppState: ObservableObject {
    @Published var weatherViewModel: WeatherDetailsView.ViewModel
    @Published var authViewModel: AuthViewModel
    
    init() {
        print("Initializing AppState")
        
        // Create view models with injected repositories
        let weatherRepository = DIContainer.shared.resolve(WeatherRepositoryProtocol.self)
        weatherViewModel = WeatherDetailsView.ViewModel(repository: weatherRepository)
        
        let authRepository = DIContainer.shared.resolve(AuthRepositoryProtocol.self)
        authViewModel = AuthViewModel(authRepository: authRepository)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase is already configured in the app's init
        // Just check if Auth is configured
        if Auth.auth().app != nil {
            print("Firebase Auth is properly initialized")
        } else {
            print("WARNING: Firebase Auth is not properly initialized")
        }
        return true
    }
}
