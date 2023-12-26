import Foundation

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
    func finish()
    var displayer: DisplayerProtocol { get }
}

extension Coordinator {
    func store(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func free(childCoordinator: Coordinator) {
        childCoordinators.removeAll { child in
            child === childCoordinator
        }
    }
}
