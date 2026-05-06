import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case rateLimited
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .noData:
            return "No data received from server."
        case .decodingError(let error):
            return "Failed to process weather data: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error (code: \(code)). Please try later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        case .unauthorized:
            return "Invalid API key. Please check your configuration."
        }
    }
}

actor WeatherService {
    static let shared = WeatherService()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    // MARK: - Public API

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        var components = URLComponents(string: Constants.currentWeatherEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: Constants.units)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return try await fetch(url)
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        var components = URLComponents(string: Constants.forecastEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: Constants.units)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return try await fetch(url)
    }

    func fetchWeatherByCity(name: String) async throws -> WeatherResponse {
        var components = URLComponents(string: Constants.currentWeatherEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: Constants.units)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return try await fetch(url)
    }

    func fetchForecastByCity(name: String) async throws -> ForecastResponse {
        var components = URLComponents(string: Constants.forecastEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: Constants.units)
        ]
        guard let url = components.url else { throw NetworkError.invalidURL }
        return try await fetch(url)
    }

    // MARK: - Generic Fetch with Retry

    private func fetch<T: Decodable>(_ url: URL, retries: Int = 3) async throws -> T {
        var lastError: Error = NetworkError.noData

        for attempt in 0..<retries {
            do {
                let (data, response) = try await session.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }

                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        throw NetworkError.decodingError(error)
                    }
                case 401:
                    throw NetworkError.unauthorized
                case 429:
                    throw NetworkError.rateLimited
                case 400...499:
                    throw NetworkError.serverError(httpResponse.statusCode)
                case 500...599:
                    lastError = NetworkError.serverError(httpResponse.statusCode)
                    if attempt < retries - 1 {
                        let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }
                default:
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
            } catch let error as NetworkError {
                throw error
            } catch {
                lastError = NetworkError.networkError(error)
                if attempt < retries - 1 {
                    let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                    try await Task.sleep(nanoseconds: delay)
                    continue
                }
            }
        }

        throw lastError
    }
}
