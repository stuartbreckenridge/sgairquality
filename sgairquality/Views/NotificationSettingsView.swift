//
//  NotificationSettingsView.swift
//  sgairquality
//
//  Created by Codex on 14/09/2026.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {

    // MARK: Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: App Storage
    @AppStorage(NotificationPreferences.alertsEnabledKey) private var alertsEnabled = false
    @AppStorage(NotificationPreferences.pm25ThresholdKey) private var pm25Threshold = NotificationPreferences.defaultPM25Threshold.rawValue
    @AppStorage(NotificationPreferences.psiThresholdKey) private var psiThreshold = NotificationPreferences.defaultPSIThreshold.rawValue

    // MARK: State
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var authorizationError: String?

    // MARK: Constants
    private let notificationService = AirQualityNotificationService.shared

    var body: some View {
        NavigationStack {
            Form {
                NotificationPermissionSection(
                    alertsEnabled: $alertsEnabled,
                    authorizationStatus: authorizationStatus,
                    authorizationError: authorizationError
                )

                NotificationThresholdSection(
                    pm25Threshold: $pm25Threshold,
                    psiThreshold: $psiThreshold,
                    alertsEnabled: alertsEnabled
                )

                NotificationRegionSection(alertsEnabled: alertsEnabled)
            }
            .navigationTitle(Text("Air Quality Alerts", comment: "Title for the notification settings view."))
#if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .task {
                await refreshAuthorizationStatus()
            }
            .onChange(of: alertsEnabled) { _, isEnabled in
                guard isEnabled else { return }
                Task {
                    await requestAuthorizationIfNeeded()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("button.title.done", action: dismiss.callAsFunction)
                }
            }
        }
    }

    private func refreshAuthorizationStatus() async {
        let settings = await notificationService.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    private func requestAuthorizationIfNeeded() async {
        authorizationError = nil

        do {
            let granted = try await notificationService.requestAuthorization()
            await refreshAuthorizationStatus()
            if !granted {
                alertsEnabled = false
            }
        } catch {
            authorizationError = error.localizedDescription
            alertsEnabled = false
        }
    }
}

private struct NotificationPermissionSection: View {
    @Binding var alertsEnabled: Bool
    let authorizationStatus: UNAuthorizationStatus
    let authorizationError: String?

    var body: some View {
        Section {
            Toggle(isOn: $alertsEnabled) {
                Label("Enable Alerts", systemImage: "bell")
            }
        } footer: {
            if let authorizationError {
                Text("Notifications could not be enabled: \(authorizationError)", comment: "Footer shown when notification permission fails. The variable is the system error message.")
            } else {
                Text(statusMessage)
            }
        }
    }

    private var statusMessage: LocalizedStringResource {
        switch authorizationStatus {
        case .authorized:
            return "Alerts are enabled for meaningful air-quality changes."
        case .provisional:
            return "Alerts are delivered quietly until you choose otherwise in Notification Center."
        case .denied:
            return "Notifications are disabled in system settings."
        case .ephemeral:
            return "Alerts are temporarily available for this session."
        case .notDetermined:
            return "You will be asked for notification permission when alerts are enabled."
        @unknown default:
            return "Notification permission status is unavailable."
        }
    }
}

private struct NotificationThresholdSection: View {
    @Binding var pm25Threshold: String
    @Binding var psiThreshold: String
    let alertsEnabled: Bool

    var body: some View {
        Section {
            Picker("PM2.5 Threshold", selection: $pm25Threshold) {
                ForEach(NotificationPreferences.pm25ThresholdOptions, id: \.rawValue) { threshold in
                    Text(threshold.rawValue)
                        .tag(threshold.rawValue)
                }
            }

            Picker("PSI Threshold", selection: $psiThreshold) {
                ForEach(NotificationPreferences.psiThresholdOptions, id: \.rawValue) { threshold in
                    Text(threshold.rawValue)
                        .tag(threshold.rawValue)
                }
            }
        } header: {
            Text("Thresholds", comment: "Section header for notification threshold pickers.")
        } footer: {
            Text("The app sends at most one alert after each background refresh, only when a selected region reaches or worsens past your thresholds.", comment: "Footer explaining notification threshold behavior.")
        }
        .disabled(!alertsEnabled)
    }
}

private struct NotificationRegionSection: View {
    let alertsEnabled: Bool

    var body: some View {
        Section {
            ForEach(AirQualityRegion.allCases) { region in
                NotificationRegionToggle(region: region)
            }
        } header: {
            Text("Regions", comment: "Section header for region notification toggles.")
        }
        .disabled(!alertsEnabled)
    }
}

private struct NotificationRegionToggle: View {
    let region: AirQualityRegion
    @AppStorage private var isEnabled: Bool

    init(region: AirQualityRegion) {
        self.region = region
        _isEnabled = AppStorage(wrappedValue: true, region.storageKey)
    }

    var body: some View {
        Toggle(region.name, isOn: $isEnabled)
    }
}

#Preview {
    NotificationSettingsView()
}
