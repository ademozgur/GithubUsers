import Combine
import CoreData
import Factory
import Foundation

protocol UserDetailsViewModelCoordinator: AnyObject {
    func finish()
}

final class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let state = CurrentValueSubject<State, Never>(.idle)
    private let user = CurrentValueSubject<UserEntity?, Never>(nil)
    weak var coordinator: UserDetailsViewModelCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private let userIdType: UserIdType
    private let usersRepository: UsersRepositoryProtocol

    init(usersRepository: UsersRepositoryProtocol, userIdType: UserIdType) {
        self.usersRepository = usersRepository
        self.userIdType = userIdType
    }

    func bind(input: UserDetailsViewModelInput) -> UserDetailsViewModelOutput {
        bind(viewDidDisappearSignal: input.viewDidDisappearSignal)
        bind(viewDidLoadSignal: input.viewDidLoadSignal)

        return UserDetailsViewModelOutput(title: title,
                                          state: state.eraseToAnyPublisher(),
                                          errors: errors.eraseToAnyPublisher(),
                                          avatarUrl: avatarUrl,
                                          user: user.eraseToAnyPublisher(),
                                          isAnimating: isAnimating,
                                          followersText: followersText,
                                          location: location)
    }

    private func bind(viewDidDisappearSignal: AnyPublisher<Void, Never>) {
        viewDidDisappearSignal.sink { [weak self] _ in
            self?.coordinator?.finish()
        }.store(in: &cancellables)
    }

    private func bind(viewDidLoadSignal: AnyPublisher<Void, Never>) {
        viewDidLoadSignal
            .compactMap { [weak self] _ -> AnyPublisher<UserEntity, Never>? in
                guard let self = self else { return nil }
                self.state.send(.loading)
                switch self.userIdType {
                case .coreData(let managedObjectId):
                    return self.usersRepository.getUserFromLocalDatabase(objectId: managedObjectId)
                        .flatMap({ (userEntity: UserEntity) in
                            self.usersRepository.fetchUserFromRemote(userId: userEntity.login)
                        })
                        .catch({ error in
                            self.state.value = .failed(error)
                            return Empty<UserEntity, Never>().eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                case .remote(let userId):
                    return self.usersRepository.fetchUserFromRemote(userId: userId)
                        .catch({ error in
                            self.state.value = .failed(error)
                            return Empty<UserEntity, Never>().eraseToAnyPublisher()
                        }).eraseToAnyPublisher()
                }
            }
            .flatMap({ $0 })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] user in
                guard let self = self else { return }
                self.user.send(user)
                self.state.send(.loaded)
            })
            .store(in: &cancellables)
    }

    func set(coordinator: UserDetailsViewModelCoordinator?) {
        self.coordinator = coordinator
    }

    private var errors: AnyPublisher<Error?, Never> {
        state
            .map { state -> Error? in
                switch state {
                case .failed(let error):
                    return error
                default:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    private var avatarUrl: AnyPublisher<URL?, Never> {
        user.map { $0?.avatarUrl }
            .compactMap { $0 }
            .map { URL(string: $0) }
            .eraseToAnyPublisher()
    }

    private var title: AnyPublisher<String?, Never> {
        state.eraseToAnyPublisher()
            .combineLatest(user.eraseToAnyPublisher()) { state, user -> String? in
                switch state {
                case .idle:
                    return nil
                case .loading:
                    return "Loading..."
                case .loaded:
                    return user?.name ?? user?.login ?? "User Details"
                case .failed:
                    return "Failed"
                }
            }.eraseToAnyPublisher()
    }

    private var isAnimating: AnyPublisher<Bool, Never> {
        state
            .map { state in
                switch state {
                case .loading:
                    return true
                case .idle, .loaded, .failed:
                    return false
                }
            }
            .eraseToAnyPublisher()
    }

    private var followersText: AnyPublisher<String?, Never> {
        user.dropFirst()
            .map { user in
                "Followers: \(user?.followers ?? 0)"
            }
            .eraseToAnyPublisher()
    }

    private var location: AnyPublisher<String?, Never> {
        user.dropFirst()
            .map { user in
                "Location: " + (user?.location ?? "")
            }
            .eraseToAnyPublisher()
    }
}
