import XCTest

final class BreedDetailsUITests: XCTestCase {
    @MainActor
    var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchEnvironment = ["UITesting": "true"]
        return app
    }()

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func openBreedDetails(named name: String = "Abyssinian") {
        app.launch()

        let breedID = name.lowercased().replacingOccurrences(of: " ", with: "-")
        let breedButton = app.buttons["breed-button-\(breedID)"]
        XCTAssertTrue(breedButton.waitForExistence(timeout: 5))
        breedButton.tap()

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertTrue(detailName.waitForExistence(timeout: 5))
    }

    @MainActor
    private func dismissDetails() {
        let dismissButton = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS 'dismiss-detail'")
        ).firstMatch
        if !dismissButton.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        } else {
            XCTAssertEqual(dismissButton.label, "Close details")
            dismissButton.tap()
        }
    }

    // MARK: - Tests

    @MainActor
    func testBreedDetailsDisplaysAllContent() {
        openBreedDetails()

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertEqual(detailName.label, "Abyssinian")

        let description = app.descendants(matching: .any).matching(identifier: "breed-detail-description").firstMatch
        XCTAssertTrue(description.waitForExistence(timeout: 2))

        let origin = app.descendants(matching: .any).matching(identifier: "breed-detail-origin").firstMatch
        XCTAssertTrue(origin.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Ethiopia"].exists)

        let temperament = app.descendants(matching: .any).matching(identifier: "breed-detail-temperament").firstMatch
        XCTAssertTrue(temperament.waitForExistence(timeout: 2))
    }

    @MainActor
    func testBreedDetailsDismissButton() {
        openBreedDetails()
        dismissDetails()

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertFalse(detailName.waitForExistence(timeout: 2))
    }

    @MainActor
    func testBreedDetailsFavoriteButton() {
        openBreedDetails()

        let favoriteButton = app.buttons.matching(identifier: "detail-favorite-button").firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))
        XCTAssertEqual(favoriteButton.label, "Add Abyssinian to favorites")

        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.label, "Remove Abyssinian from favorites")

        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.label, "Add Abyssinian to favorites")
    }

    @MainActor
    func testBreedDetailsFavoriteSyncsToGrid() {
        openBreedDetails()

        let favoriteButton = app.buttons.matching(identifier: "detail-favorite-button").firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))
        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.label, "Remove Abyssinian from favorites")

        dismissDetails()

        let gridFavorite = app.buttons.matching(identifier: "favorite-button-abyssinian").firstMatch
        XCTAssertTrue(gridFavorite.waitForExistence(timeout: 5))
        XCTAssertEqual(gridFavorite.label, "Remove Abyssinian from favorites")
    }

    @MainActor
    func testMultipleBreedsShowCorrectDetails() {
        openBreedDetails(named: "Abyssinian")

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertEqual(detailName.label, "Abyssinian")

        dismissDetails()

        let bengal = app.buttons["breed-button-bengal"]
        XCTAssertTrue(bengal.waitForExistence(timeout: 5))
        bengal.tap()

        let detailName2 = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertTrue(detailName2.waitForExistence(timeout: 5))
        XCTAssertEqual(detailName2.label, "Bengal")
    }
}
