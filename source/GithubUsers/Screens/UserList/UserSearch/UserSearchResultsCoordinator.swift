import Factory
import Foundation

final class UserSearchResultsCoordinator: BaseCoordinator {
    override func start() {
    }
}

extension UserSearchResultsCoordinator: UserSearchResultsViewModelCoordinatorDelegate {
    func didSelectUser(userId: String) {
        let baseCoordinatorParams = BaseCoordinatorParams(parentCoordinator: self, displayer: displayer)
        let userDetailsCoordinatorParams = UserDetailsCoordinatorParams(userIdType: .remote(userId),
                                                                        baseCoordinatorParams: baseCoordinatorParams)
        let userDetailsCoordinator = Container.userDetailsCoordinator(userDetailsCoordinatorParams)
        store(coordinator: userDetailsCoordinator)
        userDetailsCoordinator.start()
    }
}

extension Container {
    static let userSearchResultsCoordinator =
    ParameterFactory<BaseCoordinatorParams, UserSearchResultsCoordinator> { params in
        UserSearchResultsCoordinator(params: params)
    }
}
