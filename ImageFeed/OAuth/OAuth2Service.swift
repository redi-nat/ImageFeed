import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuthError.invalidRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode),
                let data = data
            else {
                print("Invalid response or no data")
                DispatchQueue.main.async {
                    completion(.failure(OAuthError.invalidResponse))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                print("Token decoded: \(tokenResponse.accessToken)")
                OAuth2TokenStorage().token = tokenResponse.accessToken
                DispatchQueue.main.async {
                    completion(.success(tokenResponse.accessToken))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }


    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.tokenURL) else {
            print("Failed to create URLComponents from: \(Constants.tokenURL)")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            print("Failed to get URL from URLComponents: \(urlComponents)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("OAuth token request successfully created: \(request)")
        return request
    }
}


enum OAuthError: Error {
    case invalidRequest
    case invalidResponse
}
