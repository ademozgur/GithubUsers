import UIKit

final class UserSearchResultsView: UIView {
    let collectionView: UserSearchResultsCollectionView
    let dataSource: UserSearchResultsDataSource

    init(collectionView: UserSearchResultsCollectionView = UserSearchResultsCollectionView()) {
        self.collectionView = collectionView
        self.dataSource = UserSearchResultsDataSource(collectionView: collectionView)
        self.collectionView.diffableDataSource = self.dataSource
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .systemBackground
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: -5),
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 5),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
