enum TFLAPIServiceError: Error {
	case requestFailure
	case decodingFailure
	case invalidURL
}

protocol ITFLAPIService {
	func fetchNearbyTubeStations(
		lat: String,
		lon: String,
		completion: @escaping (Result<StopPointsResponse, TFLAPIServiceError>) -> Void
	)

	func fetchArrivalPredictions(
		for stationID: String,
		completion: @escaping (Result<[ArrivalPrediction], TFLAPIServiceError>) -> Void
	)
}
