import Foundation

extension UserDetailsViewModel {
    enum State: Equatable {
        case idle, loading, loaded
        case failed(Error)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
    }
}
