import AccessibilityIdentifiers
import XCTest

final class UserListScreen: ScreenBase {
    var userListCollectionView: XCUIElement { app.collectionViews[AccessibilityIdentifiers.UserListScreen.userListCollectionView.rawValue] }
    func userListCell(userId: String) -> XCUIElement { userListCollectionView.cells[AccessibilityIdentifiers.UserListScreen.userListCell.rawValue + "_" + userId] }
    var errorView: XCUIElement { app.otherElements[AccessibilityIdentifiers.ErrorView.view.rawValue] }
}
