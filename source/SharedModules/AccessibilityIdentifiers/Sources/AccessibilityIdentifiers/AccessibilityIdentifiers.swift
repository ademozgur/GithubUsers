public enum AccessibilityIdentifiers {
    public enum ErrorView: String {
        case view = "ErrorView.view"
    }

    public enum UserListScreen: String {
        case userListCollectionView = "UserListScreen.userListCollectionView"
        case userListCell = "UserListScreen.userListCell"
        case userListCellNameLabel = "UserListScreen.userListCellNameLabel"
        case errorView = "UserListScreen.errorView"
    }

    public enum UserDetailsScreen: String {
        case imageView = "UserDetailsScreen.imageView"
        case nameLabel = "UserDetailsScreen.nameLabel"
        case followersLabel = "UserDetailsScreen.followersLabel"
        case locationLabel = "UserDetailsScreen.locationLabel"
    }
}
