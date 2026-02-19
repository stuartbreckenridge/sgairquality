//
//  Configuration.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

enum Configuration {
    static func value(for key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            return nil
        }
        return value
    }

    static var apiKey: String? { value(for: "API_KEY") }
}
