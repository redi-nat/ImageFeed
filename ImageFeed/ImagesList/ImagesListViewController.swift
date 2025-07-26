import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    private let photosName: [String] = Array(0..<20).map{ "\($0)" }

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
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
private enum Constants {
    static let likeActiveImageName = "likeButtonOn"
    static let likeInactiveImageName = "likeButtonOff"
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photosName.count else { return }
        
        let mockPhoto = photosName[indexPath.row]
        guard let mockImage = UIImage(named: mockPhoto) else { return }
        
        cell.displayImageView.image = mockImage
        
        let currentDate = Date()
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: Constants.likeActiveImageName) : UIImage(named: Constants.likeInactiveImageName)
        
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let image = UIImage(named: photosName[indexPath.row]) else {
                return 0
            }
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }
