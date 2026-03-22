import XCTest

final class BreedsListUITests: XCTestCase {
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
    func testBreedsGridLoads() {
        app.launch()

        let abyssinian = app.staticTexts["Abyssinian"]
        XCTAssertTrue(abyssinian.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Bengal"].exists)
        XCTAssertTrue(app.staticTexts["British Shorthair"].exists)
    }

    @MainActor
    func testTapBreedOpensDetails() {
        app.launch()

        let breedButton = app.buttons["breed-button-abyssinian"]
        XCTAssertTrue(breedButton.waitForExistence(timeout: 5))
        breedButton.tap()

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertTrue(detailName.waitForExistence(timeout: 5))
        XCTAssertEqual(detailName.label, "Abyssinian")

        XCTAssertTrue(app.staticTexts["Ethiopia"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testDismissDetails() {
        app.launch()

        let breedButton = app.buttons["breed-button-abyssinian"]
        XCTAssertTrue(breedButton.waitForExistence(timeout: 5))
        breedButton.tap()

        let detailName = app.staticTexts.matching(identifier: "breed-detail-name").firstMatch
        XCTAssertTrue(detailName.waitForExistence(timeout: 5))

        let dismissButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'dismiss-detail'")).firstMatch
        if !dismissButton.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        } else {
            XCTAssertEqual(dismissButton.label, "Close details")
            dismissButton.tap()
        }

        XCTAssertTrue(app.staticTexts["Abyssinian"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testToggleFavoriteFromGrid() {
        app.launch()

        let abyssinian = app.staticTexts["Abyssinian"]
        XCTAssertTrue(abyssinian.waitForExistence(timeout: 5))

        let favoriteButton = app.buttons.matching(identifier: "favorite-button-abyssinian").firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))

        XCTAssertEqual(favoriteButton.label, "Add Abyssinian to favorites")
        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.label, "Remove Abyssinian from favorites")

        favoriteButton.tap()
        XCTAssertEqual(favoriteButton.label, "Add Abyssinian to favorites")
    }

    @MainActor
    func testFavoritesTabEmptyState() {
        app.launch()

        let abyssinian = app.staticTexts["Abyssinian"]
        XCTAssertTrue(abyssinian.waitForExistence(timeout: 5))

        app.tabBars.buttons.element(boundBy: 1).tap()

        let emptyTitle = app.staticTexts["No Favorites Yet"]
        XCTAssertTrue(emptyTitle.waitForExistence(timeout: 3))
    }

    @MainActor
    func testFavoritesTab() {
        app.launch()

        let abyssinian = app.staticTexts["Abyssinian"]
        XCTAssertTrue(abyssinian.waitForExistence(timeout: 5))

        let favoriteButton = app.buttons.matching(identifier: "favorite-button-abyssinian").firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))
        favoriteButton.tap()

        app.tabBars.buttons.element(boundBy: 1).tap()

        let favoritedBreed = app.staticTexts["Abyssinian"]
        XCTAssertTrue(favoritedBreed.waitForExistence(timeout: 3))
    }

    @MainActor
    func testToggleFavoriteFromDetails() {
        app.launch()

        let breedButton = app.buttons["breed-button-abyssinian"]
        XCTAssertTrue(breedButton.waitForExistence(timeout: 5))
        breedButton.tap()

        let detailFavorite = app.buttons.matching(identifier: "detail-favorite-button").firstMatch
        XCTAssertTrue(detailFavorite.waitForExistence(timeout: 5))
        XCTAssertEqual(detailFavorite.label, "Add Abyssinian to favorites")
        detailFavorite.tap()
        XCTAssertEqual(detailFavorite.label, "Remove Abyssinian from favorites")

        let dismissButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'dismiss-detail'")).firstMatch
        if !dismissButton.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        } else {
            XCTAssertEqual(dismissButton.label, "Close details")
            dismissButton.tap()
        }

        let gridFavorite = app.buttons.matching(identifier: "favorite-button-abyssinian").firstMatch
        XCTAssertTrue(gridFavorite.waitForExistence(timeout: 5))
        XCTAssertEqual(gridFavorite.label, "Remove Abyssinian from favorites")
    }
}
