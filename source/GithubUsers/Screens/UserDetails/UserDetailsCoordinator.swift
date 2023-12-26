import CoreData
import Factory
import Foundation

enum UserIdType {
    case coreData(NSManagedObjectID)
    case remote(String)
}

struct UserDetailsCoordinatorParams {
    var userIdType: UserIdType
    var baseCoordinatorParams: BaseCoordinatorParams
}

final class UserDetailsCoordinator: BaseCoordinator {
    private let userIdType: UserIdType

    init(params: UserDetailsCoordinatorParams) {
        self.userIdType = params.userIdType
        super.init(params: params.baseCoordinatorParams)
    }

    override func start() {
        let userDetailsViewModel = UserDetailsViewModel(usersRepository: Container.usersRepository(), userIdType: userIdType)
        let userDetailsController = UserDetailsViewViewController(viewModel: userDetailsViewModel)
        userDetailsController.viewModel.set(coordinator: self)
        displayer.pushViewController(userDetailsController, animated: true)
    }
}

extension UserDetailsCoordinator: UserDetailsViewModelCoordinator {
}

extension Container {
    static let userDetailsCoordinator = ParameterFactory<UserDetailsCoordinatorParams, Coordinator> { params in
        UserDetailsCoordinator(params: params)
    }
}
