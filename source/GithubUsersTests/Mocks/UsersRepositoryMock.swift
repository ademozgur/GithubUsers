import Combine
import CoreData
import Foundation
@testable import GithubUsers

final class UsersRepositoryMock: UsersRepositoryProtocol {
    var fetchUsersFromRemoteResult: Result<Int64?, Error>?

    func fetchUsersFromRemote(since: Int64?) -> AnyPublisher<Int64?, Error> {
        switch fetchUsersFromRemoteResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail<Int64?, Error>(error: error)
                .eraseToAnyPublisher()
        case .none:
            fatalError("no value set to `.fetchUsersFromRemoteResult`")
        }
    }

    var fetchUserFromRemoteResult: Result<UserEntity, Error>?
    func fetchUserFromRemote(userId: String?) -> AnyPublisher<UserEntity, Error> {
        switch fetchUserFromRemoteResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail<UserEntity, Error>(error: error).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to `.fetchUserFromRemoteResult`")
        }
    }

    var getUserFromLocalDatabaseResult: Result<UserEntity, Error>?
    func getUserFromLocalDatabase(objectId: NSManagedObjectID) -> AnyPublisher<UserEntity, Error> {
        switch getUserFromLocalDatabaseResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail<UserEntity, Error>(error: error).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to `.getUserFromLocalDatabaseResult`")
        }
    }

    var searchResult: Result<[any UserProtocol], Error>?
    func search(query: String) -> AnyPublisher<[any UserProtocol], Error> {
        switch searchResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail<[any UserProtocol], Error>(error: error).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to `.searchResult`")
        }
    }
}
