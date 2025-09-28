import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {

    @IBOutlet private var tableView: UITableView!

    private var presenter: ImagesListPresenterProtocol!

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        presenter.viewDidLoad()
    }

    func inject(presenter: ImagesListPresenter) {
        self.presenter = presenter
    }

    func insertRows(at indexPaths: [IndexPath]) {
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if
                segue.identifier == "ShowSingleImage",
                let vc = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            {
                let photo = presenter.photo(at: indexPath.row)
                vc.imageURL = URL(string: photo.largeImageURL)
            }
        }
    }

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfPhotos
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell
        else { return UITableViewCell() }

        let photo = presenter.photo(at: indexPath.row)

        let placeholder = UIImage(named: "StubPlaceholder")
        cell.displayImageView.kf.indicatorType = .activity

        if let url = URL(string: photo.thumbImageURL) {
            cell.displayImageView.kf.setImage(with: url, placeholder: placeholder)
        }

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setIsLiked(photo.isLiked)
        cell.delegate = self

        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.loadNextPageIfNeeded(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let imageSize = photo.size
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageWidth = tableView.bounds.width - insets.left - insets.right
        let scale = imageWidth / imageSize.width
        return imageSize.height * scale + insets.top + insets.bottom
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        UIBlockingProgressHUD.show()

        presenter.toggleLike(for: indexPath) { [weak self] success in
                    guard let self else { return }
                    UIBlockingProgressHUD.dismiss()

                    if success,
                       let cell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                        let photo = self.presenter.photo(at: indexPath.row)
                        cell.setIsLiked(photo.isLiked)
                    } else {
                        let alert = UIAlertController(title: "Ошибка", message: "Не удалось поставить лайк.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default))
                        self.present(alert, animated: true)
                    }
        }
    }
}
