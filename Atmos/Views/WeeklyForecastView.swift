import SwiftUI

struct WeeklyForecastView: View {
    let forecast: [DailyForecast]
    let isNight: Bool

    private var tempRange: (min: Double, max: Double) {
        let allLows = forecast.map(\.lowTemp)
        let allHighs = forecast.map(\.highTemp)
        return (allLows.min() ?? 0, allHighs.max() ?? 30)
    }

    var body: some View {
        WeatherCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("7-DAY FORECAST", systemImage: "calendar")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))

                Divider()
                    .background(.white.opacity(0.2))

                ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                    HStack(spacing: 12) {
                        Text(index == 0 ? "Today" : day.dayName)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(width: 50, alignment: .leading)

                        Image(systemName: WeatherCondition.sfSymbol(for: day.iconCode))
                            .font(.body)
                            .foregroundStyle(WeatherCondition.iconColor(for: day.iconCode))
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 30)

                        if day.pop > 0.2 {
                            Text("\(Int(day.pop * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.cyan)
                                .frame(width: 30)
                        } else {
                            Spacer()
                                .frame(width: 30)
                        }

                        Text(day.lowTemp.temperatureString)
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 35)

                        temperatureBar(low: day.lowTemp, high: day.highTemp)

                        Text(day.highTemp.temperatureString)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(width: 35)
                    }
                    .padding(.vertical, 4)

                    if index < forecast.count - 1 {
                        Divider()
                            .background(.white.opacity(0.1))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func temperatureBar(low: Double, high: Double) -> some View {
        GeometryReader { geo in
            let range = tempRange.max - tempRange.min
            let normalizedLow = range > 0 ? (low - tempRange.min) / range : 0
            let normalizedHigh = range > 0 ? (high - tempRange.min) / range : 1

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.15))
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan, .green, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(4, geo.size.width * (normalizedHigh - normalizedLow)),
                        height: 4
                    )
                    .offset(x: geo.size.width * normalizedLow)
            }
        }
        .frame(height: 4)
    }
}
