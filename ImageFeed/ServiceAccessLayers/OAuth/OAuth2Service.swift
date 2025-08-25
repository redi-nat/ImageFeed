import Foundation

enum OAuthError: Error {
    case invalidRequest
    case invalidResponse
    case repeatedRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared

    private var task: URLSessionTask?
    private var lastCode: String?

    private(set) var authToken: String? {
        get { dataStorage.token }
        set { dataStorage.token = newValue }
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(OAuthError.invalidRequest))
            return
        }

        task?.cancel()

        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuthError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken // сохраняем в свойство
                    completion(.success(authToken)) // возвращаем наружу
                    
                    self.task = nil
                    self.lastCode = nil
                    
                case .failure(let error):
                    print("[fetchOAuthToken]: Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error)) // ошибка
                    
                    self.task = nil
                    self.lastCode = nil
                    
                    /*      guard let self = self else { return }
                     
                     if let error = error {
                     print("Network error: \(error)")
                     completion(.failure(error))
                     return
                     }
                     
                     guard
                     let httpResponse = response as? HTTPURLResponse,
                     (200..<300).contains(httpResponse.statusCode),
                     let data = data
                     else {
                     print("Invalid response or no data")
                     completion(.failure(OAuthError.invalidResponse))
                     return
                     }
                     
                     do {
                     let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                     print("Token decoded: \(tokenResponse.accessToken)")
                     self.authToken = tokenResponse.accessToken
                     completion(.success(tokenResponse.accessToken))
                     } catch {
                     print("Decoding error: \(error)")
                     completion(.failure(error))
                     } */
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
      //  guard var urlComponents = URLComponents(string: Constants.tokenURL) else {
        guard
            var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        else {
            //  print("Failed to create URLComponents from: \(Constants.tokenURL)")
            assertionFailure("Failed to create URL")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("Failed to get URL from URLComponents: \(urlComponents)")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}

extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                }
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
