import UIKit

protocol ReusableIdentifiableView {
    static var identifier: String { get }
}

extension ReusableIdentifiableView {
    static var identifier: String {
        String(describing: Self.self)
    }
}

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell & ReusableIdentifiableView>(indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath)

        if let cell = cell as? T {
            return cell
        }

        return T(frame: .zero)
    }

    func dequeueSupplementaryView<T: UICollectionReusableView & ReusableIdentifiableView>(kind: String, at indexPath: IndexPath) -> T {
        let supplementaryView: T = dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: T.identifier,
                                                                    for: indexPath) as! T

        return supplementaryView
    }
}
