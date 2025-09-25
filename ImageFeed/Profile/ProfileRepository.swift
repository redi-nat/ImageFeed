import Foundation

protocol ProfileRepository {
    func getProfile() -> Profile?
    func getAvatarURL() -> String?
}

final class DefaultProfileRepository: ProfileRepository {
    func getProfile() -> Profile? {
        ProfileService.shared.profile
    }

    func getAvatarURL() -> String? {
        ProfileImageService.shared.avatarURL
    }
}
