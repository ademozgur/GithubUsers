import AccessibilityIdentifiers
import UIKit

final class ErrorView: UIView {
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
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityIdentifier = AccessibilityIdentifiers.ErrorView.view.rawValue
    }

    private lazy var errorIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.octagon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var errorDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [errorIcon, errorDescription])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()

    private func setupSubviews() {
        addSubview(rootStackView)
    }

    private func setupConstraints() {
        let errorIconHeight = errorIcon.heightAnchor.constraint(equalToConstant: 160)
        errorIconHeight.identifier = "errorIconHeight"

        NSLayoutConstraint.activate([
            errorIconHeight
        ])

        let padding: CGFloat = CGFloat(16)

        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            rootStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
