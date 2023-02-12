@testable import GithubUsers
import XCTest

final class UsersRemoteDataSourceTests: XCTestCase {
    private let urlConfigurations = RemoteUrlConfigurations(baseUrl: "")

    func testFetchUsers_whenRemoteReturnsSuccessResponse_thenItShouldSucceed() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.usersFileContent)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUsers()
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()
        let actualResult = try publisherResult.get()
        XCTAssertEqual(actualResult.count, 30)
    }

    func testFetchUsers_whenRemoteReturnsFailureResponse_thenItShouldFail() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.failResponse)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUsers()
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()
        if case .success = publisherResult {
            XCTFail("This should fail")
        }
    }

    func testFetchUsers_whenRemoteReturnsNonDecodableResponse_thenItShouldFail() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.nonDecodableResponse)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUsers()
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()
        if case .success = publisherResult {
            XCTFail("This should fail")
        }
    }

    func testFetchSingleUser_whenRemoteReturnsSuccessResponse_thenItShouldSucceed() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.singleUserFileContent)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUser(id: "123")
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()

        if case .failure = publisherResult {
            XCTFail("This should succeed")
        }
    }

    func testFetchSingleUser_whenRemoteReturnsFailureResponse_thenItShouldFail() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.failResponse)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUser(id: "123")
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()
        if case .success = publisherResult {
            XCTFail("This should fail")
        }
    }

    func testFetchSingleUser_whenRemoteReturnsNonDecodableResponse_thenItShouldFail() throws {
        // Given
        let mockNetworking = HttpNetworkingMock(result: HttpNetworkingMock.nonDecodableResponse)
        let sut = UsersRemoteDataSource(networking: mockNetworking,
                                        urlConfigurations: urlConfigurations)

        // When
        let resultPublisher = sut.fetchUser(id: "123")
        let result = try awaitPublisher(resultPublisher)

        // Then
        let publisherResult = try result.get()
        if case .success = publisherResult {
            XCTFail("This should fail")
        }
    }
}
