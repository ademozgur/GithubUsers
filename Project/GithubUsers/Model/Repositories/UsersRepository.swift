import Combine
import CoreData
import Factory
import Foundation

protocol UsersRepositoryProtocol {
    func fetchUsersFromRemote(since: Int64?) -> AnyPublisher<Result<Int64?, Error>, Never>
    func fetchUserFromRemote(userId: String) -> AnyPublisher<Result<UserEntity, Error>, Never>
    func getUserFromLocalDatabase(objectId: NSManagedObjectID) -> AnyPublisher<Result<UserEntity, Error>, Never>
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

    func fetchUsersFromRemote(since: Int64? = nil) -> AnyPublisher<Result<Int64?, Error>, Never> {
        usersRemoteDataSource.fetchUsers(since: since)
            .map({ result -> Result<Int64?, Error> in
                switch result {
                case .success(let users):
                    do {
                        try usersLocalDataSource.insertOrUpdate(users: users)
                        let lasUserId = users.last?.id
                        return Result<Int64?, Error>.success(lasUserId)
                    } catch {
                        return Result<Int64?, Error>.failure(error)
                    }
                case .failure(let error):
                    return Result<Int64?, Error>.failure(error)
                }
            })
            .eraseToAnyPublisher()
    }

    func getUserFromLocalDatabase(objectId: NSManagedObjectID) -> AnyPublisher<Result<UserEntity, Error>, Never> {
        do {
            let user = try usersLocalDataSource.get(objectId: objectId)
            return Just(Result<UserEntity, Error>.success(user))
                .eraseToAnyPublisher()
        } catch {
            return Just(Result<UserEntity, Error>.failure(error))
                .eraseToAnyPublisher()
        }
    }

    func fetchUserFromRemote(userId: String) -> AnyPublisher<Result<UserEntity, Error>, Never> {
        usersRemoteDataSource.fetchUser(id: userId)
            .map({ result -> Result<UserEntity, Error> in
                switch result {
                case .success(let user):
                    do {
                        try usersLocalDataSource.insertOrUpdate(users: [user])
                        let user = try usersLocalDataSource.get(login: userId)
                        return Result<UserEntity, Error>.success(user)
                    } catch {
                        return Result<UserEntity, Error>.failure(error)
                    }
                case .failure(let error):
                    return Result<UserEntity, Error>.failure(error)
                }
            })
            .eraseToAnyPublisher()
    }
}

extension Container {
    static let usersRepository = Factory {
        UsersRepository(usersRemoteDataSource: Container.usersRemoteDataSource(),
                        usersLocalDataSource: Container.usersLocalDataSource()) as UsersRepositoryProtocol
    }
}
