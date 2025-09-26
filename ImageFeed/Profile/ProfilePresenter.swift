import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?

    private let repository: ProfileRepository
    private let logoutUseCase: LogoutUseCase
    private let navigator: ProfileNavigator?

    init(repository: ProfileRepository, logoutUseCase: LogoutUseCase, navigator: ProfileNavigator?) {
        self.repository = repository
        self.logoutUseCase = logoutUseCase
        self.navigator = navigator
    }

    func viewDidLoad() {
        updateProfileDetails()
        updateAvatar()
    }

    func updateProfileDetails() {
        let profile = repository.getProfile()
        view?.displayName(profile?.name ?? "Имя не указано")
        view?.displayLogin(profile?.loginName ?? "@неизвестный_пользователь")
        view?.displayBio(profile?.bio ?? "Профиль не заполнен")
    }

    func updateAvatar() {
        if let urlString = repository.getAvatarURL(), let url = URL(string: urlString) {
            view?.displayAvatar(url: url)
        } else {
            view?.displayAvatar(url: nil)
        }
    }

    func didTapLogout() {
        logoutUseCase.logout()
        navigator?.navigateToLoginScreen()
    }
}
