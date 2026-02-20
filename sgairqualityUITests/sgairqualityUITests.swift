//
//  sgairqualityUITests.swift
//  sgairqualityUITests
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import XCTest

final class sgairqualityUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testRefreshButtonExistsAndCanBeTapped() throws {
        let refreshButton = app.buttons["map.refresh.button"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 5), "Expected refresh button on map screen.")

        refreshButton.tap()
        refreshButton.tap()
        XCTAssertTrue(refreshButton.exists, "Refresh button should remain visible after repeated taps.")
    }

    @MainActor
    func testCanPresentLatestReadingsWhenDataLoads() throws {
        let refreshLabel = app.staticTexts["map.lastRefresh.label"]
        guard refreshLabel.waitForExistence(timeout: 12) else {
            throw XCTSkip("Skipping: latest data did not load (API key/network may be unavailable in this environment).")
        }

        let northAnnotation = app.staticTexts["annotation.north"]
        let eastAnnotation = app.staticTexts["annotation.east"]
        let southAnnotation = app.staticTexts["annotation.south"]
        let westAnnotation = app.staticTexts["annotation.west"]
        let centralAnnotation = app.staticTexts["annotation.central"]
        XCTAssertTrue(northAnnotation.exists)
        XCTAssertTrue(eastAnnotation.exists)
        XCTAssertTrue(southAnnotation.exists)
        XCTAssertTrue(westAnnotation.exists)
        XCTAssertTrue(centralAnnotation.exists)

        refreshLabel.tap()
        XCTAssertTrue(app.navigationBars["Latest Readings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["PSI - 24 Hour"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["PM2.5 - 24 Hour"].exists)
    }
}
