import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
      cleanCookies()
      clearToken()
      clearProfileData()
      switchToInitialScreen()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
    
    private func clearToken() {
            OAuth2TokenStorage.shared.token = nil
        }
        
        private func clearProfileData() {
            ProfileService.shared.clean()
            ProfileImageService.shared.clean()
        }
    
    private func switchToInitialScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                print("Не удалось получить текущее окно")
                return
            }
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
        }
    }
}
