import AccessibilityIdentifiers
import Combine
import Factory
import UIKit

final class UserListViewController: UIViewController, HasCustomView {
    typealias CustomView = UserListView

    let viewModel: UserListViewModelProtocol
    private let viewDidLoadSignal = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UserListViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UserListView(viewModel: viewModel)
    }

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: activityIndicator)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.rightBarButtonItem = rightBarButtonItem

        doViewBindings()

        viewDidLoadSignal.send(())
    }

    private func doViewBindings() {
        let viewModelInput = UserListViewModelInput(viewDidLoadSignal: viewDidLoadSignal.eraseToAnyPublisher(),
                                                    onSelectItem: customView.collectionView.onSelectItemSignal,
                                                    didScrollToEnd: customView.collectionView.didScrollToEndSignal,
                                                    willDisplayItemSignal: customView.collectionView.willDisplayItemSignal)

        viewModel.bind(input: viewModelInput)
        bindActivityIndicatorAnimatingState()
        bindState()
    }

    private func bindState() {
        viewModel.statePublisher.sink { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .failed(let error):
                let alertController = UIAlertController(title: "Error",
                                                        message: error.localizedDescription,
                                                        preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alertController, animated: true)
            default:
                break
            }
        }.store(in: &cancellables)
    }

    private func bindActivityIndicatorAnimatingState() {
        viewModel.isLoading
            .sink(receiveValue: { [weak self] animating in
                self?.activityIndicator.toggle(animating: animating)
            })
            .store(in: &cancellables)
    }
}

extension Container {
    static let userListViewController = Factory { UserListViewController(viewModel: Container.userListViewModel()) }
}
