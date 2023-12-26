import SDWebImage
import UIKit

typealias SearchResultsDataSource = UICollectionViewDiffableDataSource<String, SearchResultItem>
typealias SearchResultsSnapshot = NSDiffableDataSourceSnapshot<String, SearchResultItem>

final class UserSearchResultsDataSource: SearchResultsDataSource {
    private weak var customCollectionView: UICollectionView?

    init(collectionView: UICollectionView) {
        self.customCollectionView = collectionView

        let cellRegistration = UICollectionView.CellRegistration<UserSearchResultsCell, SearchResultItem> { (cell, _, item) in
            cell.searchResultItem = item
        }

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                    for: indexPath,
                                                                    item: itemIdentifier)
            cell.accessories = [.disclosureIndicator()]

            return cell
        }
    }
}
