import Combine
import Factory
import Foundation

protocol HttpNetworking {
    func loadData(from url: URL) -> AnyPublisher<Result<Data, Error>, Never>
}

extension URLSession: HttpNetworking {
    enum Errors: Error, LocalizedError {
        case urlError(URLError)
    }

    func loadData(from url: URL) -> AnyPublisher<Result<Data, Error>, Never> {
        let request = URLRequest(url: url)

        return dataTaskPublisher(for: request)
            .map({ response -> Result<Data, Error> in
                guard let httpResponse = response.response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
                    return .failure(URLError(.badServerResponse))
                }
                return .success(response.data)
            })
            .catch({ failure -> Just<Result<Data, Error>> in
                Just(.failure(failure))
            })
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
