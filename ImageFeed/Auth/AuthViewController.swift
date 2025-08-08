import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   print("AuthViewController loaded, delegate is \(String(describing: delegate))")
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            
            guard let webVC = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
       //     print("AuthViewController найден, назначаем delegate")
            webVC.delegate = self
        } else {
          //  print("➡️ Unexpected segue ID")
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  print("Delegate in viewWillAppear: \(String(describing: delegate))")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
       // print("Код авторизации получен: \(code)")

        self.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
             //   print("Вызов делегата после успешного получения токена")
                vc.dismiss(animated: true) {
                    self.delegate?.didAuthenticate(self)
                }

            case .failure(let error):
            //    print("Ошибка: \(error)")
                vc.dismiss(animated: true)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

private extension AuthViewController {
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code: code, completion: completion)
    }
}
