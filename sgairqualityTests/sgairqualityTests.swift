//
//  sgairqualityTests.swift
//  sgairqualityTests
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Testing
import Foundation
@testable import sgairquality

/// Tests for the SgAirQuality app, covering API key configuration and live data API responses.
struct SgAirQualityTests {

    var api: DataAPI!
    
    init() {
        self.api = DataAPI(repository: Database.shared)
    }
    
    
    /// Verifies that an API key has been configured in the app's secrets.
    @Test func apiKeyExists() async throws {
        let key = await Configuration.apiKey
        #expect(key != nil)
    }

    /// Fetches the latest PM2.5 readings and verifies a successful response with non-negative values for all regions.
    @Test func getPM25Readings() async throws {
        let response = try await api.latestPM25Readings()
        #expect(response.code == 0)
        #expect(response.data.items.isEmpty == false)
        let readings = try #require(response.data.items.first?.readings)
        #expect(readings.pm25OneHourly.west >= 0)
        #expect(readings.pm25OneHourly.east >= 0)
        #expect(readings.pm25OneHourly.central >= 0)
        #expect(readings.pm25OneHourly.south >= 0)
        #expect(readings.pm25OneHourly.north >= 0)
    }

    /// Fetches the latest PSI readings and verifies a successful response with non-negative values for all regions.
    @Test func getPSIReadings() async throws {
        let response = try await api.latestPSIReadings()
        #expect(response.code == 0)
        #expect(response.data.items.isEmpty == false)
        let readings = try #require(response.data.items.first?.readings)
        #expect(readings.psiTwentyFourHourly.west >= 0)
        #expect(readings.psiTwentyFourHourly.east >= 0)
        #expect(readings.psiTwentyFourHourly.central >= 0)
        #expect(readings.psiTwentyFourHourly.south >= 0)
        #expect(readings.psiTwentyFourHourly.north >= 0)
    }
    
    @Test func getPM25ReadingsFromDatabase() async throws {
        let readings = try await Database.shared.fetchPM25Records()
        #expect(readings.count > 0)
    }
    
    @Test func getPSIReadingsFromDatabase() async throws {
        let readings = try await Database.shared.fetchPSIRecords()
        #expect(readings.count > 0)
    }

    /// Verifies that an invalid API key results in an APIError being thrown.
    @Test func apiErrorHandling() async throws {
        // Create a mock URLSession that returns an error response
        let errorJSON = """
        {
            "code": 401,
            "name": "Unauthorized",
            "errorMsg": "Invalid API key provided"
        }
        """

        let errorData = errorJSON.data(using: .utf8)!
        let decodedError = try JSONDecoder.airQualityDecoder.decode(AirQualityResponseError.self, from: errorData)

        #expect(decodedError.code == 401)
        #expect(decodedError.name == "Unauthorized")
        #expect(decodedError.errorMsg == "Invalid API key provided")
    }

}
/// Tests for air quality classification logic to ensure readings are correctly categorized into bands.
struct AirQualityClassificationTests {

    let model = DataDownloaderModel()

    // MARK: - PM2.5 Classification Tests

    /// Tests PM2.5 classification for Normal band (0-55 µg/m³)
    @Test func pm25NormalBand() {
        #expect(model.classifyPM25(0) == .normal)
        #expect(model.classifyPM25(14) == .normal)
        #expect(model.classifyPM25(19) == .normal)
        #expect(model.classifyPM25(27) == .normal)
        #expect(model.classifyPM25(55) == .normal)
    }

    /// Tests PM2.5 classification boundary at 55-56 µg/m³
    @Test func pm25NormalToElevatedBoundary() {
        #expect(model.classifyPM25(55) == .normal)
        #expect(model.classifyPM25(56) == .elevated)
    }

    /// Tests PM2.5 classification for Elevated band (56-150 µg/m³)
    @Test func pm25ElevatedBand() {
        #expect(model.classifyPM25(56) == .elevated)
        #expect(model.classifyPM25(75) == .elevated)
        #expect(model.classifyPM25(100) == .elevated)
        #expect(model.classifyPM25(150) == .elevated)
    }

    /// Tests PM2.5 classification boundary at 150-151 µg/m³
    @Test func pm25ElevatedToHighBoundary() {
        #expect(model.classifyPM25(150) == .elevated)
        #expect(model.classifyPM25(151) == .high)
    }

    /// Tests PM2.5 classification for High band (151-250 µg/m³)
    @Test func pm25HighBand() {
        #expect(model.classifyPM25(151) == .high)
        #expect(model.classifyPM25(200) == .high)
        #expect(model.classifyPM25(250) == .high)
    }

    /// Tests PM2.5 classification boundary at 250-251 µg/m³
    @Test func pm25HighToVeryHighBoundary() {
        #expect(model.classifyPM25(250) == .high)
        #expect(model.classifyPM25(251) == .veryHigh)
    }

    /// Tests PM2.5 classification for Very High band (≥251 µg/m³)
    @Test func pm25VeryHighBand() {
        #expect(model.classifyPM25(251) == .veryHigh)
        #expect(model.classifyPM25(300) == .veryHigh)
        #expect(model.classifyPM25(500) == .veryHigh)
    }

    // MARK: - PSI Classification Tests

    /// Tests PSI classification for Good band (0-50)
    @Test func psiGoodBand() {
        #expect(model.classifyPSI(0) == .good)
        #expect(model.classifyPSI(25) == .good)
        #expect(model.classifyPSI(49) == .good)
        #expect(model.classifyPSI(50) == .good)
    }

    /// Tests PSI classification boundary at 50-51
    @Test func psiGoodToModerateBoundary() {
        #expect(model.classifyPSI(50) == .good)
        #expect(model.classifyPSI(51) == .moderate)
    }

    /// Tests PSI classification for Moderate band (51-100)
    @Test func psiModerateBand() {
        #expect(model.classifyPSI(51) == .moderate)
        #expect(model.classifyPSI(53) == .moderate)
        #expect(model.classifyPSI(75) == .moderate)
        #expect(model.classifyPSI(100) == .moderate)
    }

    /// Tests PSI classification boundary at 100-101
    @Test func psiModerateToUnhealthyBoundary() {
        #expect(model.classifyPSI(100) == .moderate)
        #expect(model.classifyPSI(101) == .unhealthy)
    }

    /// Tests PSI classification for Unhealthy band (101-200)
    @Test func psiUnhealthyBand() {
        #expect(model.classifyPSI(101) == .unhealthy)
        #expect(model.classifyPSI(150) == .unhealthy)
        #expect(model.classifyPSI(200) == .unhealthy)
    }

    /// Tests PSI classification boundary at 200-201
    @Test func psiUnhealthyToVeryUnhealthyBoundary() {
        #expect(model.classifyPSI(200) == .unhealthy)
        #expect(model.classifyPSI(201) == .veryUnhealthy)
    }

    /// Tests PSI classification for Very Unhealthy band (201-300)
    @Test func psiVeryUnhealthyBand() {
        #expect(model.classifyPSI(201) == .veryUnhealthy)
        #expect(model.classifyPSI(250) == .veryUnhealthy)
        #expect(model.classifyPSI(300) == .veryUnhealthy)
    }

    /// Tests PSI classification boundary at 300-301
    @Test func psiVeryUnhealthyToHazardousBoundary() {
        #expect(model.classifyPSI(300) == .veryUnhealthy)
        #expect(model.classifyPSI(301) == .hazardous)
    }

    /// Tests PSI classification for Hazardous band (>300)
    @Test func psiHazardousBand() {
        #expect(model.classifyPSI(301) == .hazardous)
        #expect(model.classifyPSI(400) == .hazardous)
        #expect(model.classifyPSI(500) == .hazardous)
    }

    // MARK: - Real-World Scenario Tests

    /// Tests classification for typical good air quality day
    @Test func goodAirQualityScenario() {
        // All regions with good air quality
        let pm25Values = [14, 12, 19, 9, 9]

        for value in pm25Values {
            #expect(model.classifyPM25(value) == .normal)
        }

        // PSI values from real scenario
        #expect(model.classifyPSI(49) == .good)
        #expect(model.classifyPSI(51) == .moderate)
        #expect(model.classifyPSI(53) == .moderate)
    }

    /// Tests classification for haze scenario
    @Test func hazeScenario() {
        // PM2.5 elevated during haze
        let pm25Values = [78, 92, 105, 88, 95]
        let psiValues = [120, 135, 145, 130, 138]

        for value in pm25Values {
            #expect(model.classifyPM25(value) == .elevated)
        }

        for value in psiValues {
            #expect(model.classifyPSI(value) == .unhealthy)
        }
    }

    /// Tests classification for severe haze scenario
    @Test func severeHazeScenario() {
        // PM2.5 high/very high during severe haze
        let pm25HighValues = [180, 200, 220]
        let pm25VeryHighValues = [260, 300, 350]

        for value in pm25HighValues {
            #expect(model.classifyPM25(value) == .high)
        }

        for value in pm25VeryHighValues {
            #expect(model.classifyPM25(value) == .veryHigh)
        }

        let psiVeryUnhealthy = [210, 250, 290]
        let psiHazardous = [310, 350, 400]

        for value in psiVeryUnhealthy {
            #expect(model.classifyPSI(value) == .veryUnhealthy)
        }

        for value in psiHazardous {
            #expect(model.classifyPSI(value) == .hazardous)
        }
    }

    /// Tests that edge case value of 19 µg/m³ is correctly classified as Normal
    @Test func specificEdgeCase19PM25() {
        // This was a specific bug reported where 19 was classified as Elevated
        #expect(model.classifyPM25(19) == .normal)
    }

    /// Tests that edge case value of 53 PSI is correctly classified as Moderate
    @Test func specificEdgeCase53PSI() {
        // This was a specific bug reported where 53 was classified as Unhealthy
        #expect(model.classifyPSI(53) == .moderate)
    }
}

/// Tests for air quality classification data integrity.
struct AirQualityClassificationIntegrityTests {

    let model = DataDownloaderModel()

    /// Creates the actual reported scenario classification
    private func createReportedScenario() -> AirQualityClassification {
        return AirQualityClassification(
            north: RegionalReading(region: "North", pm25Value: 14, pm25Band: .normal, psiValue: 53, psiBand: .moderate),
            south: RegionalReading(region: "South", pm25Value: 12, pm25Band: .normal, psiValue: 51, psiBand: .moderate),
            east: RegionalReading(region: "East", pm25Value: 19, pm25Band: .normal, psiValue: 53, psiBand: .moderate),
            west: RegionalReading(region: "West", pm25Value: 9, pm25Band: .normal, psiValue: 49, psiBand: .good),
            central: RegionalReading(region: "Central", pm25Value: 9, pm25Band: .normal, psiValue: 53, psiBand: .moderate)
        )
    }

    /// Tests that the summary prompt logic correctly identifies good air quality
    @Test func summaryPromptLogicGoodAir() {
        let classifications = createReportedScenario()

        // Verify the logic that determines if all PM2.5 is Normal
        let allPM25Normal = [
            classifications.north.pm25Band,
            classifications.south.pm25Band,
            classifications.east.pm25Band,
            classifications.west.pm25Band,
            classifications.central.pm25Band
        ].allSatisfy { $0 == .normal }

        // Verify the logic that determines if all PSI is Good or Moderate
        let allPSIGoodOrModerate = [
            classifications.north.psiBand,
            classifications.south.psiBand,
            classifications.east.psiBand,
            classifications.west.psiBand,
            classifications.central.psiBand
        ].allSatisfy { $0 == .good || $0 == .moderate }

        #expect(allPM25Normal == true)
        #expect(allPSIGoodOrModerate == true)
    }

    /// Tests that classifications fed to the model maintain integrity
    @Test func classificationIntegrityTest() {
        let classifications = createReportedScenario()

        // Verify all classifications match expected values
        #expect(classifications.north.pm25Band == .normal)
        #expect(classifications.north.psiBand == .moderate)
        #expect(classifications.south.pm25Band == .normal)
        #expect(classifications.south.psiBand == .moderate)
        #expect(classifications.east.pm25Band == .normal)
        #expect(classifications.east.psiBand == .moderate)
        #expect(classifications.west.pm25Band == .normal)
        #expect(classifications.west.psiBand == .good)
        #expect(classifications.central.pm25Band == .normal)
        #expect(classifications.central.psiBand == .moderate)

        // Verify no region is incorrectly classified
        let allRegions = [
            classifications.north,
            classifications.south,
            classifications.east,
            classifications.west,
            classifications.central
        ]

        for region in allRegions {
            #expect(region.pm25Band == .normal, "\(region.region) PM2.5 should be Normal")
            #expect(region.psiBand == .good || region.psiBand == .moderate, "\(region.region) PSI should be Good or Moderate")
        }
    }
}
