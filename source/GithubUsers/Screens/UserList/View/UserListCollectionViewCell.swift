import AccessibilityIdentifiers
import SDWebImage
import UIKit

final class BackgroundView: UIView {}
final class SelectedBackgroundView: UIView {}

final class UserListCollectionViewCell: UICollectionViewCell, ReusableIdentifiableView {
    private let imageSize: CGFloat = CGFloat(100)

    override func updateConfiguration(using state: UICellConfigurationState) {
        /*var newBgConfiguration = UIBackgroundConfiguration.listGroupedCell().updated(for: state)

        if state.isHighlighted || state.isSelected {
            newBgConfiguration.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        } else {
            newBgConfiguration.backgroundColor = .secondarySystemBackground
        }

        UIView.animate(withDuration: 0.3) {
            self.backgroundConfiguration = newBgConfiguration
        }*/
    }

    func bind(user: UserEntity?) {
        if let user = user {
            if let avatarUrl = user.avatarUrl {
                imageView.sd_setImage(with: URL(string: avatarUrl))
            }

            nameLabel.text = user.login

            accessibilityIdentifier = AccessibilityIdentifiers.UserListScreen.userListCell.rawValue + "_" + (user.login ?? "")
        } else {
            // TODO: put a silhouette image here
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        /*
        let backgroundView = BackgroundView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .orange
        backgroundView.layer.cornerRadius = CGFloat(10)
        self.backgroundView = backgroundView

        let selectedBackgroundView = SelectedBackgroundView()
        selectedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        selectedBackgroundView.backgroundColor = .magenta
        selectedBackgroundView.layer.cornerRadius = CGFloat(10)
        self.selectedBackgroundView = selectedBackgroundView
         */

        contentView.backgroundColor = .secondarySystemBackground
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        let cornerRadius = imageSize / 2

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2

        return imageView
    }()

    private lazy var imageViewShadow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        let cornerRadius = imageSize / 2

        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius).cgPath

        return view
    }()

    private lazy var imageViewWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageViewShadow)
        return view
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = AccessibilityIdentifiers.UserListScreen.userListCellNameLabel.rawValue
        return label
    }()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageViewWrapper, nameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        contentView.addSubview(rootStackView)
    }

    private func setupConstraints() {
        let padding = CGFloat(0)
        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -padding)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageViewShadow.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageViewShadow.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: imageViewShadow.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageViewShadow.bottomAnchor)
        ])

        let imageViewPadding = CGFloat(16)
        NSLayoutConstraint.activate([
            imageViewShadow.heightAnchor.constraint(equalTo: imageViewShadow.widthAnchor, multiplier: 1),
            imageViewShadow.widthAnchor.constraint(equalToConstant: imageSize),
            imageViewShadow.centerXAnchor.constraint(equalTo: imageViewWrapper.centerXAnchor),
            imageViewShadow.topAnchor.constraint(equalTo: imageViewWrapper.topAnchor, constant: imageViewPadding),
            imageViewShadow.bottomAnchor.constraint(equalTo: imageViewWrapper.bottomAnchor, constant: -imageViewPadding)
        ])
    }
}
