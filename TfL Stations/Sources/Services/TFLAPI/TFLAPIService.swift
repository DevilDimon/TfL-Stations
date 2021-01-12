import Foundation

private enum Constants {
	static let baseURLString = "https://api.tfl.gov.uk/"
	static let appKey = ""// put yours here
}

final class TFLAPIService: ITFLAPIService {
	private let urlSession = URLSession(configuration: .default)

	func fetchNearbyTubeStations(
		lat: String,
		lon: String,
		completion: @escaping (Result<StopPointsResponse, TFLAPIServiceError>) -> Void
	) {
		guard var urlComponents = URLComponents(string: Constants.baseURLString + "Stoppoint") else {
			completion(.failure(.invalidURL))
			return
		}

		let stopTypesItem = URLQueryItem(name: "stoptypes", value: "NaptanMetroStation,NaptanRailStation")
		let modesItem = URLQueryItem(name: "modes", value: "tube")
		let radiusItem = URLQueryItem(name: "radius", value: "1000")
		let latItem = URLQueryItem(name: "lat", value: lat)
		let lonItem = URLQueryItem(name: "lon", value: lon)
		let appKeyItem = makeAppKeyQueryItem()
		urlComponents.queryItems = [latItem, lonItem, stopTypesItem, radiusItem, modesItem, appKeyItem]

		guard let url = urlComponents.url else {
			completion(.failure(.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

		sendRequest(request, completion: completion)
	}

	func fetchArrivalPredictions(
		for stationID: String,
		completion: @escaping (Result<[ArrivalPrediction], TFLAPIServiceError>) -> Void
	) {
		guard var urlComponents = URLComponents(string: Constants.baseURLString + "StopPoint/\(stationID)/Arrivals") else {
			completion(.failure(.invalidURL))
			return
		}

		urlComponents.queryItems = [makeAppKeyQueryItem()]

		guard let url = urlComponents.url else {
			completion(.failure(.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

		sendRequest(request, completion: completion)
	}

	private func sendRequest<T: Decodable>(
		_ request: URLRequest,
		completion: @escaping (Result<T, TFLAPIServiceError>) -> Void
	) {
		urlSession.dataTask(with: request) { (data, _, error) in
			if error != nil {
				completion(.failure(.requestFailure))
				return
			} else if let data = data {
				do {
					let decodedResponse = try JSONDecoder().decode(T.self, from: data)
					completion(.success(decodedResponse))
					return
				} catch {
					completion(.failure(.decodingFailure))
					return
				}
			}
		}
		.resume()
	}

	private func makeAppKeyQueryItem() -> URLQueryItem {
		URLQueryItem(name: "app_key", value: Constants.appKey)
	}

}
