import Combine
import CoreData
import Factory
import Foundation

protocol UsersRepositoryProtocol {
    func fetchUsersFromRemote(since: Int64?) -> AnyPublisher<Int64?, Error>
    func fetchUserFromRemote(userId: String?) -> AnyPublisher<UserEntity, Error>
    func getUserFromLocalDatabase(objectId: NSManagedObjectID) -> AnyPublisher<UserEntity, Error>
    func search(query: String) -> AnyPublisher<[any UserProtocol], Error>
}

struct UsersRepository: UsersRepositoryProtocol {
    private let usersRemoteDataSource: UsersRemoteDataSourceProtocol
    private let usersLocalDataSource: UsersLocalDataSourceProtocol

    private var cancellables = Set<AnyCancellable>()

    init(usersRemoteDataSource: UsersRemoteDataSourceProtocol,
         usersLocalDataSource: UsersLocalDataSourceProtocol) {
        self.usersRemoteDataSource = usersRemoteDataSource
        self.usersLocalDataSource = usersLocalDataSource
    }

    func fetchUsersFromRemote(since: Int64? = nil) -> AnyPublisher<Int64?, Error> {
        usersRemoteDataSource.fetchUsers(since: since)
            .tryMap({ users in
                try usersLocalDataSource.insertOrUpdate(users: users)
                let lasUserId = users.last?.id
                return lasUserId
            })
            .eraseToAnyPublisher()
    }

    func getUserFromLocalDatabase(objectId: NSManagedObjectID) -> AnyPublisher<UserEntity, Error> {
        do {
            let user = try usersLocalDataSource.get(objectId: objectId)
            return Just(user).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    func fetchUserFromRemote(userId: String?) -> AnyPublisher<UserEntity, Error> {
        guard let userId else {
            return Fail<UserEntity, Error>(error: Errors.userNotFound).eraseToAnyPublisher()
        }
        return usersRemoteDataSource.fetchUser(id: userId)
            .tryMap({ userDetails in
                try usersLocalDataSource.insertOrUpdate(users: [userDetails])
                let user = try usersLocalDataSource.get(login: userId)
                return user
            })
            .eraseToAnyPublisher()
    }

    func search(query: String) -> AnyPublisher<[any UserProtocol], Error> {
        return usersRemoteDataSource.search(query: query)
    }
}

extension UsersRepository {
    enum Errors: Error, LocalizedError {
        case userNotFound
    }
}

extension Container {
    static let usersRepository = Factory {
        UsersRepository(usersRemoteDataSource: Container.usersRemoteDataSource(),
                        usersLocalDataSource: Container.usersLocalDataSource()) as UsersRepositoryProtocol
    }
}
