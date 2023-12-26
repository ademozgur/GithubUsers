import Combine
import Foundation
@testable import GithubUsers

final class UsersRemoteDataSourceMock: UsersRemoteDataSourceProtocol {
    var fetchUsersResult: Result<[UserDetails], Error>?
    func fetchUsers(since: Int64?) -> AnyPublisher<[UserDetails], Error> {
        switch fetchUsersResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let failure):
            return Fail<[UserDetails], Error>(error: failure).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to .fetchUsersResult")
        }
    }

    var fetchUserResult: Result<UserDetails, Error>?
    func fetchUser(id: String) -> AnyPublisher<UserDetails, Error> {
        switch fetchUserResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let failure):
            return Fail<UserDetails, Error>(error: failure).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to .fetchUserResult")
        }
    }

    var searchResult: Result<[any UserProtocol], Error>?
    func search(query: String) -> AnyPublisher<[any UserProtocol], Error> {
        switch searchResult {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let failure):
            return Fail<[any UserProtocol], Error>(error: failure).eraseToAnyPublisher()
        case .none:
            fatalError("no value set to .searchResult")
        }
    }
}
