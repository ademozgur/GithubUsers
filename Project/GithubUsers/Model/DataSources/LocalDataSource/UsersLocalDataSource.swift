import CoreData
import Factory
import Foundation

protocol UsersLocalDataSourceProtocol {
    func get(login: String) throws -> UserEntity
    func get<T: UserEntity>(objectId: NSManagedObjectID) throws -> T

    @discardableResult
    func insertOrUpdate(users: [UserDetails]) throws -> [NSManagedObjectID]
}

struct UsersLocalDataSource: UsersLocalDataSourceProtocol {
    private let coreDataStorage: CoreDataStorageProtocol

    init(coreDataStorage: CoreDataStorageProtocol) {
        self.coreDataStorage = coreDataStorage
    }

    func get<T: UserEntity>(objectId: NSManagedObjectID) throws -> T {
        do {
            if let object = try coreDataStorage.mainContext.existingObject(with: objectId) as? T {
                return object
            }
            throw Errors.userNotFound
        } catch {
            throw Errors.userNotFound
        }
    }

    func get(login: String) throws -> UserEntity {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.fetchLimit = 1

        fetchRequest.entity = UserEntity.entity()

        let predicate = NSPredicate(format: "login = %@", login)

        fetchRequest.predicate = predicate

        let fetchResult = try coreDataStorage.mainContext.execute(fetchRequest) as? NSAsynchronousFetchResult<UserEntity>

        guard let user = fetchResult?.finalResult?.first else {
            throw Errors.userNotFound
        }

        return user
    }

    private func batchInsert(entityDescription: NSEntityDescription, objects: [[String: CustomStringConvertible]]) throws -> [NSManagedObjectID] {
        let bgContext = coreDataStorage.newBackgroundContext()
        bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let mainContext = coreDataStorage.mainContext

        var objectIds = [NSManagedObjectID]()

        try bgContext.performAndWait {
            let insertRequest = NSBatchInsertRequest(entity: entityDescription, objects: objects)
            insertRequest.resultType = NSBatchInsertRequestResultType.objectIDs
            let result = try bgContext.execute(insertRequest) as? NSBatchInsertResult

            if let insertedObjectIDs = result?.result as? [NSManagedObjectID], !insertedObjectIDs.isEmpty {
                let save = [NSInsertedObjectsKey: insertedObjectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [mainContext])
                objectIds.append(contentsOf: insertedObjectIDs)
            }
        }

        return objectIds
    }

    @discardableResult
    func insertOrUpdate(users: [UserDetails]) throws -> [NSManagedObjectID] {
        let usersDict = users.map { $0.toDictionary() }
        return try batchInsert(entityDescription: UserEntity.entity(), objects: usersDict)
    }
}

extension UsersLocalDataSource {
    enum Errors: LocalizedError {
        case userNotFound
    }
}

extension Container {
    static let usersLocalDataSource = Factory {
        UsersLocalDataSource(coreDataStorage: Container.coreDataStorage()) as UsersLocalDataSourceProtocol
    }
}
