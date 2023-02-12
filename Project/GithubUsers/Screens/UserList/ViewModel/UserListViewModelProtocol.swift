import Combine
import Foundation

protocol UserListViewModelProtocol {
    var title: String { get }
    var statePublisher: AnyPublisher<UserListViewModel.State, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    func bind(input: UserListViewModelInput)
    func set(coordinator: UserListCoordinator?)
}
