import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var exitButton: UIButton!
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setupImageView()
        setupExitButton()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        
        /*     NotificationCenter.default.addObserver(
         forName: ProfileService.didChangeNotification,
         object: nil,
         queue: .main
         ) { [weak self] _ in
         guard let self = self,
         let profile = ProfileService.shared.profile else { return }
         self.updateProfileDetails(profile: profile)
         } */
        
        /*   NotificationCenter.default.addObserver(
         forName: .ProfileDidChange,
         object: nil,
         queue: .main
         ) { [weak self] _ in
         guard let self = self else { return }
         if let profile = ProfileService.shared.profile {
         self.updateProfileDetails(profile: profile)
         
         // 👇 Запрашиваем аватар (а не просто updateAvatar)
         ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
         self.updateAvatar()
         }
         }
         } */
        
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        print("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale), // Учитываем масштаб экрана
                .cacheOriginalImage, // Кэшируем оригинал
                .forceRefresh // Игнорируем кэш, чтобы обновить
            ]) { result in
                
                switch result {
                    // Успешная загрузка
                case .success(let value):
                    // Картинка
                    print(value.image)
                    
                    // Откуда картинка загружена:
                    // - .none — из сети.
                    // - .memory — из кэша оперативной памяти.
                    // - .disk — из дискового кэша.
                    print(value.cacheType)
                    
                    // Информация об источнике.
                    print(value.source)
                    
                    // В случае ошибки
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    private func setupImageView() {
        avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
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
            action: #selector(didTapButton)
        )
        exitButton.tintColor = UIColor(named: "YP Red")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        // nameLabel.text = "Ekaterina Novikova"
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
        //  loginNameLabel.text = "@e_novikova"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
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
        //  descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    @objc
     private func didTapButton() {
     avatarImageView.image = UIImage(named: "UserImage")
     
     nameLabel.removeFromSuperview()
     loginNameLabel.removeFromSuperview()
     descriptionLabel.removeFromSuperview()
     }
     }
    
 /*   @objc
    private func didTapButton() {
        
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.reset()
        ProfileImageService.shared.resetAvatar()
        
        
        guard let window = UIApplication.shared.currentWindow else {
            print("Не удалось получить текущее окно")
            return
        }
        
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }*/

