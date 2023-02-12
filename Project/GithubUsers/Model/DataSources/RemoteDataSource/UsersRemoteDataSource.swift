import Combine
import Factory
import Foundation

protocol UsersRemoteDataSourceProtocol {
    func fetchUsers(since: Int64?) -> AnyPublisher<Result<[UserDetails], Error>, Never>
    func fetchUser(id: String) -> AnyPublisher<Result<UserDetails, Error>, Never>
}

struct UsersRemoteDataSource: UsersRemoteDataSourceProtocol {
    private let networking: HttpNetworking
    private let urlConfigurations: RemoteUrlConfigurations

    init(networking: HttpNetworking, urlConfigurations: RemoteUrlConfigurations) {
        self.networking = networking
        self.urlConfigurations = urlConfigurations
    }

    func fetchUsers(since: Int64? = nil) -> AnyPublisher<Result<[UserDetails], Error>, Never> {
        let url = urlConfigurations.userListUrl(since: since)
        return networking
            .loadData(from: url)
            .map({ result in
                switch result {
                case .success(let data):
                    do {
                        let value: [UserDetails] = try data.decode()
                        return .success(value)
                    } catch {
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            })
            .eraseToAnyPublisher()
    }

    func fetchUser(id: String) -> AnyPublisher<Result<UserDetails, Error>, Never> {
        networking
            .loadData(from: urlConfigurations.singleUserUrl(id: id))
            .map({ result in
                switch result {
                case .success(let data):
                    do {
                        let value: UserDetails = try data.decode()
                        return .success(value)
                    } catch {
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            })
            .eraseToAnyPublisher()
    }
}

extension Container {
    static let usersRemoteDataSource = Factory {
        UsersRemoteDataSource(networking: Container.httpNetworking(),
                              urlConfigurations: Container.urlConfigurations()) as UsersRemoteDataSourceProtocol
    }
}
