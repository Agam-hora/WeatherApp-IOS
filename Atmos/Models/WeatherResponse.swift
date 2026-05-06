import Foundation

struct WeatherResponse: Codable, Identifiable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: MainWeather
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int

    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }

    struct Weather: Codable, Identifiable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct MainWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int
        let seaLevel: Int?
        let grndLevel: Int?

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
            case seaLevel = "sea_level"
            case grndLevel = "grnd_level"
        }
    }

    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }

    struct Clouds: Codable {
        let all: Int
    }

    struct Sys: Codable {
        let type: Int?
        let id: Int?
        let country: String?
        let sunrise: Int
        let sunset: Int
    }

    // MARK: - Computed Properties

    var conditionId: Int {
        weather.first?.id ?? 800
    }

    var conditionDescription: String {
        weather.first?.description.capitalized ?? "Clear"
    }

    var iconCode: String {
        weather.first?.icon ?? "01d"
    }

    var isNight: Bool {
        let now = dt
        return now < sys.sunrise || now > sys.sunset
    }

    var sunriseDate: Date {
        Date(timeIntervalSince1970: TimeInterval(sys.sunrise + timezone))
    }

    var sunsetDate: Date {
        Date(timeIntervalSince1970: TimeInterval(sys.sunset + timezone))
    }

    var currentDate: Date {
        Date(timeIntervalSince1970: TimeInterval(dt + timezone))
    }
}
