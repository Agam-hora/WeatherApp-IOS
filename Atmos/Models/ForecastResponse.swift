import Foundation

struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: City

    struct ForecastItem: Codable, Identifiable {
        let dt: Int
        let main: MainWeather
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let sys: ForecastSys
        let dtTxt: String

        var id: Int { dt }

        enum CodingKeys: String, CodingKey {
            case dt, main, weather, clouds, wind, visibility, pop, sys
            case dtTxt = "dt_txt"
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

        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }

        struct Clouds: Codable {
            let all: Int
        }

        struct Wind: Codable {
            let speed: Double
            let deg: Int
            let gust: Double?
        }

        struct ForecastSys: Codable {
            let pod: String
        }

        var date: Date {
            Date(timeIntervalSince1970: TimeInterval(dt))
        }

        var conditionId: Int {
            weather.first?.id ?? 800
        }

        var conditionDescription: String {
            weather.first?.description.capitalized ?? "Clear"
        }

        var iconCode: String {
            weather.first?.icon ?? "01d"
        }
    }

    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int

        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}

// MARK: - Daily Forecast Grouping

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let highTemp: Double
    let lowTemp: Double
    let conditionId: Int
    let conditionDescription: String
    let iconCode: String
    let humidity: Int
    let windSpeed: Double
    let pop: Double
}

extension ForecastResponse {
    func dailyForecasts() -> [DailyForecast] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { item in
            calendar.startOfDay(for: item.date)
        }

        return grouped.sorted { $0.key < $1.key }
            .prefix(7)
            .map { (date, items) in
                let high = items.map(\.main.tempMax).max() ?? 0
                let low = items.map(\.main.tempMin).min() ?? 0
                let midday = items.min(by: {
                    abs(Calendar.current.component(.hour, from: $0.date) - 14)
                    < abs(Calendar.current.component(.hour, from: $1.date) - 14)
                })
                let avgHumidity = items.map(\.main.humidity).reduce(0, +) / max(items.count, 1)
                let avgWind = items.map(\.wind.speed).reduce(0, +) / Double(max(items.count, 1))
                let maxPop = items.map(\.pop).max() ?? 0

                return DailyForecast(
                    date: date,
                    dayName: date.shortDay,
                    highTemp: high,
                    lowTemp: low,
                    conditionId: midday?.conditionId ?? 800,
                    conditionDescription: midday?.conditionDescription ?? "Clear",
                    iconCode: midday?.iconCode ?? "01d",
                    humidity: avgHumidity,
                    windSpeed: avgWind,
                    pop: maxPop
                )
            }
    }
}
