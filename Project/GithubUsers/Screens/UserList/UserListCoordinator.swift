import CoreData
import Factory
import Foundation

final class UserListCoordinator: BaseCoordinator {
    override func start() {
        let userListViewController = Container.userListViewController()
        userListViewController.viewModel.set(coordinator: self)
        displayer.setViewControllers([userListViewController], animated: false)
    }
}

extension UserListCoordinator: UserListViewModelCoordinatorDelegate {
    func didSelectUser(userId: NSManagedObjectID) {
        let baseCoordinatorParams = BaseCoordinatorParams(parentCoordinator: self, displayer: displayer)
        let userDetailsCoordinator = Container.userDetailsCoordinator(UserDetailsCoordinatorParams(userId: userId, baseCoordinatorParams: baseCoordinatorParams))
        store(coordinator: userDetailsCoordinator)
        userDetailsCoordinator.start()
    }
}

extension Container {
    static let userListCoordinator = ParameterFactory<BaseCoordinatorParams, Coordinator> { params in
        UserListCoordinator(params: params)
    }
}
