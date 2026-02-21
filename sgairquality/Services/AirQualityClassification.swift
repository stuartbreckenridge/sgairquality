//
//  AirQualityClassification.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 21/02/2026.
//

import Foundation
import FoundationModels

// MARK: - Air Quality Classification Types

@Generable
enum PM25Band: String {
    case normal = "Normal"
    case elevated = "Elevated"
    case high = "High"
    case veryHigh = "Very High"
}

@Generable
enum PSIBand: String {
    case good = "Good"
    case moderate = "Moderate"
    case unhealthy = "Unhealthy"
    case veryUnhealthy = "Very Unhealthy"
    case hazardous = "Hazardous"
}

@Generable
struct RegionalReading {
    var region: String
    var pm25Value: Int
    var pm25Band: PM25Band
    var psiValue: Int
    var psiBand: PSIBand
}

@Generable
struct AirQualityClassification {
    var north: RegionalReading
    var south: RegionalReading
    var east: RegionalReading
    var west: RegionalReading
    var central: RegionalReading
}
