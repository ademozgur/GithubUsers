import AccessibilityIdentifiers
import Combine
import CoreData
import UIKit

final class UserListCollectionView: UICollectionView {
    struct Constants {
        static let loadMoreTriggerScrollOffset: CGFloat = CGFloat(300)
    }

    private let itemsPerRow: Int
    private let cellSpacing: CGFloat
    private var sectionInsets: UIEdgeInsets {
        UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
    }
    private var cancellables = Set<AnyCancellable>()
    private let onSelectItem = PassthroughSubject<NSManagedObjectID, Never>()
    let onSelectItemSignal: AnyPublisher<NSManagedObjectID, Never>

    private let didScrollToEnd = PassthroughSubject<Void, Never>()
    let didScrollToEndSignal: AnyPublisher<Void, Never>

    private let willDisplayItem = PassthroughSubject<NSManagedObjectID, Never>()
    let willDisplayItemSignal: AnyPublisher<NSManagedObjectID, Never>

    weak var diffableDataSource: UserListCollectionViewDataSource?

    init(cellSpacing: CGFloat = CGFloat(16), itemsPerRow: Int = 2) {
        self.cellSpacing = cellSpacing
        self.itemsPerRow = itemsPerRow
        self.onSelectItemSignal = onSelectItem.eraseToAnyPublisher()
        self.didScrollToEndSignal = didScrollToEnd.eraseToAnyPublisher()
        self.willDisplayItemSignal = willDisplayItem.eraseToAnyPublisher()

        super.init(frame: .zero, collectionViewLayout: UserListCollectionViewLayout())

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        register(UserListCollectionViewCell.self, forCellWithReuseIdentifier: UserListCollectionViewCell.identifier)
        register(UserListCollectionViewSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: UserListCollectionViewSectionHeaderView.identifier)
        alwaysBounceVertical = true
        clipsToBounds = true
        allowsMultipleSelection = false
        delegate = self
        backgroundColor = .systemBackground
        accessibilityIdentifier = AccessibilityIdentifiers.UserListScreen.userListCollectionView.rawValue

        publisher(for: \.contentOffset)
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] scrollPoint in
                guard let self = self else { return }

                let scrollDiff = max(0, self.contentSize.height - scrollPoint.y - self.bounds.size.height)

                if self.contentSize.height > self.bounds.size.height,
                   scrollDiff < Constants.loadMoreTriggerScrollOffset {
                    self.didScrollToEnd.send(())
                }
            }
            .store(in: &cancellables)
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserListCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let snapshot = diffableDataSource?.snapshot() else { return }
        let objectId = snapshot.itemIdentifiers[indexPath.item]
        onSelectItem.send(objectId)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        cell.layer.opacity = 0.5
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)  else { return }

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            cell.layer.opacity = 1
        } completion: { _ in
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let snapshot = diffableDataSource?.snapshot(), let firstSection = snapshot.sectionIdentifiers.first else { return }
        let sectionItems = snapshot.itemIdentifiers(inSection: firstSection)
        let identifier = sectionItems[indexPath.item]
        willDisplayItem.send(identifier)
    }
}
