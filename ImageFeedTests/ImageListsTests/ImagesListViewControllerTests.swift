import XCTest
@testable import ImageFeed
import UIKit

final class ImagesListViewControllerTests: XCTestCase {

    final class MockPresenter: ImagesListPresenterProtocol {
        var numberOfPhotos: Int = 2
        var photoWasRequestedAtIndex: Int?
        var loadNextPageWasCalled = false
        var toggleLikeWasCalledWithIndexPath: IndexPath?
        var shouldToggleLikeSucceed = true

        let samplePhotos: [Photo] = [
            Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil,
                  welcomeDescription: nil, thumbImageURL: "https://example.com/thumb1",
                  largeImageURL: "https://example.com/large1", isLiked: false),
            Photo(id: "2", size: CGSize(width: 150, height: 250), createdAt: Date(),
                  welcomeDescription: nil, thumbImageURL: "https://example.com/thumb2",
                  largeImageURL: "https://example.com/large2", isLiked: true)
        ]

        func viewDidLoad() { }
        func willDisplayCell(at index: Int) { }
        func didSelectPhoto(at index: Int) { }

        func photo(at index: Int) -> Photo {
            photoWasRequestedAtIndex = index
            return samplePhotos[index]
        }

        func loadNextPageIfNeeded(for indexPath: IndexPath) {
            loadNextPageWasCalled = true
        }

        func toggleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
            toggleLikeWasCalledWithIndexPath = indexPath
            completion(shouldToggleLikeSucceed)
        }
    }

    var sut: ImagesListViewController!
    var mockPresenter: MockPresenter!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Could not instantiate ImagesListViewController from storyboard")
            return
        }

        sut = vc
        mockPresenter = MockPresenter()
        sut.inject(presenter: mockPresenter)
        sut.loadViewIfNeeded()
        
        sut.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        sut.tableView.frame = sut.view.bounds
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }

    func test_numberOfRows_IsEqualToPresenterCount() {
        let dataSource = sut as UITableViewDataSource
        let rows = dataSource.tableView(sut.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 2)
    }

    func test_cellForRow_CallsPresenterPhotoAtIndex() {
        let dataSource = sut as UITableViewDataSource
        _ = dataSource.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(mockPresenter.photoWasRequestedAtIndex, 1)
    }

    func test_willDisplayCell_CallsLoadNextPageIfNeeded() {
        let delegate = sut as UITableViewDelegate
        delegate.tableView?(sut.tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 1, section: 0))
        XCTAssertTrue(mockPresenter.loadNextPageWasCalled)
    }

    func test_tableViewHeightCalculation_IsCorrect() {
        let delegate = sut as UITableViewDelegate
        let indexPath = IndexPath(row: 0, section: 0)
        let photo = mockPresenter.samplePhotos[0]
        let imageSize = photo.size
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)

        let imageViewWidth = sut.tableView.bounds.width - insets.left - insets.right
        let scale = imageViewWidth / imageSize.width
        let expectedHeight = imageSize.height * scale + insets.top + insets.bottom

        guard let height = delegate.tableView?(sut.tableView, heightForRowAt: indexPath) else {
            XCTFail("heightForRowAt returned nil")
            return
        }
        XCTAssertEqual(height, expectedHeight, accuracy: 1.0)

    }

    func test_imageListCellDidTapLike_Success() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        guard
            let dataSource = sut.tableView.dataSource,
            let cell = dataSource.tableView(sut.tableView, cellForRowAt: indexPath) as? ImagesListCell
        else {
            XCTFail("Could not get ImagesListCell")
            return
        }

        sut.imageListCellDidTapLike(cell)
        XCTAssertEqual(mockPresenter.toggleLikeWasCalledWithIndexPath, indexPath)
    }

    func test_prepareForSegue_SetsImageURL() {
        let destination = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: sut, destination: destination)
        let indexPath = IndexPath(row: 1, section: 0)

        sut.prepare(for: segue, sender: indexPath)

        XCTAssertEqual(destination.imageURL?.absoluteString, "https://example.com/large2")
    }
}
