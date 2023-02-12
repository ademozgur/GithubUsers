import Combine
import CoreData

struct UserListViewModelInput {
    let viewDidLoadSignal: AnyPublisher<Void, Never>
    let onSelectItem: AnyPublisher<NSManagedObjectID, Never>
    let didScrollToEnd: AnyPublisher<Void, Never>
    let willDisplayItemSignal: AnyPublisher<NSManagedObjectID, Never>
}
