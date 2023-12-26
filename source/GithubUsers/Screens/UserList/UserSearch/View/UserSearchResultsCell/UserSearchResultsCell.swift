import UIKit

final class UserSearchResultsCell: UICollectionViewListCell {
    var searchResultItem: SearchResultItem?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = UserSearchResultCellContentConfiguration(searchResultItem: searchResultItem)
            .updated(for: state)
        newConfiguration.searchResultItem = searchResultItem
        contentConfiguration = newConfiguration

        var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell().updated(for: state)

        if state.isHighlighted || state.isSelected {
            newBgConfiguration.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        } else {
            newBgConfiguration.backgroundColor = .secondarySystemBackground
        }

        UIView.animate(withDuration: 0.3) {
            self.backgroundConfiguration = newBgConfiguration
        }
    }
}
