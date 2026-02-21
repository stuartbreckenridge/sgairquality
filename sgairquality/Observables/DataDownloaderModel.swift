//
//  DataDownloaderModel.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 19/02/2026.
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

@Observable
class DataDownloaderModel {

    // MARK: Variables
    var psiData: AirQualityResponse<PSIReadings>?
    var pm25Data: AirQualityResponse<PM25Readings>?
    var latestDownloadTime: Date?
    var hazeSummary: String?

    private var languageModel = SystemLanguageModel.default

    // MARK: Constants
    private let api = DataAPI.shared

    func downloadLatestData() async throws {
        psiData = try await api.latestPSIReadings()
        pm25Data = try await api.latestPM25Readings()
        latestDownloadTime = .now
        switch languageModel.availability {
        case .available:
            let session = LanguageModelSession()

            guard let pm25 = pm25Data?.data.items.first?.readings.pm25OneHourly,
                  let psi = psiData?.data.items.first?.readings.psiTwentyFourHourly else {
                return
            }

            let classifications = AirQualityClassification(
                north: RegionalReading(
                    region: "North",
                    pm25Value: pm25.north,
                    pm25Band: classifyPM25(pm25.north),
                    psiValue: psi.north,
                    psiBand: classifyPSI(psi.north)
                ),
                south: RegionalReading(
                    region: "South",
                    pm25Value: pm25.south,
                    pm25Band: classifyPM25(pm25.south),
                    psiValue: psi.south,
                    psiBand: classifyPSI(psi.south)
                ),
                east: RegionalReading(
                    region: "East",
                    pm25Value: pm25.east,
                    pm25Band: classifyPM25(pm25.east),
                    psiValue: psi.east,
                    psiBand: classifyPSI(psi.east)
                ),
                west: RegionalReading(
                    region: "West",
                    pm25Value: pm25.west,
                    pm25Band: classifyPM25(pm25.west),
                    psiValue: psi.west,
                    psiBand: classifyPSI(psi.west)
                ),
                central: RegionalReading(
                    region: "Central",
                    pm25Value: pm25.central,
                    pm25Band: classifyPM25(pm25.central),
                    psiValue: psi.central,
                    psiBand: classifyPSI(psi.central)
                )
            )

            let summaryPrompt = summaryPromptText(classifications: classifications)

            hazeSummary = try await session.respond(to: summaryPrompt).content

        default:
            return
        }
    }

    func classifyPM25(_ value: Int) -> PM25Band {
        switch value {
        case 0...55:
            return .normal
        case 56...150:
            return .elevated
        case 151...250:
            return .high
        default:
            return .veryHigh
        }
    }

    func classifyPSI(_ value: Int) -> PSIBand {
        switch value {
        case 0...50:
            return .good
        case 51...100:
            return .moderate
        case 101...200:
            return .unhealthy
        case 201...300:
            return .veryUnhealthy
        default:
            return .hazardous
        }
    }

    private func summaryPromptText(classifications: AirQualityClassification) -> String {
        // Determine the worst bands across all regions
        let allPM25Bands = [
            classifications.north.pm25Band,
            classifications.south.pm25Band,
            classifications.east.pm25Band,
            classifications.west.pm25Band,
            classifications.central.pm25Band
        ]

        let allPSIBands = [
            classifications.north.psiBand,
            classifications.south.psiBand,
            classifications.east.psiBand,
            classifications.west.psiBand,
            classifications.central.psiBand
        ]

        let allPM25Normal = allPM25Bands.allSatisfy { $0 == .normal }
        let hasElevatedOrWorsePM25 = allPM25Bands.contains(where: { $0 != .normal })
        let allPSIGoodOrModerate = allPSIBands.allSatisfy { $0 == .good || $0 == .moderate }

        let situationSummary: String
        if allPM25Normal && allPSIGoodOrModerate {
            situationSummary = "ALL regions show Normal PM2.5 and Good/Moderate PSI. This means air quality is GOOD and NO outdoor activity advisories apply to anyone."
        } else if hasElevatedOrWorsePM25 || !allPSIGoodOrModerate {
            situationSummary = "Some regions show elevated pollution requiring activity advisories."
        } else {
            situationSummary = "Mixed air quality conditions."
        }

        return """
            You are a Singapore haze advisory assistant. Provide a brief summary in approximately 45 words based ONLY on the classifications shown.

            ACTUAL CLASSIFICATIONS (use ONLY these - do not invent different values):

            North: PM2.5 band is "\(classifications.north.pm25Band.rawValue)", PSI band is "\(classifications.north.psiBand.rawValue)"
            South: PM2.5 band is "\(classifications.south.pm25Band.rawValue)", PSI band is "\(classifications.south.psiBand.rawValue)"
            East: PM2.5 band is "\(classifications.east.pm25Band.rawValue)", PSI band is "\(classifications.east.psiBand.rawValue)"
            West: PM2.5 band is "\(classifications.west.pm25Band.rawValue)", PSI band is "\(classifications.west.psiBand.rawValue)"
            Central: PM2.5 band is "\(classifications.central.pm25Band.rawValue)", PSI band is "\(classifications.central.psiBand.rawValue)"

            SITUATION: \(situationSummary)

            Advisories by Band:
            - "Normal" PM2.5 + "Good" or "Moderate" PSI = Everyone can do normal activities, NO advisories
            - "Elevated" PM2.5 = Reduce strenuous activity, vulnerable persons avoid strenuous activity
            - "Unhealthy" PSI = Reduce prolonged/strenuous exertion, vulnerable persons minimise outdoor activity

            STRICT INSTRUCTION: Your summary must match the ACTUAL CLASSIFICATIONS listed above. Do NOT say a region is "Elevated" if it shows "Normal". Do NOT recommend advisories if ALL bands are Normal/Good/Moderate.

            Write a single paragraph describing the air quality situation and recommendations.
            """
    }

}
