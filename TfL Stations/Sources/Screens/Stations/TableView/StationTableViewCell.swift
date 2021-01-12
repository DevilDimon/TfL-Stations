import UIKit

final class StationTableViewCell: UITableViewCell {
	static let reuseIdentifier = String(describing: self)
	static let arrivalDateFormatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .abbreviated
		return formatter
	}()

	var viewModel: StationTableViewCellViewModel? {
		didSet {
			guard let viewModel = viewModel else { return }
			if viewModel !== oldValue {
				viewModelDidChange()
			}
		}
	}

	private let stationNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .title2)
		label.numberOfLines = 0
		return label
	}()

	private let facilitiesLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.numberOfLines = 0
		return label
	}()

	private let arrivalPredictionsContainerStackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.distribution = .fillEqually
		view.spacing = 8
		return view
	}()

	private let arrivalPredictionStackViews: [UIStackView] = {
		var result = [UIStackView]()

		for _ in 0..<StationTableViewCellViewModel.arrivalPredictionsMaxViewCount {
			let view = UIStackView()
			view.translatesAutoresizingMaskIntoConstraints = false
			view.axis = .horizontal
			view.spacing = 16
			result.append(view)
		}

		return result
	}()

	private let arrivalPredictionStationNames: [UILabel] = {
		var result = [UILabel]()

		for _ in 0..<StationTableViewCellViewModel.arrivalPredictionsMaxViewCount {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = .preferredFont(forTextStyle: .footnote)
			label.numberOfLines = 1
			label.text = NSLocalizedString("stations.arrival placeholder", comment: "")
			result.append(label)
		}

		return result
	}()

	private let arrivalPredictionTimesToStation: [UILabel] = {
		var result = [UILabel]()

		for _ in 0..<StationTableViewCellViewModel.arrivalPredictionsMaxViewCount {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.font = .preferredFont(forTextStyle: .callout)
			label.numberOfLines = 1
			result.append(label)
		}

		return result
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubview(stationNameLabel)
		NSLayoutConstraint.activate([
			stationNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stationNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			stationNameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
		])

		contentView.addSubview(facilitiesLabel)
		NSLayoutConstraint.activate([
			facilitiesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			facilitiesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			facilitiesLabel.topAnchor.constraint(equalTo: stationNameLabel.bottomAnchor, constant: 8),
		])

		contentView.addSubview(arrivalPredictionsContainerStackView)
		NSLayoutConstraint.activate([
			arrivalPredictionsContainerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
																		  constant: 16),
			arrivalPredictionsContainerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
																		   constant: -16),
			arrivalPredictionsContainerStackView.topAnchor.constraint(equalTo: facilitiesLabel.bottomAnchor,
																	  constant: 16),
			arrivalPredictionsContainerStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
																		 constant: -8),
		])

		arrivalPredictionStackViews.forEach { arrivalPredictionsContainerStackView.addArrangedSubview($0) }
		for i in 0..<StationTableViewCellViewModel.arrivalPredictionsMaxViewCount {
			arrivalPredictionStackViews[i].addArrangedSubview(arrivalPredictionStationNames[i])
			arrivalPredictionStackViews[i].addArrangedSubview(arrivalPredictionTimesToStation[i])
			arrivalPredictionStationNames[i].setContentHuggingPriority(.init(249), for: .horizontal)
			arrivalPredictionTimesToStation[i].setContentCompressionResistancePriority(.init(751), for: .horizontal)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func viewModelDidChange() {
		guard let viewModel = viewModel else { return }
		viewModel.arrivalPredictionsDidChange = { [weak self] in
			self?.viewModelDidChange()
		}

		stationNameLabel.text = viewModel.name
		facilitiesLabel.text = viewModel.facilities

		for (i, prediction) in viewModel.arrivalPredictions
				.prefix(StationTableViewCellViewModel.arrivalPredictionsMaxViewCount).enumerated()
		{
			arrivalPredictionStackViews[i].isHidden = false
			arrivalPredictionStationNames[i].text = prediction.destinationName ?? ""
			arrivalPredictionTimesToStation[i].text = Self.arrivalDateFormatter.localizedString(
				fromTimeInterval: TimeInterval(prediction.timeToStation ?? 0)
			)
		}
	}
}
