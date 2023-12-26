import CoreData
import Factory
import UIKit

typealias CoreDataDataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>
typealias CoreDataSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

extension UICollectionViewCell {
    func shadowDecorate() {
        let radius: CGFloat = 10
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}

final class UserListCollectionViewDataSource: CoreDataDataSource {
    private let coreDataStorage: CoreDataStorageProtocol
    private var fetchedResultsController: NSFetchedResultsController<UserEntity>
    private weak var customCollectionView: UserListCollectionView?

    init(collectionView: UserListCollectionView, coreDataStorage: CoreDataStorageProtocol) {
        self.coreDataStorage = coreDataStorage
        self.customCollectionView = collectionView

        let fetchRequest = UserEntity.fetchRequest()

        let nameSort = NSSortDescriptor(key: "id", ascending: true)

        fetchRequest.sortDescriptors = [nameSort]
        fetchRequest.fetchBatchSize = 20

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStorage.mainContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell: UserListCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)

            guard let user = try? coreDataStorage.mainContext.existingObject(with: itemIdentifier) as? UserEntity else {
                return cell
            }
            cell.bind(user: user)
            cell.shadowDecorate()
            return cell
        }

        fetchedResultsController.delegate = self

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
        }
    }
}

extension UserListCollectionViewDataSource: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var snapshot = snapshot as CoreDataSnapshot
        let currentSnapshot = self.snapshot() as CoreDataSnapshot

        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
                return nil
            }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
            return itemIdentifier
        }
        snapshot.reloadItems(reloadIdentifiers)

        let shouldAnimate = customCollectionView?.numberOfSections != 0
        apply(snapshot, animatingDifferences: shouldAnimate)
    }
}

extension Container {
    static var userListCollectionViewDataSource = ParameterFactory<UserListCollectionView, UserListCollectionViewDataSource> { collectionView in
        let coreDataStorage = Container.coreDataStorage()
        return UserListCollectionViewDataSource(collectionView: collectionView, coreDataStorage: coreDataStorage)
    }
}
