import Foundation

protocol ImagesListViewProtocol: AnyObject {
    /*func updateTable(animated: Bool)
    func reloadCell(at indexPath: IndexPath)
    func showLikeError()*/
    func insertRows(at indexPaths: [IndexPath])
}

protocol ImagesListPresenterProtocol: AnyObject {
    var numberOfPhotos: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func willDisplayCell(at index: Int)
    func toggleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    //func didSelectPhoto(at index: Int)
    func loadNextPageIfNeeded(for indexPath: IndexPath)
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    
    func fetchPhotosNextPage()
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}
