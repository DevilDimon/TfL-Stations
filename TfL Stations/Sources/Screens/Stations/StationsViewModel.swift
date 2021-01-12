import Foundation
import class CoreLocation.CLLocation

private enum Constants {
	static let londonLocation = CLLocation(latitude: 51.5072, longitude: -0.1275)
	static let defaultLocation = CLLocation(latitude: 51.5075, longitude: -0.1075)

	static let londonRadiusInMeters = 50_000.0
	static let stationArrivalUpdateInterval: TimeInterval = 30
}

final class StationsViewModel {
	private(set) var items: [StationTableViewCellViewModel] = [] {
		didSet {
			itemsDidChange?()
		}
	}
	var itemsDidChange: (() -> Void)?

	private let tflApiService: ITFLAPIService
	private let locationService: ILocationService
	private weak var timer: Timer?
	private var hasLoadedFirstPredictions = false

	init(tflApiService: ITFLAPIService, locationService: ILocationService) {
		self.tflApiService = tflApiService
		self.locationService = locationService
	}

	func viewDidLoad() {
		let timer = Timer(
			timeInterval: Constants.stationArrivalUpdateInterval,
			target: self,
			selector: #selector(timerFired),
			userInfo: nil,
			repeats: true
		)
		RunLoop.current.add(timer, forMode: .common)
		self.timer = timer
	}

	func viewWillAppear() {
		fetchData()
	}

	func refreshTapped() {
		fetchData()
	}
}

// MARK: - Private

private extension StationsViewModel {
	func fetchData() {
		fetchLocation { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				switch result {
					case .success(let location) where self.isLocationInLondon(location):
						self.fetchStations(location: location)
					default:
						self.fetchStations(location: Constants.defaultLocation)
				}
			}
		}
	}

	func fetchLocation(completion: @escaping (Result<CLLocation, LocationServiceError>) -> Void) {
		locationService.requestUserLocation(completion: completion)
	}

	func fetchStations(location: CLLocation) {
		let coordinate = location.coordinate
		tflApiService.fetchNearbyTubeStations(lat: "\(coordinate.latitude)", lon: "\(coordinate.longitude)",
			completion: { [weak self] result in
				DispatchQueue.main.async {
					guard let self = self else { return }
					switch result {
						case .success(let response):
							self.items = response.stopPoints?.map {
								StationTableViewCellViewModel(model: $0, tflApiService: self.tflApiService)
							} ?? []

							if self.hasLoadedFirstPredictions == false {
								self.hasLoadedFirstPredictions = true
								self.timerFired()
							}
						case .failure:
							break
					}
				}
			}
		)
	}

	func isLocationInLondon(_ location: CLLocation) -> Bool {
		location.distance(from: Constants.londonLocation) <= Constants.londonRadiusInMeters
	}

	@objc func timerFired() {
		items.forEach {
			$0.fetchArrivalPredictions()
		}
		
		if hasLoadedFirstPredictions == false {
			hasLoadedFirstPredictions = true
		}
	}
}
