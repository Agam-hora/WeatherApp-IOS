# Atmos - iOS Weather App

Atmos is a modern weather application built with **SwiftUI** for iOS.  
It fetches real-time weather and forecast data from the OpenWeatherMap API and presents it with animated, condition-aware UI components.

## Features

- Current weather by device location
- Search weather by city name
- Hourly forecast preview
- Multi-day forecast summary
- Weather details (humidity, wind, pressure, visibility, clouds, feels-like)
- Sunrise and sunset times
- Pull-to-refresh support
- Offline fallback using cached weather data
- Retry and error handling for network requests

## Tech Stack

- Swift 5.9
- SwiftUI
- iOS 17.0+
- URLSession + async/await
- OpenWeatherMap API

## Project Structure

- `Atmos/Models` - API response models and weather condition mapping
- `Atmos/Services` - networking and API request logic
- `Atmos/ViewModels` - app state, search, caching, and data flow
- `Atmos/Views` - SwiftUI screens and reusable UI components
- `Atmos/Utilities` - constants and convenience extensions

## Getting Started

### 1) Prerequisites

- Xcode 16 or later
- iOS 17.0+ deployment target
- OpenWeatherMap API key

### 2) Clone

```bash
git clone https://github.com/Agam-hora/WeatherApp-IOS.git
cd WeatherApp-IOS
```

### 3) Configure API Key

Update the API key in `Atmos/Utilities/Constants.swift`:

```swift
static let apiKey = "YOUR_API_KEY"
```

> Note: For production apps, avoid storing API keys directly in source files.

### 4) Open in Xcode

Open the project and run on a simulator or physical device:

- `Atmos.xcodeproj`

## Build and Run

1. Select an iOS simulator (or connected device).
2. Build and run the app from Xcode.
3. Grant location permission when prompted.

## Error Handling and Resilience

The app includes:

- Request timeouts and connectivity wait behavior
- HTTP status handling (including unauthorized and rate-limited responses)
- Automatic retries with exponential backoff
- Cached weather fallback when requests fail

## License

No license file is currently provided in this repository. Add one if you plan to distribute or open-source this project publicly.

