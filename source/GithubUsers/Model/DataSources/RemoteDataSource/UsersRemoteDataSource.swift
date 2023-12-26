import Combine
import Factory
import Foundation

protocol UsersRemoteDataSourceProtocol {
    func fetchUsers(since: Int64?) -> AnyPublisher<[UserDetails], Error>
    func fetchUser(id: String) -> AnyPublisher<UserDetails, Error>
    func search(query: String) -> AnyPublisher<[any UserProtocol], Error>
}

struct UsersRemoteDataSource: UsersRemoteDataSourceProtocol {
    private let networking: HttpNetworking
    private let urlConfigurations: RemoteUrlConfigurations

    init(networking: HttpNetworking, urlConfigurations: RemoteUrlConfigurations) {
        self.networking = networking
        self.urlConfigurations = urlConfigurations
    }

    func fetchUsers(since: Int64? = nil) -> AnyPublisher<[UserDetails], Error> {
        let url = urlConfigurations.userListUrl(since: since)
        return networking
            .loadData(from: url)
            .decode(type: [UserDetails].self, decoder: Data.jsonDecoder)
            .eraseToAnyPublisher()
    }

    func fetchUser(id: String) -> AnyPublisher<UserDetails, Error> {
        networking
            .loadData(from: urlConfigurations.singleUserUrl(id: id))
            .decode(type: UserDetails.self, decoder: Data.jsonDecoder)
            .eraseToAnyPublisher()
    }

    func search(query: String) -> AnyPublisher<[any UserProtocol], Error> {
        networking.loadData(from: urlConfigurations.searchUserUrl(query: query))
            .decode(type: SearchResponse<UserDetails>.self, decoder: Data.jsonDecoder)
            .map({ $0.items })
            .eraseToAnyPublisher()
    }
}

extension Container {
    static let usersRemoteDataSource = Factory {
        UsersRemoteDataSource(networking: Container.httpNetworking(),
                              urlConfigurations: Container.urlConfigurations()) as UsersRemoteDataSourceProtocol
    }
}
