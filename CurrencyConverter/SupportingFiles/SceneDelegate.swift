
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewControllerID") as? MainViewController else { return }
        mainViewController.setup(
            screenshotService: ScreenshotService(),
            exchangeRateAPIService: ExchangeRateAPIService(),
            dateConverterService: DateConverterService(),
            exchangeRateCacheService: ExchangeRateCacheService(),
            tableViewCellService: TableViewCellService(),
            characterService: CharacterService()
        )
        
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }
}

