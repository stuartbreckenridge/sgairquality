//
//  DateFormatter.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Foundation

extension DateFormatter {
    /// A formatter that produces dates in `YYYY-MM-DD` format, as required by the air quality API's `date` parameter.
    static var yyyyMMdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
