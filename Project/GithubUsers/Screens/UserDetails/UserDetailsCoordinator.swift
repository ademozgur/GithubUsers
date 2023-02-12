import CoreData
import Factory
import Foundation

struct UserDetailsCoordinatorParams {
    var userId: NSManagedObjectID
    var baseCoordinatorParams: BaseCoordinatorParams
}

final class UserDetailsCoordinator: BaseCoordinator {
    private let userId: NSManagedObjectID

    init(params: UserDetailsCoordinatorParams) {
        self.userId = params.userId
        super.init(params: params.baseCoordinatorParams)
    }

    override func start() {
        let userDetailsViewModel = UserDetailsViewModel(usersRepository: Container.usersRepository(), userId: userId)
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
