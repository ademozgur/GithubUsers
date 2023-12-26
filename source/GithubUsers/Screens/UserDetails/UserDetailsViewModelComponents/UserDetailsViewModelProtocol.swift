import Combine
import Foundation

protocol UserDetailsViewModelProtocol {
    func bind(input: UserDetailsViewModelInput) -> UserDetailsViewModelOutput
    func set(coordinator: UserDetailsViewModelCoordinator?)
}
