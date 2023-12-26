import CoreData
import Factory
import Foundation

final class UserListCoordinator: BaseCoordinator {
    override func start() {
        let baseCoordinatorParams = BaseCoordinatorParams(parentCoordinator: self, displayer: displayer)
        let userSearchResultsCoordinator = Container.userSearchResultsCoordinator(baseCoordinatorParams)
        store(coordinator: userSearchResultsCoordinator)
        let userSearchResultsViewController = Container.userSearchResultsViewController()
        userSearchResultsViewController.viewModel.set(coordinator: userSearchResultsCoordinator)

        let userListViewController = Container.userListViewController(userSearchResultsViewController)
        userListViewController.viewModel.set(coordinator: self)
        displayer.setViewControllers([userListViewController], animated: false)
    }
}

extension UserListCoordinator: UserListViewModelCoordinatorDelegate {
    func didSelectUser(userId: NSManagedObjectID) {
        let baseCoordinatorParams = BaseCoordinatorParams(parentCoordinator: self, displayer: displayer)
        let userDetailsCoordinatorParams = UserDetailsCoordinatorParams(userIdType: .coreData(userId),
                                                                        baseCoordinatorParams: baseCoordinatorParams)
        let userDetailsCoordinator = Container.userDetailsCoordinator(userDetailsCoordinatorParams)
        store(coordinator: userDetailsCoordinator)
        userDetailsCoordinator.start()
    }
}

extension Container {
    static let userListCoordinator = ParameterFactory<BaseCoordinatorParams, Coordinator> { params in
        UserListCoordinator(params: params)
    }
}
