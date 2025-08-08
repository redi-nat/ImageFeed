import Foundation
import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
