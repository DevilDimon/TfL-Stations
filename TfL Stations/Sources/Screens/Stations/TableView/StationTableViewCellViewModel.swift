import Foundation

private enum Constants {
	static let facilitiesLimit = 7
}

final class StationTableViewCellViewModel {
	static let arrivalPredictionsMaxViewCount = 3

	var name: String {
		model.commonName ?? ""
	}

	var facilities: String? {
		guard let additionalProperties = model.additionalProperties else { return nil }
		return additionalProperties.filter {
			$0.category == StopPointAdditionalProperty.Category.facility.rawValue
		}
		.compactMap(\.key)
		.prefix(Constants.facilitiesLimit)
		.joined(separator: " • ")
	}

	var arrivalPredictions: [ArrivalPrediction] = [] {
		didSet {
			if arrivalPredictions != oldValue {
				arrivalPredictionsDidChange?()
			}
		}
	}
	var arrivalPredictionsDidChange: (() -> Void)?

	private let model: StopPoint
	private let tflApiService: ITFLAPIService

	init(model: StopPoint, tflApiService: ITFLAPIService) {
		self.model = model
		self.tflApiService = tflApiService
	}

	func fetchArrivalPredictions() {
		guard let stationID = model.naptanId else { return }

		self.tflApiService.fetchArrivalPredictions(for: stationID) { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				switch result {
					case .success(let predictions):
						let processedPredictions = predictions
							.filter { $0.timeToStation != nil }
							.prefix(StationTableViewCellViewModel.arrivalPredictionsMaxViewCount)
						self.arrivalPredictions = processedPredictions.sorted {
							($0.timeToStation ?? 0) < ($1.timeToStation ?? 0)
						}
					case .failure:
						self.arrivalPredictions = []
				}
			}
		}
	}

}
