import Combine

struct UserDetailsViewModelInput {
    let viewDidLoadSignal: AnyPublisher<Void, Never>
    let viewDidDisappearSignal: AnyPublisher<Void, Never>
}
