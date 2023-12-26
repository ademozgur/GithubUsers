import Foundation

struct BaseCoordinatorParams {
    var parentCoordinator: Coordinator?
    var displayer: DisplayerProtocol
}

class BaseCoordinator: Coordinator {
    func start() { }

    weak var parentCoordinator: Coordinator?

    var childCoordinators: [Coordinator] = []

    let displayer: DisplayerProtocol

    init(displayer: DisplayerProtocol, parentCoordinator: Coordinator? = nil) {
        self.parentCoordinator = parentCoordinator
        self.displayer = displayer
    }

    init(params: BaseCoordinatorParams) {
        self.parentCoordinator = params.parentCoordinator
        self.displayer = params.displayer
    }

    func finish() {
        parentCoordinator?.free(childCoordinator: self)
    }
}
