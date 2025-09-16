import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

private struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

private struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

final class ImagesListService {
    
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://api.unsplash.com")!
    private let tokenStorage = OAuth2TokenStorage.shared
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let session = URLSession.shared
    private let perPage = 10
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private var accessToken: String {
        return "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"
    }
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        
        guard let url = URL(string: urlString) else {
                    isLoading = false
                    print("[fetchPhotosNextPage - ImagesListService]: invalid URL - \(urlString)")
                    return
                }
        
        var request = URLRequest(url: url)
        let token = tokenStorage.token

            if let token = token, !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
            }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }
            
            if let http = response as? HTTPURLResponse {
                        print("📡 Fetch photos response status: \(http.statusCode)")
                        if http.statusCode == 401 {
                            print("❗️ Unauthorized: token likely invalid. Clearing token or prompt login.")
                        }
                    }
            
            if let error = error {
                            print("[fetchPhotosNextPage - ImagesListService]: request error - \(error.localizedDescription)")
                            return
                        }

                        guard let data = data else {
                            print("[fetchPhotosNextPage - ImagesListService]: failure - data is nil")
                            return
                        }

                        do {
                            let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                            let newPhotos = photoResults.map { result in
                                Photo(
                                    id: result.id,
                                    size: CGSize(width: result.width, height: result.height),
                                    createdAt: self.dateFormatter.date(from: result.createdAt ?? ""),
                                    welcomeDescription: result.description,
                                    thumbImageURL: result.urls.thumb,
                                    largeImageURL: result.urls.full,
                                    isLiked: result.likedByUser
                                )
                            }

                            DispatchQueue.main.async {
                                let startIndex = self.photos.count
                                self.photos += newPhotos
                                self.lastLoadedPage = nextPage
                                NotificationCenter.default.post(
                                    name: ImagesListService.didChangeNotification,
                                    object: self,
                                    userInfo: ["photos": newPhotos]
                                )
                            }
                        } catch {
                            let jsonString = String(data: data, encoding: .utf8) ?? "non-decodable"
                            print("[fetchPhotosNextPage - ImagesListService]: decoding error - \(error.localizedDescription). Data: \(jsonString)")
                        }
                    }
                    task.resume()
                }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            let error = NetworkError.invalidRequest
                        print("[changeLike - ImagesListService]: token missing - photoId: \(photoId), isLike: \(isLike)")
                        completion(.failure(error))
                        return
        }
        
        let url = baseURL.appendingPathComponent("photos/\(photoId)/like")
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                                   print("[changeLike - ImagesListService]: request error - \(error.localizedDescription). photoId: \(photoId), isLike: \(isLike)")
                                   completion(.failure(error))
                                   return
                               }

                               guard let httpResponse = response as? HTTPURLResponse else {
                                   print("[changeLike - ImagesListService]: invalid response. photoId: \(photoId), isLike: \(isLike)")
                                   completion(.failure(NetworkError.invalidRequest))
                                   return
                               }

                               switch httpResponse.statusCode {
                               case 200...299:
                                   if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                                       self.photos[index].isLiked = isLike
                                       NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                                   }
                                   completion(.success(()))

                               case 401:
                                   print("[changeLike - ImagesListService]: unauthorized (401). photoId: \(photoId), isLike: \(isLike)")
                                   completion(.failure(NetworkError.httpStatusCode(401)))

                               default:
                                   print("[changeLike - ImagesListService]: HTTP error - code: \(httpResponse.statusCode). photoId: \(photoId), isLike: \(isLike)")
                                   completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                               }
                           }
                       }
                       task.resume()
                   }
               }
