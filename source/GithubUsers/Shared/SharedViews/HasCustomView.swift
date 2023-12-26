import UIKit

public protocol HasCustomView {
    associatedtype CustomView: UIView
}

extension HasCustomView where Self: UIViewController {
    public var customView: CustomView {
        guard let customView = view as? CustomView else {
            // This is not a recoverable error, crash the app.
            fatalError("Expected view to be of type \(CustomView.self) but got \(type(of: view)) instead")
        }
        return customView
    }
}
