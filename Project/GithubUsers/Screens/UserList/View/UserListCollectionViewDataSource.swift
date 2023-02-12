import CoreData
import Factory
import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>
typealias Snapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

final class UserListCollectionViewDataSource: DataSource {
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
        var snapshot = snapshot as Snapshot
        let currentSnapshot = self.snapshot() as Snapshot

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
