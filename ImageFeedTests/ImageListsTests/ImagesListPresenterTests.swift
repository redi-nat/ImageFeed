import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    final class MockView: ImagesListViewProtocol {
        var insertedIndexPaths: [IndexPath] = []
        
        func insertRows(at indexPaths: [IndexPath]) {
            insertedIndexPaths.append(contentsOf: indexPaths)
        }
    }
    
    final class MockImagesListService: ImagesListServiceProtocol {
        var photos: [Photo] = []
        var fetchPhotosNextPageCalled = false
        var changeLikeCalled = false
        var shouldLikeSucceed = true

        func fetchPhotosNextPage() {
            fetchPhotosNextPageCalled = true
        }

        func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
            changeLikeCalled = true
            if shouldLikeSucceed {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 1)))
            }
        }
    }

    
    var sut: ImagesListPresenter!
    var mockView: MockView!
    var mockService: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        mockView = MockView()
        mockService = MockImagesListService()
        sut = ImagesListPresenter(view: mockView, service: mockService)
        
        sut.photos = [
            Photo(id: "1", size: .init(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumb", largeImageURL: "large", isLiked: false),
            Photo(id: "2", size: .init(width: 200, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumb", largeImageURL: "large", isLiked: true)
        ]
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockService = nil
        super.tearDown()
    }

    func test_numberOfPhotos_ReturnsCorrectCount() {
        XCTAssertEqual(sut.numberOfPhotos, 2)
    }

    func test_photoAtIndex_ReturnsCorrectPhoto() {
        let photo = sut.photo(at: 0)
        XCTAssertEqual(photo.id, "1")
    }

    func test_toggleLike_Success_UpdatesPhoto() {
        let expectation = self.expectation(description: "Like toggled")

        sut.toggleLike(for: IndexPath(row: 0, section: 0)) { success in
            XCTAssertTrue(success)
            XCTAssertTrue(self.sut.photos[0].isLiked)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_toggleLike_Failure_DoesNotUpdatePhoto() {
        mockService.shouldLikeSucceed = false

        sut.photos[0].isLiked = false

        let expectation = self.expectation(description: "Like failed")

        sut.toggleLike(for: IndexPath(row: 0, section: 0)) { success in
            XCTAssertFalse(success)
            XCTAssertFalse(self.sut.photos[0].isLiked)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func test_loadNextPageIfNeeded_CallsService() {
        let lastIndex = sut.photos.count - 1
        sut.loadNextPageIfNeeded(for: IndexPath(row: lastIndex, section: 0))
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
    }

    func test_handlePhotosDidChange_InsertsCorrectRows() {
        sut.photos = []
        mockService.photos = [
            Photo(id: "1", size: .init(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumb", largeImageURL: "large", isLiked: false),
            Photo(id: "2", size: .init(width: 200, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumb", largeImageURL: "large", isLiked: true)
        ]

        sut.handlePhotosDidChange()

        XCTAssertEqual(mockView.insertedIndexPaths, [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 1, section: 0)
        ])
    }
}
