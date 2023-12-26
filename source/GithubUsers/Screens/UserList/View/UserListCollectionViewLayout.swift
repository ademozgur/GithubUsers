import UIKit

final class UserListCollectionViewLayout: UICollectionViewCompositionalLayout {
    convenience init() {
        self.init { _, layoutEnvironment in
            let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500

            let itemWidth: NSCollectionLayoutDimension = isWideView ? .fractionalWidth(1/3) : .fractionalWidth(1/2)

            let itemSize = NSCollectionLayoutSize(widthDimension: itemWidth,
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            group.interItemSpacing = .flexible(0)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

            return section
        }
    }
}
