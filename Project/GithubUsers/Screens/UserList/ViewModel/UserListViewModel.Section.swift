import Foundation

extension UserListViewModel {
    struct Section<T: Hashable>: Hashable {
        var id: UUID
        var title: String
        var items: [T]
    }
}
