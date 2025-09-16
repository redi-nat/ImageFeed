import UIKit

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImage()
        
    }
    
    private func loadImage() {
            guard let imageURL else { return }

            UIBlockingProgressHUD.show()

            URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, error in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                }

                guard let self = self else { return }
        
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.frame.size = image.size
                self.scrollView.contentSize = image.size
                self.rescaleAndCenterImageInScrollView(image: image)
            }
        } else {
            print("❌ Не удалось загрузить изображение: \(error?.localizedDescription ?? "unknown error")")
        }
    }.resume()
}

    private func showLoadError() {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось загрузить изображение.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}


