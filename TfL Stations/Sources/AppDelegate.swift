import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {

		let tflApiService = TFLAPIService()
		let locationService = LocationService()
		let stationsVM = StationsViewModel(tflApiService: tflApiService, locationService: locationService)
		let stationsVC = StationsViewController(viewModel: stationsVM)
		let navigationController = UINavigationController(rootViewController: stationsVC)
		navigationController.navigationBar.prefersLargeTitles = true
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()

		return true
	}
}

