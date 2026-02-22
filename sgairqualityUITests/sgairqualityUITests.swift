//
//  sgairqualityUITests.swift
//  sgairqualityUITests
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import XCTest
import FoundationModels

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
    func testCanPresentAndDismissExplanationView() throws {
        let explanationButton = app.buttons["map.showexplanation.button"]
        XCTAssertTrue(explanationButton.waitForExistence(timeout: 5), "Expected explanation button on map screen.")

        explanationButton.tap()

        // Navigation title
        XCTAssertTrue(
            app.navigationBars["Air Quality Guide"].waitForExistence(timeout: 5),
            "Expected 'Air Quality Guide' navigation bar after tapping explanation button."
        )

        // Key section headers that should always be present
        XCTAssertTrue(
            app.staticTexts["How PSI Is Computed"].waitForExistence(timeout: 5),
            "Expected 'How PSI Is Computed' section header in explanation view."
        )
        XCTAssertTrue(
            app.staticTexts["Pollutant Standards Index (PSI)"].waitForExistence(timeout: 5),
            "Expected PSI section header in explanation view."
        )

        // Dismiss and confirm we return to the map
        let closeButton = app.buttons["explanation.close.button"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5), "Expected close button in explanation view.")
        closeButton.tap()

        XCTAssertTrue(
            app.buttons["map.showexplanation.button"].waitForExistence(timeout: 5),
            "Expected to return to map after dismissing explanation view."
        )
    }

    @MainActor
    func testCanPresentLatestReadingsWhenDataLoads() throws {
        let refreshButton = app.buttons["map.lastRefresh.label"]
        guard refreshButton.waitForExistence(timeout: 12) else {
            throw XCTSkip("Skipping: latest data did not load (API key/network may be unavailable in this environment).")
        }

        let northAnnotation = app.staticTexts["annotation.north"]
        let eastAnnotation = app.staticTexts["annotation.east"]
        let southAnnotation = app.staticTexts["annotation.south"]
        let westAnnotation = app.staticTexts["annotation.west"]
        let centralAnnotation = app.staticTexts["annotation.central"]
        XCTAssertTrue(northAnnotation.waitForExistence(timeout: 5))
        XCTAssertTrue(eastAnnotation.waitForExistence(timeout: 5))
        XCTAssertTrue(southAnnotation.waitForExistence(timeout: 5))
        XCTAssertTrue(westAnnotation.waitForExistence(timeout: 5))
        XCTAssertTrue(centralAnnotation.waitForExistence(timeout: 5))

        let languageModel = SystemLanguageModel.default
        if languageModel.isAvailable {
            let hazeSummary = app.staticTexts["overlay.airquality.summary"]
            XCTAssertTrue(hazeSummary.waitForExistence(timeout: 5))
        }

        refreshButton.tap()
        XCTAssertTrue(app.navigationBars["Latest Readings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["PSI - 24 Hour"].waitForExistence(timeout: 5))
    }
    
}
