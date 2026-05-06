import SwiftUI

struct HomeView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var locationManager = LocationManager()
    @State private var showSearch = false

    var body: some View {
        ZStack {
            // Dynamic animated background
            AnimatedWeatherBackground(
                condition: viewModel.weatherCondition,
                isNight: viewModel.isNight
            )

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView()
            case .loaded:
                mainContent
            case .error(let message):
                ErrorView(message: message) {
                    Task {
                        if let loc = locationManager.location {
                            await viewModel.fetchWeather(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
                        } else {
                            locationManager.requestPermission()
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                Task {
                    await viewModel.fetchWeather(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude
                    )
                }
            }
        }
        .onChange(of: locationManager.locationError) { _, error in
            if let error = error, viewModel.loadingState != .loaded {
                viewModel.loadingState = .error(error)
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(
                    text: $viewModel.searchText,
                    isSearching: viewModel.isSearching,
                    onSubmit: {
                        Task {
                            await viewModel.searchCity(viewModel.searchText)
                        }
                    },
                    onClear: {
                        viewModel.clearSearch()
                        if let loc = locationManager.location {
                            Task {
                                await viewModel.refresh(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
                            }
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Header Section
                headerSection
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Hourly Forecast
                HourlyForecastView(
                    items: viewModel.hourlyForecast,
                    isNight: viewModel.isNight
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Weekly Forecast
                WeeklyForecastView(
                    forecast: viewModel.dailyForecast,
                    isNight: viewModel.isNight
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Details Grid
                detailsGrid
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Sunrise/Sunset
                sunriseSunsetCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .refreshable {
            if let loc = locationManager.location {
                await viewModel.refresh(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            // City Name
            Text(viewModel.displayWeather?.name ?? locationManager.cityName)
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundStyle(.white)

            // Date
            Text(Date().dateString)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            // Weather Icon
            if let weather = viewModel.displayWeather {
                Image(systemName: WeatherCondition.sfSymbol(for: weather.iconCode))
                    .font(.system(size: 64))
                    .foregroundStyle(WeatherCondition.iconColor(for: weather.iconCode))
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: WeatherCondition.iconColor(for: weather.iconCode).opacity(0.4), radius: 16)
                    .padding(.vertical, 8)

                // Temperature
                Text(weather.main.temp.temperatureString)
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)

                // Condition
                Text(weather.conditionDescription)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.85))

                // High/Low
                HStack(spacing: 16) {
                    Label("H: \(weather.main.tempMax.temperatureString)", systemImage: "arrow.up")
                    Label("L: \(weather.main.tempMin.temperatureString)", systemImage: "arrow.down")
                }
                .font(.callout)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 2)

                // Feels Like
                Text("Feels like \(weather.main.feelsLike.temperatureString)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Details Grid

    private var detailsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            if let weather = viewModel.displayWeather {
                WeatherDetailTile(
                    title: "HUMIDITY",
                    value: "\(weather.main.humidity)%",
                    icon: "humidity.fill",
                    tint: .cyan
                )

                WeatherDetailTile(
                    title: "WIND",
                    value: weather.wind.speed.speedString,
                    icon: "wind",
                    tint: .mint
                )

                WeatherDetailTile(
                    title: "PRESSURE",
                    value: "\(weather.main.pressure) hPa",
                    icon: "gauge.medium",
                    tint: .purple
                )

                WeatherDetailTile(
                    title: "VISIBILITY",
                    value: "\(weather.visibility / 1000) km",
                    icon: "eye.fill",
                    tint: .yellow
                )

                WeatherDetailTile(
                    title: "FEELS LIKE",
                    value: weather.main.feelsLike.temperatureString,
                    icon: "thermometer.medium",
                    tint: .orange
                )

                WeatherDetailTile(
                    title: "CLOUDS",
                    value: "\(weather.clouds.all)%",
                    icon: "cloud.fill",
                    tint: .white
                )
            }
        }
    }

    // MARK: - Sunrise / Sunset

    private var sunriseSunsetCard: some View {
        WeatherCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("SUN", systemImage: "sun.and.horizon.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))

                Divider()
                    .background(.white.opacity(0.2))

                if let weather = viewModel.displayWeather {
                    HStack {
                        VStack(spacing: 6) {
                            Image(systemName: "sunrise.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            Text("Sunrise")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Text(weather.sunriseDate.timeString)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .frame(height: 50)
                            .background(.white.opacity(0.2))

                        VStack(spacing: 6) {
                            Image(systemName: "sunset.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            Text("Sunset")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Text(weather.sunsetDate.timeString)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
