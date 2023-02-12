import Foundation

extension UserListViewModel {
    enum State: Equatable {
        case idle, loading, noResults, loaded
        case failed(Error)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            case (.noResults, .noResults):
                return true
            default:
                return false
            }
        }
    }
}
