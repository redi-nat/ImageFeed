import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
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
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
                isLoading = true

                let nextPage = (lastLoadedPage ?? 0) + 1
                let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
                guard let url = URL(string: urlString) else {
                    isLoading = false
                    return
                }

                var request = URLRequest(url: url)
               request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")

                let task = session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self else { return }
                    defer { self.isLoading = false }

                    if let error = error {
                        print("Ошибка запроса: \(error)")
                        return
                    }

                    guard
                        let data = data,
                        let photoResults = try? JSONDecoder().decode([PhotoResult].self, from: data)
                    else {
                        print("Ошибка декодирования")
                        return
                    }

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
                        self.photos += newPhotos
                        self.lastLoadedPage = nextPage

                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos]
                        )
                    }
                }

                task.resume()
            
    }
}
