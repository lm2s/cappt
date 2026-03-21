import XCTest

final class StoreLoadErrorUITests: XCTestCase {
    @MainActor
    var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchEnvironment = ["SimulateStoreError": "true"]
        return app
    }()

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testErrorScreenDisplaysAllContent() {
        app.launch()

        let icon = app.images.matching(identifier: "store-error-icon").firstMatch
        XCTAssertTrue(icon.waitForExistence(timeout: 5))

        let title = app.staticTexts.matching(identifier: "store-error-title").firstMatch
        XCTAssertTrue(title.exists)
        XCTAssertEqual(title.label, "Something Went Wrong")

        let body = app.staticTexts.matching(identifier: "store-error-body").firstMatch
        XCTAssertTrue(body.exists)
        XCTAssertTrue(body.label.contains("contact customer service"))

        let details = app.staticTexts.matching(identifier: "store-error-details").firstMatch
        XCTAssertTrue(details.exists)
        XCTAssertTrue(details.label.contains("Simulated store load failure"))
    }
}
