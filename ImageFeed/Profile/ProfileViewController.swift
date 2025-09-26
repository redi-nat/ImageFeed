import UIKit

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    private var presenter: ProfilePresenterProtocol?

        private var avatarImageView: UIImageView!
        private var nameLabel: UILabel!
        private var loginNameLabel: UILabel!
        private var descriptionLabel: UILabel!
        private var exitButton: UIButton!

        init(presenter: ProfilePresenterProtocol) {
            self.presenter = presenter
            super.init(nibName: nil, bundle: nil)
            self.presenter?.view = self
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        func configure(presenter: ProfilePresenterProtocol) {
            self.presenter = presenter
            self.presenter?.view = self
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor(resource: .ypBlack)
            setupUI()

            assert(presenter != nil, "Presenter must be set before viewDidLoad")
            
            presenter?.viewDidLoad()
        }

    private func setupUI() {
        setupImageView()
        setupExitButton()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
    }

    private func setupImageView() {
        avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupExitButton() {
        exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(didTapExitButton)
        )
        exitButton.tintColor = UIColor(resource: .ypRed)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }

    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20)
        ])
    }

    private func setupLoginLabel() {
        loginNameLabel = UILabel()
        loginNameLabel.textColor = UIColor(resource: .ypGray)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)

        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }

    @objc private func didTapExitButton() {
        present(AlertFactory.logoutConfirmation { [weak self] in
            guard let presenter = self?.presenter else { return }
            presenter.didTapLogout()
        }, animated: true)
    }

    
    func displayName(_ name: String) {
            nameLabel.text = name
        }

        func displayLogin(_ login: String) {
            loginNameLabel.text = login
        }

        func displayBio(_ bio: String) {
            descriptionLabel.text = bio
        }

    func displayAvatar(url: URL?) {
        AvatarImageLoader.setImage(on: avatarImageView, url: url)
    }

    }

#if DEBUG
extension ProfileViewController {
    var testable_nameLabel: UILabel? { nameLabel }
    var testable_loginNameLabel: UILabel? { loginNameLabel }
    var testable_descriptionLabel: UILabel? { descriptionLabel }
}
#endif
