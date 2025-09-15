import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    //private let photosName: [String] = Array(0..<20).map{ "\($0)" }
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

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Подписка на нотификацию
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePhotosDidChange(_:)),
                name: ImagesListService.didChangeNotification,
                object: nil
            )

            // Загрузка первой страницы
            imagesListService.fetchPhotosNextPage()
    }
        
    @objc private func handlePhotosDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newPhotos = userInfo["photos"] as? [Photo] else {
            return
        }

        /* тут ячейки перезаписываются
        self.photos = photos
        tableView.reloadData()*/
        
        //тут новые ячейки
        let oldCount = self.photos.count
            self.photos.append(contentsOf: newPhotos[oldCount...])

            let newIndexPaths = (oldCount..<self.photos.count).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: newIndexPaths, with: .automatic)
    }

    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }*/
    
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

            // Загружаем изображение по URL
            if let url = URL(string: photo.largeImageURL) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data,
                          let image = UIImage(data: data) else {
                        return
                    }

                    DispatchQueue.main.async {
                        viewController.image = image
                    }
                }.resume()
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension ImagesListViewController: UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //photosName.count
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
                imagesListService.fetchPhotosNextPage()
            }
    }
}
private enum ButtonConstants {
    static let likeActiveImageName = "likeButtonOn"
    static let likeInactiveImageName = "likeButtonOff"
}

extension ImagesListViewController {
    /*func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photosName.count else { return }
        
        let mockPhoto = photosName[indexPath.row]
        guard let mockImage = UIImage(named: mockPhoto) else { return }
        
        cell.displayImageView.image = mockImage
        
        let currentDate = Date()
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let likeImage = indexPath.row % 2 == 0
                ? UIImage(named: ButtonConstants.likeActiveImageName)
                : UIImage(named: ButtonConstants.likeInactiveImageName)
        
        cell.likeButton.setImage(likeImage, for: .normal)
    }*/
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }

        let photo = photos[indexPath.row]

        // Загрузка изображения по URL — можешь использовать SDWebImage или свой код
        if let url = URL(string: photo.thumbImageURL) {
            // Пример без сторонней библиотеки
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.displayImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        let likeImageName = photo.isLiked ? ButtonConstants.likeActiveImageName : ButtonConstants.likeInactiveImageName
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
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
