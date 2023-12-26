import CoreData
import Factory
import UIKit

protocol CoreDataStorageProtocol {
    var mainContext: NSManagedObjectContext { get }
    func saveContext()
    func newBackgroundContext() -> NSManagedObjectContext
}

final class CoreDataStorage: CoreDataStorageProtocol {
    public var mainContext: NSManagedObjectContext {
        container.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }

    private let container: NSPersistentContainer

    private static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataStorage.self)
        let url = bundle.url(forResource: "Database", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }()

    /// Creates and returns a CoreDataStorage instance conforming `CoreDataStorageProtocol`
    /// - Parameters:
    ///   - modelName: The name of your .xcdatamodeld file
    ///   - storeType: For unit testing or swiftui previews, pass `NSInMemoryStoreType`
    init(modelName: String = "Database", storeType: String = NSSQLiteStoreType) {
        container = NSPersistentContainer(name: modelName, managedObjectModel: CoreDataStorage.managedObjectModel)
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true

        if storeType == NSInMemoryStoreType {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { [weak self] storeDescription, error in
            guard error != nil else { return }
            guard let storeUrl = storeDescription.url else { return }

            // assuming there is a serious problem with database, dropping and re-creating it.
            // a better solution should be implemented for this.
            // maybe disk is full?!
            do {
                try FileManager.default.removeItem(at: storeUrl)
                try self?.container.persistentStoreCoordinator.addPersistentStore(ofType: storeType,
                                                                                  configurationName: nil,
                                                                                  at: storeUrl)
            } catch {
            }
        }
    }

    public func saveContext() {
        guard container.viewContext.hasChanges else { return }

        do {
            try container.viewContext.save()
        } catch {
            print("An error occurred while saving: \(error)")
        }
    }
}

extension Container {
    static let coreDataStorage = Factory(scope: .singleton) {
        CoreDataStorage() as CoreDataStorageProtocol
    }
}
