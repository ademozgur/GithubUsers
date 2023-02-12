import Combine
import Factory
@testable import GithubUsers
import XCTest

final class UserListViewModelTests: XCTestCase {
    private let viewDidAppear = PassthroughSubject<Void, Never>()
    private let loadMore = PassthroughSubject<Void, Never>()
    private let onSelectItem = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

//    func testViewDidAppear_whenValuePassed_thenViewModelStateShouldChange() {
//        // Given
//        let mockedResponse = Result<[User], Error>.success([User(id: 1, login: "login", avatarUrl: "avatarUrl")])
//        let fetchUsersUseCaseMock = FetchUsersFromApiUseCaseMock(response: mockedResponse)
//        let sut = UserListViewModel(fetchUsersUseCase: fetchUsersUseCaseMock)
//
//        let expectation = expectation(description: "viewDidAppear")
//
//        var result = [UserListViewModel.State]()
//
//        sut.state.sink { state in
//            result.append(state)
//            if result.count == 3 {
//                expectation.fulfill()
//            }
//        }.store(in: &cancellables)
//
//        sut.bind(input: UserListViewModelInput(viewDidAppear: self.viewDidAppear.eraseToAnyPublisher(),
//                                               onSelectItem: onSelectItem.eraseToAnyPublisher(),
//                                               loadMore: loadMore.eraseToAnyPublisher()))
//
//        // When
//        self.viewDidAppear.send(())
//
//        wait(for: [expectation], timeout: 3)
//
//        // Then
//        XCTAssertEqual(result, [UserListViewModel.State.idle, UserListViewModel.State.loading, UserListViewModel.State.loaded])
//
//        // testing memory leak, it should be released
//        addTeardownBlock { [weak sut] in
//            XCTAssertNil(sut)
//        }
//    }
//
//    func testViewDidAppear_whenValuePassed_thenViewModelStateShouldChangeToFailure() {
//        // Given
//        let mockedResponse = Result<[User], Error>.failure(URLError(.badServerResponse))
//        let fetchUsersUseCaseMock = FetchUsersFromApiUseCaseMock(response: mockedResponse)
//        let sut = UserListViewModel(fetchUsersUseCase: fetchUsersUseCaseMock)
//
//        let expectation = expectation(description: "viewDidAppear")
//
//        var result: UserListViewModel.State?
//
//        sut.state.sink { state in
//            result = state
//
//            if case .failed = state {
//                expectation.fulfill()
//            }
//        }.store(in: &cancellables)
//
//        sut.bind(input: UserListViewModelInput(viewDidAppear: self.viewDidAppear.eraseToAnyPublisher(),
//                                               onSelectItem: onSelectItem.eraseToAnyPublisher(),
//                                               loadMore: loadMore.eraseToAnyPublisher()))
//
//        // When
//        self.viewDidAppear.send(())
//
//        wait(for: [expectation], timeout: 3)
//
//        // Then
//        switch result {
//        case .idle, .loading, .noResults, .loaded, .none:
//            XCTFail("The state should be .failed")
//        case .failed:
//            break
//        }
//
//        // testing memory leak, it should be released
//        addTeardownBlock { [weak sut] in
//            XCTAssertNil(sut)
//        }
//    }
}
