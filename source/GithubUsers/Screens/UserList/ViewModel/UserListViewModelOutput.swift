import Combine
import Foundation

struct UserListViewModelOutput {
    var title: String
    var state: AnyPublisher<UserListViewModel.State, Never>
    var isLoading: AnyPublisher<Bool, Never>
}
