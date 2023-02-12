import Combine
import Factory
import UIKit

final class UserListView: UIView {
    let viewModel: UserListViewModelProtocol
    let collectionView: UserListCollectionView
    let dataSource: UserListCollectionViewDataSource
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UserListViewModelProtocol) {
        self.viewModel = viewModel
        collectionView = UserListCollectionView()
        dataSource = Container.userListCollectionViewDataSource(collectionView)
        collectionView.diffableDataSource = dataSource

        super.init(frame: .zero)

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        setupSubviews()
        setupConstraints()

        bindState()
    }

    private func bindState() {
        viewModel.statePublisher.sink { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .failed/*(let error)*/:
                // self.errorView.isHidden = false
                // self.errorView.errorDescription.text = error.localizedDescription
                break
            default:
                self.errorView.isHidden = true
            }
        }.store(in: &cancellables)
    }

    private var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.isHidden = true
        return errorView
    }()

    private func setupSubviews() {
        backgroundColor = UIColor.systemBackground
        addSubview(collectionView)
        addSubview(errorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
