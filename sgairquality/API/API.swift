//
//  API.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation
import os.log

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

        var baseURL: URL {
            switch self {
            case .pm25:
                return URL(string: "https://api-open.data.gov.sg/v2/real-time/api/pm25")!
            case .psi:
                return URL(string: "https://api-open.data.gov.sg/v2/real-time/api/psi")!
            }
        }

        func url(for date: String) -> URL {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "date", value: date)]
            return components.url!
        }
    }

    static let shared = DataAPI()
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sgairquality", category: "DataAPI")
    private let repository: any AirQualityRepository

    init(repository: any AirQualityRepository = Database.shared) {
        self.repository = repository
    }

    /// Fetches and persists all PM2.5 readings for the given calendar date.
    /// - Parameter date: The calendar day to fetch. Defaults to today.
    func pm25Readings(for date: Date = Date()) async throws -> AirQualityResponse<PM25Readings> {
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        let reading: AirQualityResponse<PM25Readings> = try await fetch(endpoint: .pm25, date: dateString)

        for item in reading.data.items {
            let record = PM25Record(timestamp: item.timestamp,
                                    updated_timestamp: item.updatedTimestamp,
                                    date: item.date,
                                    west: item.readings.pm25OneHourly.west,
                                    east: item.readings.pm25OneHourly.east,
                                    central: item.readings.pm25OneHourly.central,
                                    south: item.readings.pm25OneHourly.south,
                                    north: item.readings.pm25OneHourly.north)
            do {
                try repository.save(record)
            } catch {
                Self.logger.error("Unable to save PM25 record: \(error.localizedDescription)")
            }
        }
        return reading
    }

    /// Fetches and persists all PSI readings for the given calendar date.
    /// - Parameter date: The calendar day to fetch. Defaults to today.
    func psiReadings(for date: Date = Date()) async throws -> AirQualityResponse<PSIReadings> {
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        let reading: AirQualityResponse<PSIReadings> = try await fetch(endpoint: .psi, date: dateString)

        for item in reading.data.items {
            let record = PSIRecord(timestamp: item.timestamp,
                                   updated_timestamp: item.updatedTimestamp,
                                   date: item.date,
                                   o3_sub_index_west: item.readings.o3SubIndex.west,
                                   o3_sub_index_east: item.readings.o3SubIndex.east,
                                   o3_sub_index_central: item.readings.o3SubIndex.central,
                                   o3_sub_index_south: item.readings.o3SubIndex.south,
                                   o3_sub_index_north: item.readings.o3SubIndex.north,
                                   no2_one_hour_max_west: item.readings.no2OneHourMax.west,
                                   no2_one_hour_max_east: item.readings.no2OneHourMax.east,
                                   no2_one_hour_max_central: item.readings.no2OneHourMax.central,
                                   no2_one_hour_max_south: item.readings.no2OneHourMax.south,
                                   no2_one_hour_max_north: item.readings.no2OneHourMax.north,
                                   o3_eight_hour_max_west: item.readings.o3EightHourMax.west,
                                   o3_eight_hour_max_east: item.readings.o3EightHourMax.east,
                                   o3_eight_hour_max_central: item.readings.o3EightHourMax.central,
                                   o3_eight_hour_max_south: item.readings.o3EightHourMax.south,
                                   o3_eight_hour_max_north: item.readings.o3EightHourMax.north,
                                   psi_twenty_four_hourly_west: item.readings.psiTwentyFourHourly.west,
                                   psi_twenty_four_hourly_east: item.readings.psiTwentyFourHourly.east,
                                   psi_twenty_four_hourly_central: item.readings.psiTwentyFourHourly.central,
                                   psi_twenty_four_hourly_south: item.readings.psiTwentyFourHourly.south,
                                   psi_twenty_four_hourly_north: item.readings.psiTwentyFourHourly.north,
                                   pm10_twenty_four_hourly_west: item.readings.pm10TwentyFourHourly.west,
                                   pm10_twenty_four_hourly_east: item.readings.pm10TwentyFourHourly.east,
                                   pm10_twenty_four_hourly_central: item.readings.pm10TwentyFourHourly.central,
                                   pm10_twenty_four_hourly_south: item.readings.pm10TwentyFourHourly.south,
                                   pm10_twenty_four_hourly_north: item.readings.pm10TwentyFourHourly.north,
                                   pm10_sub_index_west: item.readings.pm10SubIndex.west,
                                   pm10_sub_index_east: item.readings.pm10SubIndex.east,
                                   pm10_sub_index_central: item.readings.pm10SubIndex.central,
                                   pm10_sub_index_south: item.readings.pm10SubIndex.south,
                                   pm10_sub_index_north: item.readings.pm10SubIndex.north,
                                   pm25_twenty_four_hourly_west: item.readings.pm25TwentyFourHourly.west,
                                   pm25_twenty_four_hourly_east: item.readings.pm25TwentyFourHourly.east,
                                   pm25_twenty_four_hourly_central: item.readings.pm25TwentyFourHourly.central,
                                   pm25_twenty_four_hourly_south: item.readings.pm25TwentyFourHourly.south,
                                   pm25_twenty_four_hourly_north: item.readings.pm25TwentyFourHourly.north,
                                   so2_sub_index_west: item.readings.so2SubIndex.west,
                                   so2_sub_index_east: item.readings.so2SubIndex.east,
                                   so2_sub_index_central: item.readings.so2SubIndex.central,
                                   so2_sub_index_south: item.readings.so2SubIndex.south,
                                   so2_sub_index_north: item.readings.so2SubIndex.north,
                                   pm25_sub_index_west: item.readings.pm25SubIndex.west,
                                   pm25_sub_index_east: item.readings.pm25SubIndex.east,
                                   pm25_sub_index_central: item.readings.pm25SubIndex.central,
                                   pm25_sub_index_south: item.readings.pm25SubIndex.south,
                                   pm25_sub_index_north: item.readings.pm25SubIndex.north,
                                   so2_twenty_four_hourly_west: item.readings.so2TwentyFourHourly.west,
                                   so2_twenty_four_hourly_east: item.readings.so2TwentyFourHourly.east,
                                   so2_twenty_four_hourly_central: item.readings.so2TwentyFourHourly.central,
                                   so2_twenty_four_hourly_south: item.readings.so2TwentyFourHourly.south,
                                   so2_twenty_four_hourly_north: item.readings.so2TwentyFourHourly.north,
                                   co_eight_hour_max_west: item.readings.coEightHourMax.west,
                                   co_eight_hour_max_east: item.readings.coEightHourMax.east,
                                   co_eight_hour_max_central: item.readings.coEightHourMax.central,
                                   co_eight_hour_max_south: item.readings.coEightHourMax.south,
                                   co_eight_hour_max_north: item.readings.coEightHourMax.north,
                                   co_sub_index_west: item.readings.coSubIndex.west,
                                   co_sub_index_east: item.readings.coSubIndex.east,
                                   co_sub_index_central: item.readings.coSubIndex.central,
                                   co_sub_index_south: item.readings.coSubIndex.south,
                                   co_sub_index_north: item.readings.coSubIndex.north)
            do {
                try repository.save(record)
            } catch {
                Self.logger.error("Unable to save PSI record: \(error.localizedDescription)")
            }
        }
        return reading
    }

    func latestPM25Readings() async throws -> AirQualityResponse<PM25Readings> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let reading: AirQualityResponse<PM25Readings> = try await fetch(endpoint: .pm25, date: today)

        // Upsert all items for the day
        for item in reading.data.items {
            let record = PM25Record(timestamp: item.timestamp,
                                    updated_timestamp: item.updatedTimestamp,
                                    date: item.date,
                                    west: item.readings.pm25OneHourly.west,
                                    east: item.readings.pm25OneHourly.east,
                                    central: item.readings.pm25OneHourly.central,
                                    south: item.readings.pm25OneHourly.south,
                                    north: item.readings.pm25OneHourly.north)
            do {
                try repository.save(record)
            } catch {
                Self.logger.error("Unable to save PM25 record: \(error.localizedDescription)")
            }
        }

        // Return a response containing only the most recent item
        guard let mostRecent = reading.data.items.max(by: { $0.timestamp < $1.timestamp }) else {
            return reading
        }
        let trimmedData = AirQualityData(regionMetadata: reading.data.regionMetadata, items: [mostRecent])
        return AirQualityResponse(code: reading.code, errorMsg: reading.errorMsg, data: trimmedData)
    }

    func latestPSIReadings() async throws -> AirQualityResponse<PSIReadings> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let reading: AirQualityResponse<PSIReadings> = try await fetch(endpoint: .psi, date: today)

        // Upsert all items for the day
        for item in reading.data.items {
            let record = PSIRecord(timestamp: item.timestamp,
                                   updated_timestamp: item.updatedTimestamp,
                                   date: item.date,
                                   o3_sub_index_west: item.readings.o3SubIndex.west,
                                   o3_sub_index_east: item.readings.o3SubIndex.east,
                                   o3_sub_index_central: item.readings.o3SubIndex.central,
                                   o3_sub_index_south: item.readings.o3SubIndex.south,
                                   o3_sub_index_north: item.readings.o3SubIndex.north,
                                   no2_one_hour_max_west: item.readings.no2OneHourMax.west,
                                   no2_one_hour_max_east: item.readings.no2OneHourMax.east,
                                   no2_one_hour_max_central: item.readings.no2OneHourMax.central,
                                   no2_one_hour_max_south: item.readings.no2OneHourMax.south,
                                   no2_one_hour_max_north: item.readings.no2OneHourMax.north,
                                   o3_eight_hour_max_west: item.readings.o3EightHourMax.west,
                                   o3_eight_hour_max_east: item.readings.o3EightHourMax.east,
                                   o3_eight_hour_max_central: item.readings.o3EightHourMax.central,
                                   o3_eight_hour_max_south: item.readings.o3EightHourMax.south,
                                   o3_eight_hour_max_north: item.readings.o3EightHourMax.north,
                                   psi_twenty_four_hourly_west: item.readings.psiTwentyFourHourly.west,
                                   psi_twenty_four_hourly_east: item.readings.psiTwentyFourHourly.east,
                                   psi_twenty_four_hourly_central: item.readings.psiTwentyFourHourly.central,
                                   psi_twenty_four_hourly_south: item.readings.psiTwentyFourHourly.south,
                                   psi_twenty_four_hourly_north: item.readings.psiTwentyFourHourly.north,
                                   pm10_twenty_four_hourly_west: item.readings.pm10TwentyFourHourly.west,
                                   pm10_twenty_four_hourly_east: item.readings.pm10TwentyFourHourly.east,
                                   pm10_twenty_four_hourly_central: item.readings.pm10TwentyFourHourly.central,
                                   pm10_twenty_four_hourly_south: item.readings.pm10TwentyFourHourly.south,
                                   pm10_twenty_four_hourly_north: item.readings.pm10TwentyFourHourly.north,
                                   pm10_sub_index_west: item.readings.pm10SubIndex.west,
                                   pm10_sub_index_east: item.readings.pm10SubIndex.east,
                                   pm10_sub_index_central: item.readings.pm10SubIndex.central,
                                   pm10_sub_index_south: item.readings.pm10SubIndex.south,
                                   pm10_sub_index_north: item.readings.pm10SubIndex.north,
                                   pm25_twenty_four_hourly_west: item.readings.pm25TwentyFourHourly.west,
                                   pm25_twenty_four_hourly_east: item.readings.pm25TwentyFourHourly.east,
                                   pm25_twenty_four_hourly_central: item.readings.pm25TwentyFourHourly.central,
                                   pm25_twenty_four_hourly_south: item.readings.pm25TwentyFourHourly.south,
                                   pm25_twenty_four_hourly_north: item.readings.pm25TwentyFourHourly.north,
                                   so2_sub_index_west: item.readings.so2SubIndex.west,
                                   so2_sub_index_east: item.readings.so2SubIndex.east,
                                   so2_sub_index_central: item.readings.so2SubIndex.central,
                                   so2_sub_index_south: item.readings.so2SubIndex.south,
                                   so2_sub_index_north: item.readings.so2SubIndex.north,
                                   pm25_sub_index_west: item.readings.pm25SubIndex.west,
                                   pm25_sub_index_east: item.readings.pm25SubIndex.east,
                                   pm25_sub_index_central: item.readings.pm25SubIndex.central,
                                   pm25_sub_index_south: item.readings.pm25SubIndex.south,
                                   pm25_sub_index_north: item.readings.pm25SubIndex.north,
                                   so2_twenty_four_hourly_west: item.readings.so2TwentyFourHourly.west,
                                   so2_twenty_four_hourly_east: item.readings.so2TwentyFourHourly.east,
                                   so2_twenty_four_hourly_central: item.readings.so2TwentyFourHourly.central,
                                   so2_twenty_four_hourly_south: item.readings.so2TwentyFourHourly.south,
                                   so2_twenty_four_hourly_north: item.readings.so2TwentyFourHourly.north,
                                   co_eight_hour_max_west: item.readings.coEightHourMax.west,
                                   co_eight_hour_max_east: item.readings.coEightHourMax.east,
                                   co_eight_hour_max_central: item.readings.coEightHourMax.central,
                                   co_eight_hour_max_south: item.readings.coEightHourMax.south,
                                   co_eight_hour_max_north: item.readings.coEightHourMax.north,
                                   co_sub_index_west: item.readings.coSubIndex.west,
                                   co_sub_index_east: item.readings.coSubIndex.east,
                                   co_sub_index_central: item.readings.coSubIndex.central,
                                   co_sub_index_south: item.readings.coSubIndex.south,
                                   co_sub_index_north: item.readings.coSubIndex.north)
            do {
                try repository.save(record)
            } catch {
                Self.logger.error("Unable to save PSI record: \(error.localizedDescription)")
            }
        }

        // Return a response containing only the most recent item
        guard let mostRecent = reading.data.items.max(by: { $0.timestamp < $1.timestamp }) else {
            return reading
        }
        let trimmedData = AirQualityData(regionMetadata: reading.data.regionMetadata, items: [mostRecent])
        return AirQualityResponse(code: reading.code, errorMsg: reading.errorMsg, data: trimmedData)
    }

    private func fetch<T: Decodable>(endpoint: Endpoint, date: String) async throws -> AirQualityResponse<T> {
        guard let apiKey = Configuration.apiKey else { throw APIError.apiKeyNotConfigured }
        let url = endpoint.url(for: date)
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           [400, 404, 429].contains(httpResponse.statusCode) {
            let errorResponse = try JSONDecoder.airQualityDecoder.decode(AirQualityResponseError.self, from: data)
            throw APIError.apiError(errorResponse.errorMsg)
        }
        Self.logger.debug("Fetched data from \(url.lastPathComponent)")
        return try JSONDecoder.airQualityDecoder.decode(AirQualityResponse<T>.self, from: data)
    }

}
