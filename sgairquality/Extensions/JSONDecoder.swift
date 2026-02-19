//
//  JSONDecoder.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

extension JSONDecoder {
    /// A pre-configured `JSONDecoder` for decoding air quality API responses.
    ///
    /// Uses ISO 8601 date decoding strategy to correctly parse date strings
    /// returned by the air quality APIs.
    static var airQualityDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
