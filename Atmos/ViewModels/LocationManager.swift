import CoreLocation
import SwiftUI

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var cityName: String = ""
    var countryCode: String = ""
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?
    var isLoading: Bool = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 1000
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        isLoading = true
        locationError = nil
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        isLoading = true
        locationError = nil
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        isLoading = false
        reverseGeocode(newLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = "Location access denied. Please enable in Settings."
            case .locationUnknown:
                locationError = "Unable to determine location. Please try again."
            case .network:
                locationError = "Network error. Check your connection."
            default:
                locationError = "Location error: \(error.localizedDescription)"
            }
        } else {
            locationError = error.localizedDescription
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            isLoading = false
            locationError = "Location access denied. Please enable in Settings."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                self.countryCode = placemark.isoCountryCode ?? ""
            }
        }
    }
}
