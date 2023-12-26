import Combine
import Factory
import UIKit

protocol ReachabilityManagerProtocol { }

final class ReachabilityManager: ReachabilityManagerProtocol {
    private weak var window: UIWindow?
    private let reachability: ReachabilityProtocol
    private var cancellables = Set<AnyCancellable>()
    private var reachabilityView: ReachabilityView?

    init(window: UIWindow, reachability: ReachabilityProtocol) {
        self.window = window
        self.reachability = reachability

        startReachability()

        reachabilitySignal
            .map { [weak self] reachable -> Bool in
                guard let self = self else { return reachable }
                self.setupReachabilityView()
                return reachable
            }
            .sink(receiveValue: { [weak self] reachable in
                guard let self = self else { return }
                self.reachabilityView?.isHidden = reachable
            })
            .store(in: &cancellables)
    }

    private func setupReachabilityView() {
        guard let window = self.window else { return }
        guard reachabilityView == nil else { return }

        let windowBounds = window.bounds
        let viewHeight = CGFloat(60)
        let frame = CGRect(x: 0, y: windowBounds.height - viewHeight, width: windowBounds.size.width, height: viewHeight)
        let reachabilityView = ReachabilityView(frame: frame, delegate: self)
        window.addSubview(reachabilityView)
        NSLayoutConstraint.activate([
            reachabilityView.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor),
            reachabilityView.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor),
            reachabilityView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor)
        ])
        reachabilityView.isHidden = true
        self.reachabilityView = reachabilityView
    }

    private func startReachability() {
        do {
            try reachability.startNotifier()
        } catch {
            // TODO: Properly handle this error.
            print("could not start reachability notifier \(error)")
        }
    }

    private var reachabilitySignal: AnyPublisher<Bool, Never> {
        NotificationCenter.default.publisher(for: .reachabilityChanged)
            .map({ notification -> Bool in
                let reachability = notification.object as! Reachability

                switch reachability.connection {
                case .wifi, .cellular:
                    return true
                case .unavailable:
                    return false
                }
            })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension ReachabilityManager: ReachabilityViewDelegate {
    func didTapOnCloseButton() {
        reachabilityView?.isHidden = true
    }
}

extension Container {
    static var reachabilityManager = ParameterFactory<UIWindow, ReachabilityManagerProtocol> { window in
        ReachabilityManager(window: window, reachability: Container.reachability())
    }
}
