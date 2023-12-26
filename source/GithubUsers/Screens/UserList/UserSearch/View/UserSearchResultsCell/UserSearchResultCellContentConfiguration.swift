import UIKit

struct UserSearchResultCellContentConfiguration: UIContentConfiguration, Hashable {
    var searchResultItem: SearchResultItem?

    var nameColor: UIColor = .label

    init(searchResultItem: SearchResultItem?) {
        self.searchResultItem = searchResultItem
    }

    func makeContentView() -> UIView & UIContentView {
        UserSearchResultContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfiguration = self

        if state.isSelected {
            updatedConfiguration.nameColor = .orange
        } else {
            updatedConfiguration.nameColor = .label
        }

        return updatedConfiguration
    }
}
