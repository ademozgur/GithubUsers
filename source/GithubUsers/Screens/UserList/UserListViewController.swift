import AccessibilityIdentifiers
import Combine
import Factory
import UIKit

final class UserListViewController: UIViewController, HasCustomView {
    typealias CustomView = UserListView

    let viewModel: UserListViewModelProtocol
    private let userSearchResultsViewController: UserSearchResultsViewController
    private let viewDidLoadSignal = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UserListViewModelProtocol, userSearchResultsViewController: UserSearchResultsViewController) {
        self.viewModel = viewModel
        self.userSearchResultsViewController = userSearchResultsViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UserListView()
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
        navigationItem.rightBarButtonItem = rightBarButtonItem
        doViewBindings()
        viewDidLoadSignal.send(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // doing the assignment after view appears to make it initially hidden.
        navigationItem.searchController = searchController
    }

    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: userSearchResultsViewController)
        search.searchResultsUpdater = userSearchResultsViewController
        let searchSignal = search.searchBar.searchTextField.textPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main).eraseToAnyPublisher()
        userSearchResultsViewController.bind(input: searchSignal)
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search"
        search.searchBar.autocapitalizationType = .none
        search.searchBar.returnKeyType = .done
        // search.showsSearchResultsController = true
        definesPresentationContext = true
        return search
    }()

    private func doViewBindings() {
        let viewModelInput = UserListViewModelInput(viewDidLoadSignal: viewDidLoadSignal.eraseToAnyPublisher(),
                                                    onSelectItem: customView.collectionView.onSelectItemSignal,
                                                    didScrollToEnd: customView.collectionView.didScrollToEndSignal,
                                                    willDisplayItemSignal: customView.collectionView.willDisplayItemSignal)

        let viewModelOutput = viewModel.bind(input: viewModelInput)
        bind(viewModelOutput: viewModelOutput)
    }

    private func bind(viewModelOutput: UserListViewModelOutput) {
        title = viewModelOutput.title
        bind(state: viewModelOutput.state)
        bind(isLoading: viewModelOutput.isLoading)
        customView.bind(state: viewModelOutput.state)
    }

    private func bind(state: AnyPublisher<UserListViewModel.State, Never>) {
        state.sink { [weak self] state in
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

    private func bind(isLoading: AnyPublisher<Bool, Never>) {
        isLoading
            .sink(receiveValue: { [weak self] animating in
                self?.activityIndicator.toggle(animating: animating)
            })
            .store(in: &cancellables)
    }
}

extension Container {
    static let userListViewController =
    ParameterFactory<UserSearchResultsViewController, UserListViewController> { params in
        UserListViewController(viewModel: Container.userListViewModel(), userSearchResultsViewController: params)
    }
}
