import Combine
import Foundation

protocol UserListViewModelProtocol {
    func bind(input: UserListViewModelInput) -> UserListViewModelOutput
    func set(coordinator: UserListCoordinator?)
}
