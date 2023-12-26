import Combine
import Foundation
@testable import GithubUsers

final class HttpNetworkingMock: HttpNetworking {
    static func getFileContent(file: String, fileExtension: String) -> Result<Data, Error> {
        let mockDataUrl = Bundle(for: HttpNetworkingMock.self)
            .url(forResource: file, withExtension: fileExtension)!

        let mockData = (try? Data(contentsOf: mockDataUrl))!

        return .success(mockData)
    }

    static let usersFileContent: Result<Data, Error> = getFileContent(file: "Users", fileExtension: "json")
    static let singleUserFileContent: Result<Data, Error> = getFileContent(file: "User", fileExtension: "json")
    static let failResponse: Result<Data, Error> = .failure(URLError(.badServerResponse))
    static let nonDecodableResponse: Result<Data, Error> = .success(Data())

    let result: Result<Data, Error>

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func loadData(from url: URL) -> AnyPublisher<Data, Error> {
        switch result {
        case .success(let success):
            return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let failure):
            return Fail(error: failure).eraseToAnyPublisher()
        }
    }
}
