import Combine
import Factory
import Foundation

protocol HttpNetworking {
    func loadData(from url: URL) -> AnyPublisher<Data, Error>
}

extension URLSession: HttpNetworking {
    enum Errors: Error, LocalizedError {
        case urlError(URLError)
    }

    func loadData(from url: URL) -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)

        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            })
            // .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

extension Container {
    static let httpNetworking = Factory(scope: .singleton) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return URLSession(configuration: configuration)  as HttpNetworking
    }
}
