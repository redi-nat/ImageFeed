import UIKit

final class AlertFactory {
    
    static func logoutConfirmation(onConfirm: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { _ in
            onConfirm()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        return alert
    }
}
