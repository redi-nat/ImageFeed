import Foundation

protocol LogoutUseCase {
    func logout()
}

final class DefaultLogoutUseCase: LogoutUseCase {
    func logout() {
        ProfileLogoutService.shared.logout()
    }
}
