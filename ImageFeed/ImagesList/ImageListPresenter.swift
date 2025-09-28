import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let service: ImagesListServiceProtocol
    internal(set) var photos: [Photo] = []

    init(view: ImagesListViewProtocol, service: ImagesListServiceProtocol = ImagesListService()) {
        self.view = view
        self.service = service
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handlePhotosDidChange),
                    name: ImagesListService.didChangeNotification,
                    object: nil
                )
    }

    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    func viewDidLoad() {
        service.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            service.fetchPhotosNextPage()
        }
    }

    @objc func handlePhotosDidChange() {
        let oldCount = photos.count
        let newPhotos = service.photos
        let newCount = newPhotos.count
        let diff = newCount - oldCount

        guard diff > 0 else { return }

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        photos = newPhotos
        view?.insertRows(at: indexPaths)
    }

    func photo(at index: Int) -> Photo {
        return photos[index]
    }

    var numberOfPhotos: Int {
            return photos.count
        }

        func loadNextPageIfNeeded(for indexPath: IndexPath) {
            if indexPath.row == photos.count - 1 {
                service.fetchPhotosNextPage()
            }
        }

        func toggleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
            var photo = photos[indexPath.row]
            let newIsLiked = !photo.isLiked

            service.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        photo.isLiked = newIsLiked
                        self.photos[indexPath.row] = photo
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            }
        }
    }
