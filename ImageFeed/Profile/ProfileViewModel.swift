import Foundation

final class ProfileViewModel {

    private let repository: ProfileRepository

    var onAvatarURLChange: ((URL?) -> Void)?

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    var displayName: String {
        repository.getProfile()?.name ?? "Имя не указано"
    }

    var displayLogin: String {
        repository.getProfile()?.loginName ?? "@неизвестный_пользователь"
    }

    var displayBio: String {
        repository.getProfile()?.bio ?? "Профиль не заполнен"
    }

    var avatarURL: URL? {
        guard let urlString = repository.getAvatarURL() else { return nil }
        return URL(string: urlString)
    }

    func updateAvatar() {
        onAvatarURLChange?(avatarURL)
    }
}
