import Combine
import Foundation
@testable import GithubUsers
import XCTest

final class UsersRepositoryTests: XCTestCase {
    func testFetchUsersFromRemote_whenCalled_itShouldReturnLastFetchedUserId() throws {
        // Given
        let usersRemoteDataSource = UsersRemoteDataSourceMock()
        usersRemoteDataSource.fetchUsersResult = .success([UserDetails.example, UserDetails.example2])

        let usersLocalDataSource = UsersLocalDataSourceMock()
        usersLocalDataSource.insertOrUpdateResult = .success([NSManagedObjectIDMock()])

        let sut = UsersRepository(usersRemoteDataSource: usersRemoteDataSource,
                                  usersLocalDataSource: usersLocalDataSource)

        // When
        let publisher = sut.fetchUsersFromRemote(since: nil)

        // Then
        let result = try awaitPublisher(publisher)
        XCTAssertEqual(try result.get(), UserDetails.example2.id)
    }

    func testFetchUsersFromRemote_whenRemoteFails_itShouldRelayTheError() throws {
        // Given
        let expectedError = URLError(.badServerResponse)
        let usersRemoteDataSource = UsersRemoteDataSourceMock()
        usersRemoteDataSource.fetchUsersResult = .failure(expectedError)

        let usersLocalDataSource = UsersLocalDataSourceMock()
        usersLocalDataSource.insertOrUpdateResult = .success([NSManagedObjectIDMock()])

        let sut = UsersRepository(usersRemoteDataSource: usersRemoteDataSource,
                                  usersLocalDataSource: usersLocalDataSource)

        // When
        let publisher = sut.fetchUsersFromRemote(since: nil)

        // Then
        let result = try awaitPublisher(publisher)
        switch result {
        case .success:
            break
        case .failure(let failure):
            XCTAssertEqual(expectedError, failure as! URLError)
        }
    }
}
