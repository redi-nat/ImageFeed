import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")

        let repository = DefaultProfileRepository()
        let navigator: ProfileNavigator? = nil
        let logoutUseCase = DefaultLogoutUseCase()
        
        let presenter = ProfilePresenter(
            repository: repository,
            logoutUseCase: logoutUseCase,
            navigator: navigator
        )
        
        let profileViewController = ProfileViewController(presenter: presenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
