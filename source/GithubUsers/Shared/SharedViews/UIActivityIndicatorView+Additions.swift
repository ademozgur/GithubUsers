import UIKit

extension UIActivityIndicatorView {
    func toggle(animating: Bool) {
        if animating {
            startAnimating()
            return
        }

        stopAnimating()
    }
}
