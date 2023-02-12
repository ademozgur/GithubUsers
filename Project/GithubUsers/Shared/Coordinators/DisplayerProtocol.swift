import UIKit

protocol DisplayerProtocol {
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    func pushViewController(_ viewController: UIViewController, animated: Bool)
}

extension UINavigationController: DisplayerProtocol {}
