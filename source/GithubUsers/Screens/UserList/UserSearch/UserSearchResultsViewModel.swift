import Combine
import Factory
import Foundation

struct UserSearchResultsViewModelInput {
    let searchQuery: AnyPublisher<String, Never>
    let onSelectItem: AnyPublisher<SearchResultItem, Never>
}

struct UserSearchResultsViewModelOutput {
    var searchResults: AnyPublisher<[SearchResultItem], Never>
    var errors: AnyPublisher<Error, Never>
}

protocol UserSearchResultsViewModelProtocol {
    func set(coordinator: UserSearchResultsViewModelCoordinatorDelegate?)
    func bind(input: UserSearchResultsViewModelInput) -> UserSearchResultsViewModelOutput
}

struct SearchResultItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        lhs.value.id == rhs.value.id
    }

    var value: any UserProtocol
}

protocol UserSearchResultsViewModelCoordinatorDelegate: AnyObject {
    func didSelectUser(userId: String)
}

final class UserSearchResultsViewModel: UserSearchResultsViewModelProtocol {
    private let usersRepository: UsersRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: UserSearchResultsViewModelCoordinatorDelegate?
    private let errorSubject = PassthroughSubject<Error, Never>()

    init(usersRepository: UsersRepositoryProtocol) {
        self.usersRepository = usersRepository
    }

    func set(coordinator: UserSearchResultsViewModelCoordinatorDelegate?) {
        self.coordinator = coordinator
    }

    func bind(input: UserSearchResultsViewModelInput) -> UserSearchResultsViewModelOutput {
        let searchResults = input.searchQuery
            .compactMap { [weak self] query -> AnyPublisher<[any UserProtocol], Never>? in
                guard let self else { return nil }

                return self.usersRepository.search(query: query)
                    .catch { error -> AnyPublisher<[any UserProtocol], Never> in
                        self.errorSubject.send(error)
                        return Empty(completeImmediately: true).eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
            }
            .flatMap({ $0 })
            .eraseToAnyPublisher()
            .map({ users in
                users.map { user in
                    SearchResultItem(value: user)
                }
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        bind(onSelectItem: input.onSelectItem)

        return UserSearchResultsViewModelOutput(searchResults: searchResults,
                                                errors: errorSubject.eraseToAnyPublisher())
    }

    private func bind(onSelectItem: AnyPublisher<SearchResultItem, Never>) {
        onSelectItem.sink { [weak self] itemId in
            guard let self = self else { return }
            guard let login = itemId.value.login else { return }
            self.coordinator?.didSelectUser(userId: login)
        }.store(in: &cancellables)
    }
}

extension Container {
    static let userSearchResultsViewModel = Factory {
        UserSearchResultsViewModel(usersRepository: Container.usersRepository()) as UserSearchResultsViewModelProtocol
    }
}
