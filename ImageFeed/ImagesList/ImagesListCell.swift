
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
   
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            
            displayImageView.kf.cancelDownloadTask()
            displayImageView.image = nil
        }
    
    func setIsLiked(_ isLiked: Bool) {
            let imageName = isLiked ? ButtonConstants.likeActiveImageName : ButtonConstants.likeInactiveImageName
            likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

private enum ButtonConstants {
    static let likeActiveImageName = "likeButtonOn"
    static let likeInactiveImageName = "likeButtonOff"
}
