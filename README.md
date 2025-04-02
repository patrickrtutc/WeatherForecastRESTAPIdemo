# Weather Forecast REST API Demo (iOS App)

## Overview

This is a demonstration iOS application built with Swift and SwiftUI. It showcases how to:

1.  Fetch weather forecast data from a REST API (specifically, the [Open-Meteo API](https://open-meteo.com/)).
2.  Integrate various Firebase services for backend functionality and analytics.

## Features

*   Fetches and displays weather forecast data using the `OpenMeteoSdk`.
*   Integrates Firebase for:
    *   **Authentication:** User sign-up/sign-in (implementation details may vary).
    *   **Analytics:** Tracking user interactions and app usage.
    *   **Crashlytics:** Monitoring and reporting application crashes.
    *   **Firestore:** Storing and syncing data (e.g., user preferences, saved locations).

## Dependencies

This project utilizes Swift Package Manager (SPM) to manage dependencies:

*   [Open-Meteo Swift SDK](https://github.com/open-meteo/sdk)
*   [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk):
    *   `FirebaseAnalytics`
    *   `FirebaseAuth`
    *   `FirebaseAuthCombine-Community`
    *   `FirebaseCore`
    *   `FirebaseCrashlytics`
    *   `FirebaseFirestore`

## Setup

1.  **Clone the Repository:**
    ```bash
    git clone <your-repository-url>
    cd Swift-basics/WeatherForecastRESTAPIdemo
    ```
2.  **Open in Xcode:**
    Open the `WeatherForecastRESTAPIdemo.xcodeproj` file in Xcode (Version 16.2 or later recommended based on project settings).
3.  **Firebase Configuration:**
    *   This project requires a Firebase project setup.
    *   Download your `GoogleService-Info.plist` file from the Firebase console.
    *   Place the `GoogleService-Info.plist` file into the `WeatherForecastRESTAPIdemo/WeatherForecastRESTAPIdemo/` directory (ensure it's added to the `WeatherForecastRESTAPIdemo` target in Xcode's "Build Phases" -> "Copy Bundle Resources").
    *   **Important:** Without a valid `GoogleService-Info.plist`, Firebase services will fail to initialize.
4.  **Build and Run:**
    Select a target simulator or physical device in Xcode and run the application (Cmd+R).

## API Used

*   **Open-Meteo API:** Provides the weather forecast data. Refer to their [documentation](https://open-meteo.com/en/docs) for API details.

---

*This README provides a basic structure. Feel free to add more details about specific features, usage instructions, screenshots, or contribution guidelines.* 