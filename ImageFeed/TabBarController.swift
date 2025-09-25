import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")

        let repository = DefaultProfileRepository()
        let viewModel = ProfileViewModel(repository: repository)
        let navigator: ProfileNavigator? = nil
        let logoutUseCase = DefaultLogoutUseCase()
        
        let profileViewController = ProfileViewController(
            viewModel: viewModel,
            logoutUseCase: logoutUseCase,
            navigator: navigator
        )

        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
