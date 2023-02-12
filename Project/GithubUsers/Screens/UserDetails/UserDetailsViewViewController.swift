import Combine
import UIKit

class UserDetailsViewViewController: UIViewController, HasCustomView {
    typealias CustomView = UserDetailsView

    private let viewDidLoadSignal = PassthroughSubject<Void, Never>()
    private let viewDidDisappearSignal = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    let viewModel: UserDetailsViewModelProtocol

    init(viewModel: UserDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: activityIndicator)
        return button
    }()

    override func loadView() {
        view = UserDetailsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = rightBarButtonItem

        bindViewModel()

        viewDidLoadSignal.send(())
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappearSignal.send(())
    }

    private func bindViewModel() {
        let userDetailsViewModelInput = UserDetailsViewModelInput(viewDidLoadSignal: viewDidLoadSignal.eraseToAnyPublisher(),
                                                                  viewDidDisappearSignal: viewDidDisappearSignal.eraseToAnyPublisher())

        viewModel.bind(input: userDetailsViewModelInput)

        viewModel.isAnimating
            .sink { [weak self] isAnimating in
                self?.activityIndicator.toggle(animating: isAnimating)
            }.store(in: &cancellables)

        viewModel.title.weakAssign(to: \.title, on: self).store(in: &cancellables)

        viewModel.user.map { $0?.name }.weakAssign(to: \.text, on: customView.nameLabel).store(in: &cancellables)

        viewModel.followersText.weakAssign(to: \.text, on: customView.followersLabel).store(in: &cancellables)

        viewModel.avatarUrl
            .sink(receiveValue: { [weak self] url in
                self?.customView.bind(avatarUrl: url)
            })
            .store(in: &cancellables)

        viewModel.location.weakAssign(to: \.text, on: customView.locationLabel).store(in: &cancellables)

        viewModel.errors.sink(receiveValue: { [weak self] error in
            self?.customView.bind(error: error)
        })
        .store(in: &cancellables)
    }
}
