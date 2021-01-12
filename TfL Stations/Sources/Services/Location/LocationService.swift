import CoreLocation

final class LocationService: NSObject, ILocationService {
	private let locationManager: CLLocationManager

	private var completion: ((Result<CLLocation, LocationServiceError>) -> Void)?

	override init() {
		self.locationManager = CLLocationManager()
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		super.init()

		self.locationManager.delegate = self
	}

	func requestUserLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void) {
		if let location = self.locationManager.location {
			completion(.success(location))
			return
		} else {
			self.completion = completion
		}

		let status = CLLocationManager.authorizationStatus()
		switch status {
			case .notDetermined:
				locationManager.requestWhenInUseAuthorization()
			case .denied, .restricted:
				completion(.failure(.unauthorized))
				return
			case .authorizedAlways, .authorizedWhenInUse:
				break
			@unknown default:
				break
		}

		self.locationManager.requestLocation()
	}
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		completion?(.success(location))
		completion = nil
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		completion?(.failure(.platformError))
		completion = nil
	}
}
