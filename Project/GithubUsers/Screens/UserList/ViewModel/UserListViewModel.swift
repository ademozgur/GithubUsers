import Combine
import CoreData
import Factory
import Foundation

final class UserListViewModel: UserListViewModelProtocol {
    let state = CurrentValueSubject<State, Never>(.idle)

    var statePublisher: AnyPublisher<UserListViewModel.State, Never> {
        state.eraseToAnyPublisher()
    }

    weak var coordinator: UserListViewModelCoordinatorDelegate?

    var title: String {
        "Github Users"
    }

    private var cancellables = Set<AnyCancellable>()

    private var lastFetchedUserId: Int64?

    private let usersRepository: UsersRepositoryProtocol

    init(usersRepository: UsersRepositoryProtocol) {
        self.usersRepository = usersRepository

        state.sink { state in
            print("state: \(state)")
        }.store(in: &cancellables)
    }

    private var reachabilitySignal: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: .reachabilityChanged)
            .map({ notification -> Bool in
                guard let reachability = notification.object as? Reachability else { return false }

                switch reachability.connection {
                case .wifi, .cellular:
                    return true
                case .unavailable:
                    return false
                }
            })
            // remove the duplicate signals generated switching from cellular to wi-fi or vice versa
            // it generates true + true in these cases
            .removeDuplicates()
            .compactMap({ connected -> Void? in
                connected ? () : nil
            })
            .eraseToAnyPublisher()
    }

    // This function binds some input signals from view to self.
    // view appearance, loadMore, etc.
    func bind(input: UserListViewModelInput) {
        // TODO: update on-screen items depending on reachability status.
        let viewDidLoadSignal = input.viewDidLoadSignal.first()
            .merge(with: reachabilitySignal)
            .eraseToAnyPublisher()

        let willDisplayItemSignal = input.willDisplayItemSignal
            .compactMap { [weak self] objectId -> AnyPublisher<Result<UserEntity, Error>, Never>? in
                print("willDisplayItemSignal \(objectId)")
                guard let self = self else { return nil }
                return self.usersRepository.getUserFromLocalDatabase(objectId: objectId)
            }
            .flatMap({ $0 })
            .compactMap { [weak self] result -> Void? in
                guard let self = self else { return nil }
                guard let lastFetchedUserId = self.lastFetchedUserId else { return nil }

                switch result {
                case .success(let userEntity):
                    return userEntity.id == lastFetchedUserId ? () : nil
                case .failure:
                    return nil
                }
            }
            .eraseToAnyPublisher()

        let mergedSignals = viewDidLoadSignal
            .merge(with: willDisplayItemSignal)
            .merge(with: input.didScrollToEnd)
            .eraseToAnyPublisher()

        triggerRemoteUserListFetch(signal: mergedSignals)
        bind(onSelectItem: input.onSelectItem)
    }

    private func triggerRemoteUserListFetch(signal: AnyPublisher<Void, Never>) {
        signal
            .compactMap { [weak self] _ -> AnyPublisher<Result<Int64?, Error>, Never>? in
                guard let self = self else { return nil }
                if case .loading = self.state.value { return nil }
                self.state.value = .loading
                let since = self.lastFetchedUserId
                return self.usersRepository.fetchUsersFromRemote(since: since)
            }
            .flatMap({ $0 })
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.state.value = .failed(error)
                case .success(let lastFetchedUserId):
                    self.lastFetchedUserId = lastFetchedUserId
                    self.state.value = .loaded
                }
            })
            .store(in: &cancellables)
    }

    private func bind(onSelectItem: AnyPublisher<NSManagedObjectID, Never>) {
        onSelectItem.sink { [weak self] itemId in
            guard let self = self else { return }
            self.coordinator?.didSelectUser(userId: itemId)
        }.store(in: &cancellables)
    }

    func set(coordinator: UserListCoordinator?) {
        self.coordinator = coordinator
    }

    var isLoading: AnyPublisher<Bool, Never> {
        state.map { state -> Bool in
            switch state {
            case .loading:
                return true
            case .idle, .loaded, .failed, .noResults:
                return false
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Container {
    static let userListViewModel = Factory {
        UserListViewModel(usersRepository: Container.usersRepository()) as UserListViewModelProtocol
    }
}
