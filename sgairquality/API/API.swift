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
        try await fetch(endpoint: .pm25)
    }

    func latestPSIReadings() async throws -> AirQualityResponse<PSIReadings> {
        try await fetch(endpoint: .psi)
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
