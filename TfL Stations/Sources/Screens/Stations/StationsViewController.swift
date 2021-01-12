import UIKit

final class StationsViewController: UIViewController {
	private let tableView = UITableView()

	private var viewModel: StationsViewModel?

	init(viewModel: StationsViewModel) {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = viewModel
		viewModel.itemsDidChange = { [weak self] in
			self?.reloadTable()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = NSLocalizedString("stations.title", comment: "")
		view.backgroundColor = .systemBackground

		configureNavigationBar()

		configureTableView()
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
			view.topAnchor.constraint(equalTo: tableView.topAnchor),
			view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
		])

		viewModel?.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel?.viewWillAppear()
	}

	func reloadTable() {
		tableView.reloadData()
	}

	private func configureTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 300
		tableView.register(StationTableViewCell.self, forCellReuseIdentifier: StationTableViewCell.reuseIdentifier)
		tableView.tableFooterView = UIView()
	}

	private func configureNavigationBar() {
		let image = UIImage(systemName: "arrow.clockwise")
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: image,
			style: .plain,
			target: self,
			action: #selector(tapRefresh)
		)
	}

	@objc private func tapRefresh() {
		viewModel?.refreshTapped()
	}
}

// MARK: - UITableViewDataSource

extension StationsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel?.items.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let viewModel = viewModel else { return UITableViewCell() }

		let cellVM = viewModel.items[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: StationTableViewCell.reuseIdentifier, for: indexPath)
			as? StationTableViewCell
		cell?.viewModel = cellVM

		return cell ?? UITableViewCell()
	}
}

// MARK: - UITableViewDelegate

extension StationsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
