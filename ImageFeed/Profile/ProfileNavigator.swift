import Foundation
import UIKit

protocol ProfileNavigator: AnyObject {
    func navigateToLoginScreen()
}

final class DefaultProfileNavigator: ProfileNavigator {
    func navigateToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else {
            print("Не удалось получить окно для перехода")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
