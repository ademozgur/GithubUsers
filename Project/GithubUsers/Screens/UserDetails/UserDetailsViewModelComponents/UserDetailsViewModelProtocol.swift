import Combine
import Foundation

protocol UserDetailsViewModelProtocol {
    var title: AnyPublisher<String?, Never> { get }
    var state: AnyPublisher<UserDetailsViewModel.State, Never> { get }
    var errors: AnyPublisher<Error?, Never> { get }
    var avatarUrl: AnyPublisher<URL?, Never> { get }
    var user: AnyPublisher<UserEntity?, Never> { get }
    var isAnimating: AnyPublisher<Bool, Never> { get }
    var followersText: AnyPublisher<String?, Never> { get }
    var location: AnyPublisher<String?, Never> { get }

    func bind(input: UserDetailsViewModelInput)
    func set(coordinator: UserDetailsViewModelCoordinator?)
}
