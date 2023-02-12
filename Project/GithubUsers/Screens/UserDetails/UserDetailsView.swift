import AccessibilityIdentifiers
import SDWebImage
import UIKit

final class UserDetailsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupSubviews()
        setupConstraints()
        backgroundColor = .systemBackground
    }

    func bind(avatarUrl: URL?) {
        guard let avatarUrl = avatarUrl else { return }
        imageView.sd_setImage(with: avatarUrl) { [weak self] _, _, _, _ in
            self?.imageView.isHidden = false
        }
    }

    func bind(error: Error?) {
        if let error {
            errorView.alpha = 1
            errorView.errorDescription.text = error.localizedDescription
        } else {
            errorView.alpha = 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = imageView.bounds.size.width / 2

        imageView.layer.cornerRadius = cornerRadius
        imageViewShadow.layer.shadowPath = UIBezierPath(roundedRect: imageViewShadow.bounds, cornerRadius: cornerRadius).cgPath
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        imageView.clipsToBounds = true

        let cornerRadius = imageView.bounds.size.width / 2

        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2

        imageView.accessibilityIdentifier = AccessibilityIdentifiers.UserDetailsScreen.imageView.rawValue

        imageView.isHidden = true

        return imageView
    }()

    private lazy var imageViewShadow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
        let cornerRadius = imageView.bounds.size.width / 2
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius).cgPath
        return view
    }()

    private lazy var imageViewWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageViewShadow)
        return view
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.accessibilityIdentifier = AccessibilityIdentifiers.UserDetailsScreen.nameLabel.rawValue
        return label
    }()

    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.accessibilityIdentifier = AccessibilityIdentifiers.UserDetailsScreen.followersLabel.rawValue
        return label
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.accessibilityIdentifier = AccessibilityIdentifiers.UserDetailsScreen.locationLabel.rawValue
        return label
    }()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageViewWrapper, nameLabel, followersLabel, locationLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()

    private var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.alpha = 0
        return errorView
    }()

    private func setupSubviews() {
        addSubview(rootStackView)
        addSubview(errorView)
    }

    private func setupConstraints() {
        let imageViewPadding = CGFloat(6)

        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: imageViewPadding),
            rootStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -imageViewPadding),
            rootStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageViewShadow.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageViewShadow.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: imageViewShadow.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageViewShadow.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageViewShadow.heightAnchor.constraint(equalTo: imageViewShadow.widthAnchor, multiplier: 1),
            imageViewShadow.widthAnchor.constraint(equalTo: imageViewWrapper.widthAnchor, multiplier: 0.60),
            imageViewShadow.centerXAnchor.constraint(equalTo: imageViewWrapper.centerXAnchor),
            imageViewShadow.centerYAnchor.constraint(equalTo: imageViewWrapper.centerYAnchor),
            imageViewShadow.topAnchor.constraint(greaterThanOrEqualTo: imageViewWrapper.topAnchor, constant: imageViewPadding),
            imageViewShadow.bottomAnchor.constraint(lessThanOrEqualTo: imageViewWrapper.bottomAnchor, constant: -imageViewPadding)
        ])

        NSLayoutConstraint.activate([
            imageViewWrapper.heightAnchor.constraint(equalTo: rootStackView.widthAnchor, multiplier: 0.65)
        ])

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
