import SwiftUI

enum WeatherCondition: String, CaseIterable {
    case clear
    case fewClouds
    case clouds
    case rain
    case drizzle
    case thunderstorm
    case snow
    case mist
    case unknown

    static func from(id: Int) -> WeatherCondition {
        switch id {
        case 200...232: return .thunderstorm
        case 300...321: return .drizzle
        case 500...531: return .rain
        case 600...622: return .snow
        case 700...781: return .mist
        case 800: return .clear
        case 801: return .fewClouds
        case 802...804: return .clouds
        default: return .unknown
        }
    }

    var sfSymbol: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .fewClouds: return "cloud.sun.fill"
        case .clouds: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .mist: return "cloud.fog.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    var nightSfSymbol: String {
        switch self {
        case .clear: return "moon.stars.fill"
        case .fewClouds: return "cloud.moon.fill"
        default: return sfSymbol
        }
    }

    func icon(isNight: Bool) -> String {
        isNight ? nightSfSymbol : sfSymbol
    }

    func gradientColors(isNight: Bool) -> [Color] {
        if isNight {
            return nightGradientColors
        }
        return dayGradientColors
    }

    var dayGradientColors: [Color] {
        switch self {
        case .clear:
            return [
                Color(red: 1.0, green: 0.75, blue: 0.3),
                Color(red: 1.0, green: 0.55, blue: 0.2),
                Color(red: 0.95, green: 0.4, blue: 0.15)
            ]
        case .fewClouds:
            return [
                Color(red: 0.4, green: 0.7, blue: 0.95),
                Color(red: 0.3, green: 0.55, blue: 0.85),
                Color(red: 0.5, green: 0.65, blue: 0.9)
            ]
        case .clouds:
            return [
                Color(red: 0.55, green: 0.6, blue: 0.7),
                Color(red: 0.45, green: 0.5, blue: 0.6),
                Color(red: 0.4, green: 0.45, blue: 0.55)
            ]
        case .rain, .drizzle:
            return [
                Color(red: 0.15, green: 0.25, blue: 0.45),
                Color(red: 0.1, green: 0.2, blue: 0.4),
                Color(red: 0.08, green: 0.15, blue: 0.35)
            ]
        case .thunderstorm:
            return [
                Color(red: 0.12, green: 0.1, blue: 0.2),
                Color(red: 0.2, green: 0.1, blue: 0.3),
                Color(red: 0.1, green: 0.05, blue: 0.15)
            ]
        case .snow:
            return [
                Color(red: 0.75, green: 0.82, blue: 0.92),
                Color(red: 0.65, green: 0.72, blue: 0.85),
                Color(red: 0.55, green: 0.62, blue: 0.78)
            ]
        case .mist:
            return [
                Color(red: 0.6, green: 0.65, blue: 0.7),
                Color(red: 0.5, green: 0.55, blue: 0.62),
                Color(red: 0.45, green: 0.5, blue: 0.58)
            ]
        case .unknown:
            return [
                Color(red: 0.3, green: 0.5, blue: 0.8),
                Color(red: 0.2, green: 0.4, blue: 0.7),
                Color(red: 0.15, green: 0.3, blue: 0.6)
            ]
        }
    }

    var nightGradientColors: [Color] {
        switch self {
        case .clear:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.2),
                Color(red: 0.08, green: 0.06, blue: 0.25),
                Color(red: 0.1, green: 0.08, blue: 0.3)
            ]
        case .thunderstorm:
            return [
                Color(red: 0.08, green: 0.05, blue: 0.15),
                Color(red: 0.15, green: 0.05, blue: 0.25),
                Color(red: 0.05, green: 0.02, blue: 0.1)
            ]
        default:
            return [
                Color(red: 0.08, green: 0.1, blue: 0.2),
                Color(red: 0.1, green: 0.12, blue: 0.25),
                Color(red: 0.06, green: 0.08, blue: 0.18)
            ]
        }
    }

    static func sfSymbol(for iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "cloud.snow.fill"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }

    static func iconColor(for iconCode: String) -> Color {
        switch iconCode {
        case "01d": return .yellow
        case "01n": return Color(red: 0.7, green: 0.75, blue: 1.0)
        case "02d", "10d": return Color(red: 1.0, green: 0.85, blue: 0.4)
        case "02n", "10n": return Color(red: 0.6, green: 0.65, blue: 0.9)
        case "09d", "09n": return Color(red: 0.4, green: 0.6, blue: 0.9)
        case "11d", "11n": return Color(red: 0.9, green: 0.8, blue: 0.3)
        case "13d", "13n": return .white
        default: return .white
        }
    }
}
