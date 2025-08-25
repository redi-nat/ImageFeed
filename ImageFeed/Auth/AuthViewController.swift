import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
 //   override func viewWillAppear(_ animated: Bool) {
   //     super.viewWillAppear(animated)
    //}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webVC = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {

            // Скрываем WebViewViewController
            vc.dismiss(animated: true)

            // Показываем индикатор загрузки
            UIBlockingProgressHUD.show()

            fetchOAuthToken(code) { [weak self] result in
                // Скрываем индикатор загрузки
                UIBlockingProgressHUD.dismiss()

                guard let self else { return }

                switch result {
                case .success:
                    self.delegate?.didAuthenticate(self)
                case let .failure(error):
                    print("Ошибка при аутентификации: \(error.localizedDescription)")
                    self.showAuthErrorAlert()  // Показываем алерт при ошибке
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

        
    /*    vc.dismiss(animated: true)
                UIBlockingProgressHUD.show()

                // 1. Получаем токен
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
                    UIBlockingProgressHUD.dismiss()
                    guard let self = self else { return }

                    switch result {
                    case .success(let token):
                        // ✅ Пункт 3 — загрузка профиля и аватара
                        ProfileService.shared.fetchProfile(token) { result in
                            switch result {
                            case .success(let profile):
                                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                                    // Автоматически сработают нотификации и обновят UI
                                }
                                // Уведомляем делегата, что вход завершён
                                DispatchQueue.main.async {
                                    self.delegate?.didAuthenticate(self)
                                }

                            case .failure(let error):
                                print("Ошибка получения профиля: \(error)")
                                DispatchQueue.main.async {
                                    self.showAuthErrorAlert()
                                }
                            }
                        }

                    case .failure(let error):
                        print("Ошибка получения токена: \(error)")
                        DispatchQueue.main.async {
                            if self.view.window != nil {
                                self.showAuthErrorAlert()
                            } else {
                                print("⚠️ Не удалось показать алерт — view не в иерархии окна")
                            }
                        }
                    }
                }
            }

            func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
                vc.dismiss(animated: true)
            }
        }*/

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}

extension AuthViewController {
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
