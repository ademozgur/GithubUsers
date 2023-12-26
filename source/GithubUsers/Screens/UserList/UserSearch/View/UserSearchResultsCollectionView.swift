import Combine
import UIKit

final class UserSearchResultsCollectionView: UICollectionView {
    weak var diffableDataSource: UserSearchResultsDataSource?
    private let onSelectItem = PassthroughSubject<SearchResultItem, Never>()
    let onSelectItemSignal: AnyPublisher<SearchResultItem, Never>

    init(layout: UserSearchResultsCollectionViewLayout = UserSearchResultsCollectionViewLayout()) {
        self.onSelectItemSignal = onSelectItem.eraseToAnyPublisher()

        var separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .insetGrouped)
        separatorConfiguration.topSeparatorInsets = NSDirectionalEdgeInsets.zero
        separatorConfiguration.bottomSeparatorInsets = NSDirectionalEdgeInsets.zero

        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.backgroundColor = .systemBackground
        layoutConfig.separatorConfiguration = separatorConfiguration

        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        super.init(frame: .zero, collectionViewLayout: listLayout)
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = true
        delegate = self
        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

 extension UserSearchResultsCollectionView: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         collectionView.deselectItem(at: indexPath, animated: true)

         guard let snapshot = diffableDataSource?.snapshot() else { return }
         let objectId = snapshot.itemIdentifiers[indexPath.item]
         onSelectItem.send(objectId)
     }
 }
