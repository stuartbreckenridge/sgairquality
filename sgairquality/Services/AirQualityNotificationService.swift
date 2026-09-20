//
//  AirQualityNotificationService.swift
//  sgairquality
//
//  Created by Codex on 14/09/2026.
//

import Foundation
import os.log
import UserNotifications

struct NotificationPreferences {
    static let alertsEnabledKey = "notifications.alertsEnabled"
    static let pm25ThresholdKey = "notifications.pm25Threshold"
    static let psiThresholdKey = "notifications.psiThreshold"
    static let northEnabledKey = "notifications.region.north"
    static let southEnabledKey = "notifications.region.south"
    static let eastEnabledKey = "notifications.region.east"
    static let westEnabledKey = "notifications.region.west"
    static let centralEnabledKey = "notifications.region.central"

    static let defaultPM25Threshold = PM25Band.elevated
    static let defaultPSIThreshold = PSIBand.unhealthy
    static let pm25ThresholdOptions: [PM25Band] = [.elevated, .high, .veryHigh]
    static let psiThresholdOptions: [PSIBand] = [.unhealthy, .veryUnhealthy, .hazardous]
}

enum AirQualityRegion: String, CaseIterable, Identifiable {
    case north
    case south
    case east
    case west
    case central

    var id: String { rawValue }

    var name: String {
        switch self {
        case .north:
            return String(localized: "label.text.north", defaultValue: "North", comment: "North region of Singapore")
        case .south:
            return String(localized: "label.text.south", defaultValue: "South", comment: "South region of Singapore")
        case .east:
            return String(localized: "label.text.east", defaultValue: "East", comment: "East region of Singapore")
        case .west:
            return String(localized: "label.text.west", defaultValue: "West", comment: "West region of Singapore")
        case .central:
            return String(localized: "label.text.central", defaultValue: "Central", comment: "Central region of Singapore")
        }
    }

    var storageKey: String {
        switch self {
        case .north:
            return NotificationPreferences.northEnabledKey
        case .south:
            return NotificationPreferences.southEnabledKey
        case .east:
            return NotificationPreferences.eastEnabledKey
        case .west:
            return NotificationPreferences.westEnabledKey
        case .central:
            return NotificationPreferences.centralEnabledKey
        }
    }

    func value(in readings: RegionalReadings) -> Int {
        switch self {
        case .north:
            return readings.north
        case .south:
            return readings.south
        case .east:
            return readings.east
        case .west:
            return readings.west
        case .central:
            return readings.central
        }
    }
}

extension PM25Band {
    var severity: Int {
        switch self {
        case .normal:
            return 0
        case .elevated:
            return 1
        case .high:
            return 2
        case .veryHigh:
            return 3
        }
    }

    static func classify(_ value: Int) -> PM25Band {
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
}

extension PSIBand {
    var severity: Int {
        switch self {
        case .good:
            return 0
        case .moderate:
            return 1
        case .unhealthy:
            return 2
        case .veryUnhealthy:
            return 3
        case .hazardous:
            return 4
        }
    }

    static func classify(_ value: Int) -> PSIBand {
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

final class AirQualityNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AirQualityNotificationService()

    private enum Metric: String {
        case pm25
        case psi
    }

    private struct NotificationCandidate {
        let region: AirQualityRegion
        let metric: Metric
        let value: Int
        let bandName: String
        let severity: Int
        let unit: String
    }

    private let center = UNUserNotificationCenter.current()
    private let defaults: UserDefaults
    private let cooldown: TimeInterval = 6 * 60 * 60
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sgairquality", category: "Notifications")

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
        center.delegate = self
        registerDefaultPreferences()
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func notificationSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func evaluateLatestReadings(
        pm25Data: AirQualityResponse<PM25Readings>,
        psiData: AirQualityResponse<PSIReadings>
    ) async {
        guard defaults.bool(forKey: NotificationPreferences.alertsEnabledKey) else { return }

        let settings = await notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            logger.debug("Skipping air-quality notification because authorization status is \(String(describing: settings.authorizationStatus))")
            return
        }

        guard let pm25 = pm25Data.data.items.first?.readings.pm25OneHourly,
              let psi = psiData.data.items.first?.readings.psiTwentyFourHourly else {
            logger.debug("Skipping air-quality notification because latest readings are unavailable")
            return
        }

        guard let candidate = notificationCandidate(pm25: pm25, psi: psi) else { return }
        guard await scheduleNotification(for: candidate) else { return }
        rememberNotification(for: candidate)
    }

    private func registerDefaultPreferences() {
        defaults.register(defaults: [
            NotificationPreferences.alertsEnabledKey: false,
            NotificationPreferences.pm25ThresholdKey: NotificationPreferences.defaultPM25Threshold.rawValue,
            NotificationPreferences.psiThresholdKey: NotificationPreferences.defaultPSIThreshold.rawValue,
            NotificationPreferences.northEnabledKey: true,
            NotificationPreferences.southEnabledKey: true,
            NotificationPreferences.eastEnabledKey: true,
            NotificationPreferences.westEnabledKey: true,
            NotificationPreferences.centralEnabledKey: true
        ])
    }

    private func notificationCandidate(pm25: RegionalReadings, psi: RegionalReadings) -> NotificationCandidate? {
        let pm25Threshold = PM25Band(rawValue: defaults.string(forKey: NotificationPreferences.pm25ThresholdKey) ?? "") ?? NotificationPreferences.defaultPM25Threshold
        let psiThreshold = PSIBand(rawValue: defaults.string(forKey: NotificationPreferences.psiThresholdKey) ?? "") ?? NotificationPreferences.defaultPSIThreshold

        let candidates = AirQualityRegion.allCases.compactMap { region -> [NotificationCandidate]? in
            guard defaults.bool(forKey: region.storageKey) else { return nil }

            let pm25Value = region.value(in: pm25)
            let pm25Band = PM25Band.classify(pm25Value)
            let psiValue = region.value(in: psi)
            let psiBand = PSIBand.classify(psiValue)
            updateLastSeenBandIfNeeded(region: region, metric: .pm25, severity: pm25Band.severity, threshold: pm25Threshold.severity)
            updateLastSeenBandIfNeeded(region: region, metric: .psi, severity: psiBand.severity, threshold: psiThreshold.severity)

            var regionCandidates: [NotificationCandidate] = []
            if pm25Band.severity >= pm25Threshold.severity,
               shouldNotify(region: region, metric: .pm25, severity: pm25Band.severity) {
                regionCandidates.append(
                    NotificationCandidate(
                        region: region,
                        metric: .pm25,
                        value: pm25Value,
                        bandName: pm25Band.rawValue,
                        severity: pm25Band.severity,
                        unit: String(localized: "µg/m³", comment: "Micrograms per cubic metre unit used for PM2.5 readings.")
                    )
                )
            }

            if psiBand.severity >= psiThreshold.severity,
               shouldNotify(region: region, metric: .psi, severity: psiBand.severity) {
                regionCandidates.append(
                    NotificationCandidate(
                        region: region,
                        metric: .psi,
                        value: psiValue,
                        bandName: psiBand.rawValue,
                        severity: psiBand.severity,
                        unit: ""
                    )
                )
            }

            return regionCandidates
        }
        .flatMap { $0 }

        return candidates.max { lhs, rhs in
            if lhs.severity == rhs.severity {
                return lhs.metric.rawValue < rhs.metric.rawValue
            }
            return lhs.severity < rhs.severity
        }
    }

    private func shouldNotify(region: AirQualityRegion, metric: Metric, severity: Int) -> Bool {
        let lastSeverity = defaults.integer(forKey: lastSeverityKey(region: region, metric: metric))
        let lastNotificationDate = Date(timeIntervalSince1970: defaults.double(forKey: lastNotificationDateKey(region: region, metric: metric)))
        let neverNotified = defaults.object(forKey: lastNotificationDateKey(region: region, metric: metric)) == nil

        if severity > lastSeverity {
            return true
        }

        return neverNotified || Date().timeIntervalSince(lastNotificationDate) >= cooldown
    }

    private func updateLastSeenBandIfNeeded(region: AirQualityRegion, metric: Metric, severity: Int, threshold: Int) {
        guard severity < threshold else { return }
        defaults.set(severity, forKey: lastSeverityKey(region: region, metric: metric))
    }

    private func scheduleNotification(for candidate: NotificationCandidate) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: candidate)
        content.body = notificationBody(for: candidate)
        content.sound = .default
        content.threadIdentifier = "air-quality-alerts"

        let request = UNNotificationRequest(
            identifier: "air-quality-\(candidate.metric.rawValue)-\(candidate.region.rawValue)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        do {
            try await center.add(request)
            logger.info("Scheduled air-quality notification for \(candidate.metric.rawValue) in \(candidate.region.rawValue)")
            return true
        } catch {
            logger.error("Unable to schedule air-quality notification: \(error.localizedDescription)")
            return false
        }
    }

    private func rememberNotification(for candidate: NotificationCandidate) {
        defaults.set(candidate.severity, forKey: lastSeverityKey(region: candidate.region, metric: candidate.metric))
        defaults.set(Date().timeIntervalSince1970, forKey: lastNotificationDateKey(region: candidate.region, metric: candidate.metric))
    }

    private func notificationTitle(for candidate: NotificationCandidate) -> String {
        switch candidate.metric {
        case .pm25:
            return String(localized: "Air quality worsening in \(candidate.region.name)", comment: "Notification title. The variable is the Singapore region name.")
        case .psi:
            return String(localized: "PSI worsening in \(candidate.region.name)", comment: "Notification title. The variable is the Singapore region name.")
        }
    }

    private func notificationBody(for candidate: NotificationCandidate) -> String {
        switch candidate.metric {
        case .pm25:
            return String(localized: "PM2.5 is now \(candidate.bandName) at \(candidate.value) \(candidate.unit).", comment: "Notification body. The variables are the air-quality band, reading value, and PM2.5 unit.")
        case .psi:
            return String(localized: "PSI is now \(candidate.bandName) at \(candidate.value).", comment: "Notification body. The variables are the air-quality band and reading value.")
        }
    }

    private func lastSeverityKey(region: AirQualityRegion, metric: Metric) -> String {
        "notifications.lastSeverity.\(metric.rawValue).\(region.rawValue)"
    }

    private func lastNotificationDateKey(region: AirQualityRegion, metric: Metric) -> String {
        "notifications.lastNotificationDate.\(metric.rawValue).\(region.rawValue)"
    }
}
