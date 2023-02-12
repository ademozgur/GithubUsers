import AccessibilityIdentifiers
import XCTest

final class UserDetailsScreen: ScreenBase {
    var imageView: XCUIElement { app.images[AccessibilityIdentifiers.UserDetailsScreen.imageView.rawValue] }
    var nameLabel: XCUIElement { app.staticTexts[AccessibilityIdentifiers.UserDetailsScreen.nameLabel.rawValue] }
    var followersLabel: XCUIElement { app.staticTexts[AccessibilityIdentifiers.UserDetailsScreen.followersLabel.rawValue] }
    var locationLabel: XCUIElement { app.staticTexts[AccessibilityIdentifiers.UserDetailsScreen.locationLabel.rawValue] }
    var errorView: XCUIElement { app.otherElements[AccessibilityIdentifiers.ErrorView.view.rawValue] }
}
