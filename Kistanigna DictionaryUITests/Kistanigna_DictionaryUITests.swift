//
//  Kistanigna_DictionaryUITests.swift
//  Kistanigna DictionaryUITests
//
//  Created by Kebron Tadesse on 3/28/25.
//

import XCTest

final class Kistanigna_DictionaryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPrimaryTabNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-skipSplash")
        app.launch()

        XCTAssertTrue(app.staticTexts["Kistanigna Dictionary"].waitForExistence(timeout: 8))

        app.tabBars.buttons["Favorites"].tap()
        XCTAssertTrue(app.staticTexts["Favorites"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Traditions"].tap()
        XCTAssertTrue(app.staticTexts["Traditions"].waitForExistence(timeout: 3))

        app.tabBars.buttons["Quiz"].tap()
        XCTAssertTrue(app.staticTexts["Choose Your Path"].waitForExistence(timeout: 3))
    }
}
