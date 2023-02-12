import UIKit

protocol ReachabilityViewDelegate: AnyObject {
    func didTapOnCloseButton()
}

final class ReachabilityView: UIView {
    struct Constants {
        static let leftImageViewWidth: CGFloat = CGFloat(44)
        static let rootPadding: CGFloat = CGFloat(6)
    }

    weak var delegate: ReachabilityViewDelegate?

    init(frame: CGRect, delegate: ReachabilityViewDelegate?) {
        super.init(frame: frame)
        self.delegate = delegate
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.octagon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        // TODO: this should be localized.
        label.text = "No internet connection."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc func closeButtonTapped() {
        delegate?.didTapOnCloseButton()
    }

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel, closeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.rootPadding
        return stackView
    }()

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
        setupConstraints()
        backgroundColor = .secondarySystemBackground
    }

    private func setupSubviews() {
        addSubview(rootStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.rootPadding),
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.rootPadding),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.rootPadding),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.rootPadding)
        ])

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.leftImageViewWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.9)
        ])

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
    }
}
