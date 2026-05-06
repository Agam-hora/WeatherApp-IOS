import SwiftUI

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

@Observable
class WeatherViewModel {
    var currentWeather: WeatherResponse?
    var forecast: ForecastResponse?
    var loadingState: LoadingState = .idle
    var searchText: String = ""
    var isSearching: Bool = false
    var searchedCityWeather: WeatherResponse?

    private let service = WeatherService.shared
    private let cacheKey = "cachedWeather"
    private let cacheForecastKey = "cachedForecast"

    // MARK: - Computed Properties

    var hourlyForecast: [ForecastResponse.ForecastItem] {
        guard let forecast = forecast else { return [] }
        return Array(forecast.list.prefix(8))
    }

    var dailyForecast: [DailyForecast] {
        forecast?.dailyForecasts() ?? []
    }

    var weatherCondition: WeatherCondition {
        guard let weather = currentWeather else { return .clear }
        return WeatherCondition.from(id: weather.conditionId)
    }

    var isNight: Bool {
        currentWeather?.isNight ?? false
    }

    var displayWeather: WeatherResponse? {
        searchedCityWeather ?? currentWeather
    }

    // MARK: - Fetch Weather

    func fetchWeather(lat: Double, lon: Double) async {
        loadingState = .loading

        do {
            async let weatherTask = service.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecastTask = service.fetchForecast(lat: lat, lon: lon)

            let (weather, forecastData) = try await (weatherTask, forecastTask)

            await MainActor.run {
                self.currentWeather = weather
                self.forecast = forecastData
                self.searchedCityWeather = nil
                self.loadingState = .loaded
                self.cacheWeatherData()
            }
        } catch {
            await MainActor.run {
                if self.loadCachedWeather() {
                    self.loadingState = .loaded
                } else {
                    self.loadingState = .error(error.localizedDescription)
                }
            }
        }
    }

    func refresh(lat: Double, lon: Double) async {
        do {
            async let weatherTask = service.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecastTask = service.fetchForecast(lat: lat, lon: lon)

            let (weather, forecastData) = try await (weatherTask, forecastTask)

            await MainActor.run {
                self.currentWeather = weather
                self.forecast = forecastData
                self.searchedCityWeather = nil
                self.cacheWeatherData()
            }
        } catch {
            // Silently fail on refresh, keep existing data
        }
    }

    // MARK: - City Search

    func searchCity(_ name: String) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        await MainActor.run {
            isSearching = true
        }

        do {
            async let weatherTask = service.fetchWeatherByCity(name: name)
            async let forecastTask = service.fetchForecastByCity(name: name)

            let (weather, forecastData) = try await (weatherTask, forecastTask)

            await MainActor.run {
                self.currentWeather = weather
                self.forecast = forecastData
                self.searchedCityWeather = weather
                self.isSearching = false
                self.loadingState = .loaded
            }
        } catch {
            await MainActor.run {
                self.isSearching = false
            }
        }
    }

    func clearSearch() {
        searchText = ""
        searchedCityWeather = nil
    }

    // MARK: - Caching

    private func cacheWeatherData() {
        if let weather = currentWeather, let data = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        if let forecast = forecast, let data = try? JSONEncoder().encode(forecast) {
            UserDefaults.standard.set(data, forKey: cacheForecastKey)
        }
    }

    @discardableResult
    private func loadCachedWeather() -> Bool {
        var loaded = false
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let weather = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
            self.currentWeather = weather
            loaded = true
        }
        if let data = UserDefaults.standard.data(forKey: cacheForecastKey),
           let forecast = try? JSONDecoder().decode(ForecastResponse.self, from: data) {
            self.forecast = forecast
            loaded = true
        }
        return loaded
    }
}
