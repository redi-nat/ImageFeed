import Foundation

protocol ProfileViewProtocol: AnyObject {
    func displayName(_ name: String)
    func displayLogin(_ login: String)
    func displayBio(_ bio: String)
    func displayAvatar(url: URL?)
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}
