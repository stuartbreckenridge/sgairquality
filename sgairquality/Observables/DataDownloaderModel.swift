//
//  DataDownloaderModel.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import Foundation

@Observable
class DataDownloaderModel {

    // MARK: Variables
    var psiData: AirQualityResponse<PSIReadings>?
    var pm25Data: AirQualityResponse<PM25Readings>?
    var latestDownloadTime: Date?
    var hazeSummary: String?
    var showUpToDateAlert: Bool = false

    // MARK: Constants
    private let api = DataAPI.shared

    func downloadLatestData() async throws {
        // Skip the API call if the most recent reading's timestamp is already for the current hour
        let calendar = Calendar.current
        let existingTimestamp = pm25Data?.data.items.first?.timestamp ?? psiData?.data.items.first?.timestamp
        if let timestamp = existingTimestamp, calendar.isDate(timestamp, equalTo: .now, toGranularity: .hour) {
            showUpToDateAlert = true
            return
        }

        psiData = try await api.latestPSIReadings()
        pm25Data = try await api.latestPM25Readings()
        latestDownloadTime = .now

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

        hazeSummary = try await AirQualitySummaryService.generateSummary(for: classifications)
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

}
