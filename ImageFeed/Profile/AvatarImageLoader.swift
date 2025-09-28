import UIKit
import Kingfisher

final class AvatarImageLoader {
    
    static func setImage(
        on imageView: UIImageView,
        url: URL?,
        placeholder: UIImage? = UIImage(systemName: "UserImage"),
        cornerRadius: CGFloat = 35,
        size: CGSize = CGSize(width: 70, height: 70)
    ) {
        DispatchQueue.main.async {
            guard let url = url else {
                imageView.image = placeholder
                return
            }

            let processor = ResizingImageProcessor(referenceSize: size, mode: .aspectFill)
            |> RoundCornerImageProcessor(cornerRadius: cornerRadius)

            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .forceRefresh
                ]
            )
        }
    }
}
