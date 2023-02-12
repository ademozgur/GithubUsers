import Combine
import CoreData
import Factory
import Foundation

protocol UserDetailsViewModelCoordinator: AnyObject {
    func finish()
}

struct UserDetailsViewModelInput {
    let viewDidLoadSignal: AnyPublisher<Void, Never>
    let viewDidDisappearSignal: AnyPublisher<Void, Never>
}

final class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let stateInternal = CurrentValueSubject<State, Never>(.idle)
    private let userInternal = CurrentValueSubject<UserEntity?, Never>(nil)
    weak var coordinator: UserDetailsViewModelCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private let userId: NSManagedObjectID
    private let usersRepository: UsersRepositoryProtocol

    init(usersRepository: UsersRepositoryProtocol, userId: NSManagedObjectID) {
        self.usersRepository = usersRepository
        self.userId = userId
    }

    func bind(input: UserDetailsViewModelInput) {
        bind(viewDidDisappearSignal: input.viewDidDisappearSignal)
        bind(viewDidLoadSignal: input.viewDidLoadSignal)
    }

    private func bind(viewDidDisappearSignal: AnyPublisher<Void, Never>) {
        viewDidDisappearSignal.sink { [weak self] _ in
            self?.coordinator?.finish()
        }.store(in: &cancellables)
    }

    private func bind(viewDidLoadSignal: AnyPublisher<Void, Never>) {
        viewDidLoadSignal.first()
            .map { _ in
                State.loading
            }
            .weakAssign(to: \.value, on: stateInternal)
            .store(in: &cancellables)

        viewDidLoadSignal
            .compactMap { [weak self] _ -> AnyPublisher<Result<UserEntity, Error>, Never>? in
                guard let self = self else { return nil }
                return self.usersRepository.getUserFromLocalDatabase(objectId: self.userId)
            }
            .flatMap({ $0 })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .map({ result in
                switch result {
                case .success(let user):
                    self.userInternal.value = user
                    self.triggerRemoteUserFetch(userId: user.login)
                case .failure(let error):
                    self.stateInternal.value = .failed(error)
                }
                return result
            })
            .sink(receiveValue: { _ in
            })
            .store(in: &cancellables)
    }

    private func triggerRemoteUserFetch(userId: String?) {
        guard let userId = userId else { return }

        usersRepository.fetchUserFromRemote(userId: userId)
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    self.stateInternal.value = .failed(error)
                case .success(let user):
                    self.stateInternal.value = .loaded
                    self.userInternal.value = user
                }
            }.store(in: &cancellables)
    }

    func set(coordinator: UserDetailsViewModelCoordinator?) {
        self.coordinator = coordinator
    }

    var errors: AnyPublisher<Error?, Never> {
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

    var avatarUrl: AnyPublisher<URL?, Never> {
        user.map { $0?.avatarUrl }
            .compactMap { $0 }
            .map { URL(string: $0) }
            .eraseToAnyPublisher()
    }

    var state: AnyPublisher<State, Never> {
        stateInternal.eraseToAnyPublisher()
    }

    var user: AnyPublisher<UserEntity?, Never> {
        userInternal.eraseToAnyPublisher()
    }

    var title: AnyPublisher<String?, Never> {
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

    var isAnimating: AnyPublisher<Bool, Never> {
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

    var followersText: AnyPublisher<String?, Never> {
        user.dropFirst()
            .map { user in
                "Followers: \(user?.followers ?? 0)"
            }
            .eraseToAnyPublisher()
    }

    var location: AnyPublisher<String?, Never> {
        user.dropFirst()
            .map { user in
                "Location: " + (user?.location ?? "")
            }
            .eraseToAnyPublisher()
    }
}
