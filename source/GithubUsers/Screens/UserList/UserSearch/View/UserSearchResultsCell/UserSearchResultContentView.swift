import UIKit

final class UserSearchResultContentView: UIView, UIContentView {
    private var currentConfiguration: UserSearchResultCellContentConfiguration

    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? UserSearchResultCellContentConfiguration else { return }
            guard newConfiguration != currentConfiguration else { return }
            currentConfiguration = newConfiguration
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: UserSearchResultCellContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(configuration: UserSearchResultCellContentConfiguration) {
        nameLabel.text = configuration.searchResultItem?.value.login
        nameLabel.textColor = configuration.nameColor
        imageView.sd_setImage(with: URL(string: configuration.searchResultItem?.value.avatarUrl ?? ""))
    }

    private(set) var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tertiarySystemBackground

        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 50)
        heightConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 50),
            heightConstraint
        ])
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private(set) var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()

    private func setupSubviews() {
        addSubview(rootStackView)
    }

    private func setupConstraints() {
        let padding = CGFloat(0)
        let bottomConstraint = rootStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -padding)
        bottomConstraint.priority = .defaultHigh
        let heightConstraint = rootStackView.heightAnchor.constraint(equalToConstant: 44)
        heightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: padding),
            rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -padding),
            rootStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding),
            bottomConstraint,
            heightConstraint
        ])
    }
}
