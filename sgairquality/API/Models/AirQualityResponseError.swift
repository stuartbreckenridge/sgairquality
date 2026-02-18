//
//  AirQualityResponseError.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

/// Represents an error response returned by the air quality API.
///
/// The API returns error responses for the following HTTP status codes:
/// - `400`: The request body is invalid.
/// - `404`: No API data was found for the request.
/// - `429`: The rate limit has been exceeded.
nonisolated struct AirQualityResponseError: Decodable, Error {
    /// The HTTP status code of the error response.
    let code: Int
    /// A short name or title describing the error.
    let name: String
    /// A human-readable message describing the error in detail.
    let errorMsg: String
}
