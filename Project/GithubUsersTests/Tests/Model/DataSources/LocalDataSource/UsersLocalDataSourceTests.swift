import XCTest
@testable import GithubUsers
import CoreData

final class NSManagedObjectIDMock: NSManagedObjectID {
    override var isTemporaryID: Bool {
        return false
    }

    override var persistentStore: NSPersistentStore? {
        return nil
    }

    override func uriRepresentation() -> URL {
        return URL(fileURLWithPath: "")
    }
}

extension UserDetails {
    static var example: UserDetails {
        UserDetails(id: 123, login: "adem", avatarUrl: "avatarUrl", name: "name", followers: 22, location: "Berlin")
    }
}

final class UsersLocalDataSourceTests: XCTestCase {
    func testInsertOrUpdate_whenCalled_thenDatabaseShouldHaveEntitiesInserted() throws {
        // Given
        let coreDataStorage = CoreDataStorage(storeType: NSInMemoryStoreType)
        let sut = UsersLocalDataSource(coreDataStorage: coreDataStorage)

        // When
        try sut.insertOrUpdate(users: [UserDetails.example])
        
        // Then
        let user = try sut.get(login: UserDetails.example.login)
        XCTAssertEqual(user.id, UserDetails.example.id)
    }

    func testGet_whenCalledWithValidObjectId_thenItShouldReturnCorrectEntity() throws {
        // Given
        let coreDataStorage = CoreDataStorage(storeType: NSInMemoryStoreType)
        let sut = UsersLocalDataSource(coreDataStorage: coreDataStorage)
        let objectId = try XCTUnwrap(
            try sut.insertOrUpdate(users: [UserDetails.example]).first
        )

        // When
        let user = try sut.get(objectId: objectId)

        // Then
        XCTAssertEqual(user.id, UserDetails.example.id)
    }

    func testGet_whenCalledWithNonExistingObjectId_thenItShouldThrowError() throws {
        // Given
        let coreDataStorage = CoreDataStorage(storeType: NSInMemoryStoreType)
        let sut = UsersLocalDataSource(coreDataStorage: coreDataStorage)

        // When
        XCTAssertThrowsError(try sut.get(objectId: NSManagedObjectIDMock()), "This user is not in the database!") { error in
            // Then
            XCTAssertEqual(error as! UsersLocalDataSource.Errors, UsersLocalDataSource.Errors.userNotFound)
        }
    }

    func testGet_whenCalledWithNonExistingLogin_thenItShouldReturnCorrectError() throws {
        // Given
        let coreDataStorage = CoreDataStorage(storeType: NSInMemoryStoreType)
        let sut = UsersLocalDataSource(coreDataStorage: coreDataStorage)

        // When
        XCTAssertThrowsError(try sut.get(login: "someRandomUserId"), "This user is not in the database!") { error in
            // Then
            XCTAssertEqual(error as! UsersLocalDataSource.Errors, UsersLocalDataSource.Errors.userNotFound)
        }
    }
}
