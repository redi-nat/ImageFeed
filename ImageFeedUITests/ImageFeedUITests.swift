import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
       func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        print(app.debugDescription)
        XCTAssertTrue(webView.waitForExistence(timeout: 15))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("ВВЕДИ ПОЧТУ")
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        // У меня не сработал обычный ввод пароля, поэтому сделала через копипаст, но старый код оставила
           
        /* func slowTypeText(_ element: XCUIElement, text: String) {
            for char in text {
                element.typeText(String(char))
                usleep(100_000) // 0.1 секунды пауза
            }
        }
        passwordTextField.tap()
        sleep(3)
        slowTypeText(passwordTextField, text: "ВВЕДИ ПАРОЛЬ")
        webView.tap()*/
        
        passwordTextField.tap()
        UIPasteboard.general.string = "ВВЕДИ ПАРОЛЬ"
        passwordTextField.press(forDuration: 1.1)
        app.menuItems["Paste"].tap()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
        XCTAssertTrue(loginButton.isHittable)
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        sleep(5)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 2)
        
        cellToLike.buttons["like button"].tap()
        cellToLike.buttons["like button"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        let nameLabel = app.staticTexts["profile_name"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))

        let usernameLabel = app.staticTexts["profile_login"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5))

        let logoutButton = app.buttons["logout_button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        print(app.debugDescription)

    }
}
