import XCTest
@testable import ImageFeed

final class ProfilePresenterTests: XCTestCase {
    
    class MockView: ProfileViewProtocol {
        var displayedName: String?
        var displayedLogin: String?
        var displayedBio: String?
        var displayedAvatarURL: URL?
        
        func displayName(_ name: String) {
            displayedName = name
        }
        
        func displayLogin(_ login: String) {
            displayedLogin = login
        }
        
        func displayBio(_ bio: String) {
            displayedBio = bio
        }
        
        func displayAvatar(url: URL?) {
            displayedAvatarURL = url
        }
    }
    
    class MockRepository: ProfileRepository {
        var profile: Profile?
        var avatarURL: String?
        
        func getProfile() -> Profile? {
            return profile
        }
        
        func getAvatarURL() -> String? {
            return avatarURL
        }
    }
    
    class MockLogoutUseCase: LogoutUseCase {
        var didLogout = false
        func logout() {
            didLogout = true
        }
    }
    
    class MockNavigator: ProfileNavigator {
        var didNavigateToLogin = false
        func navigateToLoginScreen() {
            didNavigateToLogin = true
        }
    }
    
    func testViewDidLoad_DisplaysProfileData() {
        let mockView = MockView()
        let mockRepository = MockRepository()
        let mockLogout = MockLogoutUseCase()
        let mockNavigator = MockNavigator()
        
        let profile = Profile(username: "Test Username", name: "Test User", loginName: "test_login", bio: "Test bio")
        mockRepository.profile = profile
        mockRepository.avatarURL = "https://example.com/avatar.png"
        
        let presenter = ProfilePresenter(repository: mockRepository, logoutUseCase: mockLogout, navigator: mockNavigator)
        presenter.view = mockView
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(mockView.displayedName, "Test User")
        XCTAssertEqual(mockView.displayedLogin, "test_login")
        XCTAssertEqual(mockView.displayedBio, "Test bio")
        XCTAssertEqual(mockView.displayedAvatarURL, URL(string: "https://example.com/avatar.png"))
    }
    
    func testViewDidLoad_DisplaysDefaultValuesWhenProfileIsNil() {
        let mockView = MockView()
        let mockRepository = MockRepository()
        let mockLogout = MockLogoutUseCase()
        let mockNavigator = MockNavigator()
        
        mockRepository.profile = nil
        mockRepository.avatarURL = nil
        
        let presenter = ProfilePresenter(repository: mockRepository, logoutUseCase: mockLogout, navigator: mockNavigator)
        presenter.view = mockView
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(mockView.displayedName, "Имя не указано")
        XCTAssertEqual(mockView.displayedLogin, "@неизвестный_пользователь")
        XCTAssertEqual(mockView.displayedBio, "Профиль не заполнен")
        XCTAssertNil(mockView.displayedAvatarURL)
    }
    
    func testDidTapLogout_TriggersLogoutAndNavigation() {
        let mockView = MockView()
        let mockRepository = MockRepository()
        let mockLogout = MockLogoutUseCase()
        let mockNavigator = MockNavigator()
        
        let presenter = ProfilePresenter(repository: mockRepository, logoutUseCase: mockLogout, navigator: mockNavigator)
        presenter.view = mockView
        
        presenter.didTapLogout()
        
        XCTAssertTrue(mockLogout.didLogout)
        XCTAssertTrue(mockNavigator.didNavigateToLogin)
    }
}
