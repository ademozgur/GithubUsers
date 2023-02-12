import Combine
import Factory
@testable import GithubUsers
import XCTest

// final class UserDetailsViewModelTests: XCTestCase {
//    private let viewDidAppear = PassthroughSubject<Void, Never>()
//    private let viewDidDisappear = PassthroughSubject<Void, Never>()
//    private var cancellables = Set<AnyCancellable>()
//
//    func testViewDidAppear_whenValuePassed_thenViewModelStateShouldChange() {
//        // Given
//        let mockedResponse = Result<UserDetails, Error>.success(UserDetails(id: 1, login: "login", avatarUrl: "avatarUrl", name: "name", followers: 123))
//        let FetchSingleUserFromApiUseCaseMock = FetchSingleUserFromApiUseCaseMock(response: mockedResponse)
//        let sut = UserDetailsViewModel(FetchSingleUserFromApiUseCase: FetchSingleUserFromApiUseCaseMock, userId: "123")
//
//        let expectation = expectation(description: "viewDidAppear")
//
//        var result = [UserDetailsViewModel.State]()
//
//        sut.state.sink { state in
//            result.append(state)
//            if result.count == 3 {
//                expectation.fulfill()
//            }
//        }.store(in: &cancellables)
//
//        sut.bind(input: UserDetailsViewModelInput(viewDidAppear: viewDidAppear.eraseToAnyPublisher(),
//                                                  viewDidDisappear: viewDidDisappear.eraseToAnyPublisher()))
//
//        // When
//        self.viewDidAppear.send(())
//
//        wait(for: [expectation], timeout: 3)
//
//        // Then
//        XCTAssertEqual(result, [.idle, .loading, .loaded])
//    }
//
//    func testViewDidAppear_whenValuePassed_thenViewModelStateShouldChangeToFailure() {
//        // Given
//        let mockedResponse = Result<UserDetails, Error>.failure(URLError(.badServerResponse))
//        let FetchSingleUserFromApiUseCaseMock = FetchSingleUserFromApiUseCaseMock(response: mockedResponse)
//        let sut = UserDetailsViewModel(FetchSingleUserFromApiUseCase: FetchSingleUserFromApiUseCaseMock, userId: "123")
//
//        let expectation = expectation(description: "viewDidAppear")
//
//        var result: UserDetailsViewModel.State?
//
//        sut.state.sink { state in
//            result = state
//
//            if case .failed = state {
//                expectation.fulfill()
//            }
//        }.store(in: &cancellables)
//
//        sut.bind(input: UserDetailsViewModelInput(viewDidAppear: viewDidAppear.eraseToAnyPublisher(),
//                                                  viewDidDisappear: viewDidDisappear.eraseToAnyPublisher()))
//
//        // When
//        self.viewDidAppear.send(())
//
//        wait(for: [expectation], timeout: 3)
//
//        // Then
//        switch result {
//        case .idle, .loading, .loaded, .none:
//            XCTFail("The state should be .failed")
//        case .failed:
//            break
//        }
//    }
// }
