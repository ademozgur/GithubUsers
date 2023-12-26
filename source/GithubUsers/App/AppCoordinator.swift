import Factory
import UIKit

class AppCoordinator: BaseCoordinator {
    private weak var window: UIWindow?
    private let reachabilityManager: ReachabilityManagerProtocol

    init(window: UIWindow, reachabilityManager: ReachabilityManagerProtocol) {
        self.window = window
        self.reachabilityManager = reachabilityManager

        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        super.init(displayer: navigationController)
    }

    override func start() {
        let userListCoordinator = Container.userListCoordinator(BaseCoordinatorParams(parentCoordinator: self, displayer: displayer))
        store(coordinator: userListCoordinator)
        userListCoordinator.start()
    }
}

extension Container {
    static var appCoordinator = ParameterFactory<UIWindow, Coordinator> { window in
        let reachabilityManager = Container.reachabilityManager(window)
        return AppCoordinator(window: window, reachabilityManager: reachabilityManager)
    }
}
