import Combine
import CoreData
import Foundation
@testable import GithubUsers

final class UsersLocalDataSourceMock: UsersLocalDataSourceProtocol {
    var getResult: Result<UserEntity, Error>?
    func get(login: String) throws -> UserEntity {
        switch getResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            fatalError("no value set to .fetchUsersResult")
        }
    }

    var getObjectResult: Result<UserEntity, Error>?
    func get<T>(objectId: NSManagedObjectID) throws -> T where T: UserEntity {
        switch getObjectResult {
        case .success(let success):
            return success as! T
        case .failure(let failure):
            throw failure
        case .none:
            fatalError("no value set to .fetchUsersResult")
        }
    }

    var insertOrUpdateResult: Result<[NSManagedObjectID], Error>?
    func insertOrUpdate(users: [UserDetails]) throws -> [NSManagedObjectID] {
        switch insertOrUpdateResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            fatalError("no value set to .fetchUsersResult")
        }
    }

    var searchResult: Result<[UserEntity], Error>?
    func search(query: String) throws -> [UserEntity] {
        switch searchResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            fatalError("no value set to .searchResult")
        }
    }
}
