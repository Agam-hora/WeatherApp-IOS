import SwiftUI

struct HourlyForecastView: View {
    let items: [ForecastResponse.ForecastItem]
    let isNight: Bool

    var body: some View {
        WeatherCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("HOURLY FORECAST", systemImage: "clock")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))

                Divider()
                    .background(.white.opacity(0.2))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            VStack(spacing: 10) {
                                Text(index == 0 ? "Now" : item.date.hourString)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white.opacity(0.8))

                                Image(systemName: WeatherCondition.sfSymbol(for: item.iconCode))
                                    .font(.title3)
                                    .foregroundStyle(WeatherCondition.iconColor(for: item.iconCode))
                                    .symbolRenderingMode(.multicolor)

                                Text(item.main.temp.temperatureString)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)

                                if item.pop > 0.1 {
                                    Text("\(Int(item.pop * 100))%")
                                        .font(.caption2)
                                        .foregroundStyle(.cyan)
                                } else {
                                    Text(" ")
                                        .font(.caption2)
                                }
                            }
                            .frame(width: 55)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
