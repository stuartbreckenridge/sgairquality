//
//  sgairqualityTests.swift
//  sgairqualityTests
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Testing
@testable import sgairquality

/// Tests for the SgAirQuality app, covering API key configuration and live data API responses.
struct SgAirQualityTests {

    /// Verifies that an API key has been configured in the app's secrets.
    @Test func apiKeyExists() async throws {
        let key = await Configuration.apiKey
        #expect(key != nil)
    }
    
    /// Fetches the latest PM2.5 readings and verifies a successful response with non-negative values for all regions.
    @Test func getPM25Readings() async throws {
        let response = try await DataAPI.shared.latestPM25Readings()
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
        let response = try await DataAPI.shared.latestPSIReadings()
        #expect(response.code == 0)
        #expect(response.data.items.isEmpty == false)
        let readings = try #require(response.data.items.first?.readings)
        #expect(readings.psiTwentyFourHourly.west >= 0)
        #expect(readings.psiTwentyFourHourly.east >= 0)
        #expect(readings.psiTwentyFourHourly.central >= 0)
        #expect(readings.psiTwentyFourHourly.south >= 0)
        #expect(readings.psiTwentyFourHourly.north >= 0)
    }

}
