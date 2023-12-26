import AccessibilityIdentifiers
import Ambassador
import Embassy
import XCTest

final class UserListScreenUITests: BaseTest {
    func testUserListScreen_DisplayedCorrectly() throws {
        router.set(path: Routes.usersPath, response: UITestHelper.getDataResponse(file: "Users", fileExtension: "json"))
        launchApp()

        let subjectUserId = "mojombo"

        let userListScreen = UserListScreen(app: app)
        userListScreen.userListCollectionView.waitForExist()

        let userCell = userListScreen.userListCell(userId: subjectUserId)
        userCell.waitForExist()

        let firstNameLabel = userCell.staticTexts[AccessibilityIdentifiers.UserListScreen.userListCellNameLabel.rawValue]
        firstNameLabel.waitForExist()
        XCTAssertEqual(firstNameLabel.label, subjectUserId)
    }

    func testErrorView_DisplayedCorrectly() throws {
        router.set(path: Routes.usersPath, response: UITestHelper.errorResponse())

        launchApp()

        let userListScreen = UserListScreen(app: app)
        userListScreen.errorView.waitForExist()
    }
}
