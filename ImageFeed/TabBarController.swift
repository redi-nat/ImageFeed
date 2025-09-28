import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.inject(presenter: imagesListPresenter)

        let repository = DefaultProfileRepository()
        let navigator: ProfileNavigator? = nil
        let logoutUseCase = DefaultLogoutUseCase()
        
        let profilePresenter = ProfilePresenter(
            repository: repository,
            logoutUseCase: logoutUseCase,
            navigator: navigator
        )
        
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
