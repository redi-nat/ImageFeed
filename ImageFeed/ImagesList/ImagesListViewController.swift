import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePhotosDidChange(_:)),
                name: ImagesListService.didChangeNotification,
                object: nil
            )

        imagesListService.fetchPhotosNextPage()
    }
        
    @objc private func handlePhotosDidChange(_ notification: Notification) {
        updateTableViewAnimated()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]

            viewController.imageURL = URL(string: photo.largeImageURL)
                } else {
                    super.prepare(for: segue, sender: sender)
                }
            }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
                let newPhotos = imagesListService.photos
                let newCount = newPhotos.count
                photos = newPhotos

                if oldCount != newCount {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension ImagesListViewController: UITableViewDataSource, ImagesListCellDelegate  {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var photo = photos[indexPath.row]
        let newIsLiked = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Обновляем локально фото
                    photo.isLiked = newIsLiked
                    self.photos[indexPath.row] = photo
                    
                    // Обновляем ячейку
                    if let cell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                        cell.setIsLiked(newIsLiked)
                    }
                    
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure(let error):
                    print("Ошибка при изменении лайка: \(error.localizedDescription)")
                    
                    UIBlockingProgressHUD.dismiss()
                    
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось поставить лайк.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
                imagesListService.fetchPhotosNextPage()
            }
    }
}


extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }

        let photo = photos[indexPath.row]
        let placeholder = UIImage(named: "StubPlaceholder")
        cell.displayImageView.kf.indicatorType = .activity
        
        if let url = URL(string: photo.thumbImageURL) {
        cell.displayImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.2))],
                completionHandler: nil
           )
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            //guard let image = UIImage(named: photos[indexPath.row]) else { return 0 }
            let photo = photos[indexPath.row]
            let imageSize = photo.size
            
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            //let imageWidth = image.size.width
            let scale = imageViewWidth / imageSize.width
            let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }
