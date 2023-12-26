import Combine
import Factory
import UIKit

final class UserSearchResultsViewController: UIViewController, HasCustomView {
    typealias CustomView = UserSearchResultsView
    private var cancellables = Set<AnyCancellable>()
    let viewModel: UserSearchResultsViewModelProtocol

    init(viewModel: UserSearchResultsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UserSearchResultsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bind(input: AnyPublisher<String, Never>) {
        let input = UserSearchResultsViewModelInput(searchQuery: input,
                                                    onSelectItem: customView.collectionView.onSelectItemSignal)
        let output = viewModel.bind(input: input)

        bind(searchResults: output.searchResults)
        bind(errors: output.errors)
    }

    private func bind(searchResults: AnyPublisher<[SearchResultItem], Never>) {
        searchResults.sink { [weak self] users in
            guard let self = self else { return }

            var snapshot = SearchResultsSnapshot()
            snapshot.appendSections(["test"])
            snapshot.appendItems(users)
            self.customView.dataSource.apply(snapshot)
        }.store(in: &cancellables)
    }

    private func bind(errors: AnyPublisher<Error, Never>) {
        errors.sink { error in
            print(error)
        }.store(in: &cancellables)
    }
}

extension UserSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}

extension Container {
    static let userSearchResultsViewController = Factory {
        UserSearchResultsViewController(viewModel: Container.userSearchResultsViewModel())
    }
}
