import XCTest
@testable import ImageFeed
import UIKit

final class ProfileViewControllerTests: XCTestCase {

    final class MockPresenter: ProfilePresenterProtocol {
        weak var view: ProfileViewProtocol?
        var viewDidLoadCalled = false
        var didTapLogoutCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didTapLogout() {
            didTapLogoutCalled = true
        }
    }

    var sut: ProfileViewController!
    var mockPresenter: MockPresenter!

    override func setUp() {
        super.setUp()
        mockPresenter = MockPresenter()
        sut = ProfileViewController(presenter: mockPresenter)
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }

    func testViewDidLoad_CallsPresenterViewDidLoad() {
        XCTAssertTrue(mockPresenter.viewDidLoadCalled)
    }

    func testDisplayName_SetsNameLabel() {
        sut.displayName("Иван Иванов")
        XCTAssertEqual(sut.testable_nameLabel?.text, "Иван Иванов")
    }

    func testDisplayLogin_SetsLoginLabel() {
        sut.displayLogin("@ivan")
        XCTAssertEqual(sut.testable_loginNameLabel?.text, "@ivan")
    }

    func testDisplayBio_SetsDescriptionLabel() {
            sut.displayBio("Test bio")
            XCTAssertEqual(sut.testable_descriptionLabel?.text, "Test bio")
        }

    func testSetImage_WithNilURL_SetsPlaceholder() {
        let imageView = UIImageView()
        let placeholder = UIImage(systemName: "person.crop.circle")!

        let expectation = XCTestExpectation(description: "Async placeholder set")

        AvatarImageLoader.setImage(on: imageView, url: nil, placeholder: placeholder)

        DispatchQueue.main.async {
            XCTAssertNotNil(imageView.image)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    }
