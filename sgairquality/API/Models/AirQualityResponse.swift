//
//  AirQualityResponse.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

// MARK: - Shared Root

/// These models are shared across the PSI and PM2.5 responses.

/// Top-level API response wrapper containing a status code, error message, and the response payload.
nonisolated struct AirQualityResponse<R: Codable & Sendable>: Codable, Sendable {
    let code: Int
    let errorMsg: String
    let data: AirQualityData<R>
}

/// Contains region metadata and a list of air quality reading items.
nonisolated struct AirQualityData<R: Codable & Sendable>: Codable, Sendable {
    let regionMetadata: [RegionMetadata]
    let items: [AirQualityItem<R>]
}

/// A single timestamped set of air quality readings.
nonisolated struct AirQualityItem<R: Codable & Sendable>: Codable, Sendable {
    let date: String
    let updatedTimestamp: Date
    let timestamp: Date
    let readings: R
}

/// Metadata for a named region, including its map label position.
nonisolated struct RegionMetadata: Codable, Sendable {
    let name: String
    let labelLocation: Coordinate
}

/// A geographic coordinate expressed as latitude and longitude.
nonisolated struct Coordinate: Codable, Sendable {
    let latitude: Double
    let longitude: Double
}

/// Air quality readings broken down by the five Singapore regions.
nonisolated struct RegionalReadings: Codable, Sendable {
    let west: Int
    let east: Int
    let central: Int
    let south: Int
    let north: Int
}


// MARK: - PSI Readings

/// Full set of PSI sub-index and pollutant readings across all regions.
nonisolated struct PSIReadings: Codable, Sendable {
    let o3SubIndex: RegionalReadings
    let no2OneHourMax: RegionalReadings
    let o3EightHourMax: RegionalReadings
    let psiTwentyFourHourly: RegionalReadings
    let pm10TwentyFourHourly: RegionalReadings
    let pm10SubIndex: RegionalReadings
    let pm25TwentyFourHourly: RegionalReadings
    let so2SubIndex: RegionalReadings
    let pm25SubIndex: RegionalReadings
    let so2TwentyFourHourly: RegionalReadings
    let coEightHourMax: RegionalReadings
    let coSubIndex: RegionalReadings

    enum CodingKeys: String, CodingKey {
        case o3SubIndex          = "o3_sub_index"
        case no2OneHourMax       = "no2_one_hour_max"
        case o3EightHourMax      = "o3_eight_hour_max"
        case psiTwentyFourHourly = "psi_twenty_four_hourly"
        case pm10TwentyFourHourly = "pm10_twenty_four_hourly"
        case pm10SubIndex        = "pm10_sub_index"
        case pm25TwentyFourHourly = "pm25_twenty_four_hourly"
        case so2SubIndex         = "so2_sub_index"
        case pm25SubIndex        = "pm25_sub_index"
        case so2TwentyFourHourly = "so2_twenty_four_hourly"
        case coEightHourMax      = "co_eight_hour_max"
        case coSubIndex          = "co_sub_index"
    }
}

// MARK: - PM2.5 Readings

/// One-hourly PM2.5 readings across all regions.
nonisolated struct PM25Readings: Codable, Sendable {
    let pm25OneHourly: RegionalReadings

    enum CodingKeys: String, CodingKey {
        case pm25OneHourly = "pm25_one_hourly"
    }

}
