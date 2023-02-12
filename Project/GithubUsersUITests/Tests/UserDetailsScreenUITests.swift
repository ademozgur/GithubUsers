import AccessibilityIdentifiers
import Ambassador
import Embassy
import Foundation
import XCTest

final class UserDetailsScreenUITests: BaseTest {
    private let subjectUserId = "mojombo"

    func testUserDetailsScreenDisplayedCorrectly() {
        router.set(path: Routes.usersPath, response: UITestHelper.getDataResponse(file: "Users", fileExtension: "json"))
        router.set(path: Routes.singleUserPath(userId: subjectUserId), response: UITestHelper.getDataResponse(file: "User", fileExtension: "json"))

        launchApp()

        let userListScreen = UserListScreen(app: app)

        let userCell = userListScreen.userListCell(userId: subjectUserId)
        userCell.tapHittable()

        let userDetailsScreen = UserDetailsScreen(app: app)
        userDetailsScreen.imageView.waitForExist()
        userDetailsScreen.nameLabel.waitForExist()
        userDetailsScreen.followersLabel.waitForExist()
        userDetailsScreen.locationLabel.waitForExist()
    }

    func testErrorView_displayedCorrectly() {
        router.set(path: Routes.usersPath, response: UITestHelper.getDataResponse(file: "Users", fileExtension: "json"))
        router.set(path: Routes.singleUserPath(userId: subjectUserId), response: UITestHelper.errorResponse())

        launchApp()

        let userListScreen = UserListScreen(app: app)

        let userCell = userListScreen.userListCell(userId: subjectUserId)
        userCell.tapHittable()

        let userDetailsScreen = UserDetailsScreen(app: app)
        userDetailsScreen.errorView.waitForExist()
    }
}
