import class CoreLocation.CLLocation

enum LocationServiceError: Error {
	case unauthorized
	case platformError
}

protocol ILocationService {
	func requestUserLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void)
}
