//
//  API.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

enum APIError: LocalizedError {
    case apiKeyNotConfigured
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return String(localized: "error.apiKeyNotConfigured", defaultValue: "API key is not configured.")
        case .apiError(let message):
            return message
        }
    }
}

/// Singleton client for fetching real-time air quality data from the Singapore government open data API.
///
/// Use ``shared`` to access the client, then call ``latestPM25Readings()`` or ``latestPSIReadings()``
/// to retrieve the most recent readings. Requests are authenticated using the API key from `Configuration`.
final class DataAPI {

    enum Endpoint {
        case pm25
        case psi

        var url: URL {
            switch self {
            case .pm25:
                return URL(string: "https://api-open.data.gov.sg/v2/real-time/api/pm25")!
            case .psi:
                return URL(string: "https://api-open.data.gov.sg/v2/real-time/api/psi")!
            }
        }
    }

    static let shared = DataAPI()

    private init() {}

    func latestPM25Readings() async throws -> AirQualityResponse<PM25Readings> {
        let reading: AirQualityResponse<PM25Readings> = try await fetch(endpoint: .pm25)
        guard let firstReading = reading.data.items.first else { return reading }
        let record = PM25Record(timestamp: firstReading.timestamp,
                                updated_timestamp: firstReading.updatedTimestamp,
                                date: firstReading.date,
                                west: firstReading.readings.pm25OneHourly.west,
                                east: firstReading.readings.pm25OneHourly.east,
                                central: firstReading.readings.pm25OneHourly.central,
                                south: firstReading.readings.pm25OneHourly.south,
                                north: firstReading.readings.pm25OneHourly.north)
        try? Database.shared.save(record)
        return reading
    }

    func latestPSIReadings() async throws -> AirQualityResponse<PSIReadings> {
        let reading: AirQualityResponse<PSIReadings> = try await fetch(endpoint: .psi)
        guard let firstReading = reading.data.items.first else { return reading }
        let record = PSIRecord(timestamp: firstReading.timestamp,
                               updated_timestamp: firstReading.updatedTimestamp,
                               date: firstReading.date,
                               o3_sub_index_west: firstReading.readings.o3SubIndex.west,
                               o3_sub_index_east: firstReading.readings.o3SubIndex.east,
                               o3_sub_index_central: firstReading.readings.o3SubIndex.central,
                               o3_sub_index_south: firstReading.readings.o3SubIndex.south,
                               o3_sub_index_north: firstReading.readings.o3SubIndex.north,
                               no2_one_hour_max_west: firstReading.readings.no2OneHourMax.west,
                               no2_one_hour_max_east: firstReading.readings.no2OneHourMax.east,
                               no2_one_hour_max_central: firstReading.readings.no2OneHourMax.central,
                               no2_one_hour_max_south: firstReading.readings.no2OneHourMax.south,
                               no2_one_hour_max_north: firstReading.readings.no2OneHourMax.north,
                               o3_eight_hour_max_west: firstReading.readings.o3EightHourMax.west,
                               o3_eight_hour_max_east: firstReading.readings.o3EightHourMax.east,
                               o3_eight_hour_max_central: firstReading.readings.o3EightHourMax.central,
                               o3_eight_hour_max_south: firstReading.readings.o3EightHourMax.south,
                               o3_eight_hour_max_north: firstReading.readings.o3EightHourMax.north,
                               psi_twenty_four_hourly_west: firstReading.readings.psiTwentyFourHourly.west,
                               psi_twenty_four_hourly_east: firstReading.readings.psiTwentyFourHourly.east,
                               psi_twenty_four_hourly_central: firstReading.readings.psiTwentyFourHourly.central,
                               psi_twenty_four_hourly_south: firstReading.readings.psiTwentyFourHourly.south,
                               psi_twenty_four_hourly_north: firstReading.readings.psiTwentyFourHourly.north,
                               pm10_twenty_four_hourly_west: firstReading.readings.pm10TwentyFourHourly.west,
                               pm10_twenty_four_hourly_east: firstReading.readings.pm10TwentyFourHourly.east,
                               pm10_twenty_four_hourly_central: firstReading.readings.pm10TwentyFourHourly.central,
                               pm10_twenty_four_hourly_south: firstReading.readings.pm10TwentyFourHourly.south,
                               pm10_twenty_four_hourly_north: firstReading.readings.pm10TwentyFourHourly.north,
                               pm10_sub_index_west: firstReading.readings.pm10SubIndex.west,
                               pm10_sub_index_east: firstReading.readings.pm10SubIndex.east,
                               pm10_sub_index_central: firstReading.readings.pm10SubIndex.central,
                               pm10_sub_index_south: firstReading.readings.pm10SubIndex.south,
                               pm10_sub_index_north: firstReading.readings.pm10SubIndex.north,
                               pm25_twenty_four_hourly_west: firstReading.readings.pm25TwentyFourHourly.west,
                               pm25_twenty_four_hourly_east: firstReading.readings.pm25TwentyFourHourly.east,
                               pm25_twenty_four_hourly_central: firstReading.readings.pm25TwentyFourHourly.central,
                               pm25_twenty_four_hourly_south: firstReading.readings.pm25TwentyFourHourly.south,
                               pm25_twenty_four_hourly_north: firstReading.readings.pm25TwentyFourHourly.north,
                               so2_sub_index_west: firstReading.readings.so2SubIndex.west,
                               so2_sub_index_east: firstReading.readings.so2SubIndex.east,
                               so2_sub_index_central: firstReading.readings.so2SubIndex.central,
                               so2_sub_index_south: firstReading.readings.so2SubIndex.south,
                               so2_sub_index_north: firstReading.readings.so2SubIndex.north,
                               pm25_sub_index_west: firstReading.readings.pm25SubIndex.west,
                               pm25_sub_index_east: firstReading.readings.pm25SubIndex.east,
                               pm25_sub_index_central: firstReading.readings.pm25SubIndex.central,
                               pm25_sub_index_south: firstReading.readings.pm25SubIndex.south,
                               pm25_sub_index_north: firstReading.readings.pm25SubIndex.north,
                               so2_twenty_four_hourly_west: firstReading.readings.so2TwentyFourHourly.west,
                               so2_twenty_four_hourly_east: firstReading.readings.so2TwentyFourHourly.east,
                               so2_twenty_four_hourly_central: firstReading.readings.so2TwentyFourHourly.central,
                               so2_twenty_four_hourly_south: firstReading.readings.so2TwentyFourHourly.south,
                               so2_twenty_four_hourly_north: firstReading.readings.so2TwentyFourHourly.north,
                               co_eight_hour_max_west: firstReading.readings.coEightHourMax.west,
                               co_eight_hour_max_east: firstReading.readings.coEightHourMax.east,
                               co_eight_hour_max_central: firstReading.readings.coEightHourMax.central,
                               co_eight_hour_max_south: firstReading.readings.coEightHourMax.south,
                               co_eight_hour_max_north: firstReading.readings.coEightHourMax.north,
                               co_sub_index_west: firstReading.readings.coSubIndex.west,
                               co_sub_index_east: firstReading.readings.coSubIndex.east,
                               co_sub_index_central: firstReading.readings.coSubIndex.central,
                               co_sub_index_south: firstReading.readings.coSubIndex.south,
                               co_sub_index_north: firstReading.readings.coSubIndex.north)
        try? Database.shared.save(record)
        return reading
    }

    private func fetch<T: Decodable>(endpoint: Endpoint) async throws -> AirQualityResponse<T> {
        guard let apiKey = Configuration.apiKey else { throw APIError.apiKeyNotConfigured }
        var request = URLRequest(url: endpoint.url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           [400, 404, 429].contains(httpResponse.statusCode) {
            let errorResponse = try JSONDecoder.airQualityDecoder.decode(AirQualityResponseError.self, from: data)
            throw APIError.apiError(errorResponse.errorMsg)
        }
        return try JSONDecoder.airQualityDecoder.decode(AirQualityResponse<T>.self, from: data)
    }

}
