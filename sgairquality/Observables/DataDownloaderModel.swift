//
//  DataDownloaderModel.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import Foundation

@Observable
class DataDownloaderModel {

    var psiData: AirQualityResponse<PSIReadings>?
    var pm25Data: AirQualityResponse<PM25Readings>?
    var latestDownloadTime: Date?

    private let api = DataAPI.shared

    func downloadLatestData() async throws {
        psiData = try await api.latestPSIReadings()
        pm25Data = try await api.latestPM25Readings()
        latestDownloadTime = .now
    }

}
