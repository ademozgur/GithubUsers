import Combine
import Foundation

struct UserDetailsViewModelOutput {
    var title: AnyPublisher<String?, Never>
    var state: AnyPublisher<UserDetailsViewModel.State, Never>
    var errors: AnyPublisher<Error?, Never>
    var avatarUrl: AnyPublisher<URL?, Never>
    var user: AnyPublisher<UserEntity?, Never>
    var isAnimating: AnyPublisher<Bool, Never>
    var followersText: AnyPublisher<String?, Never>
    var location: AnyPublisher<String?, Never>
}
