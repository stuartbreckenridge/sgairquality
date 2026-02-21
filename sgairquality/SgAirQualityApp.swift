//
//  SgAirQualityApp.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import SwiftUI
import BackgroundTasks
import os.log

@main
struct SgAirQualityApp: App {
    
    // MARK: Environment
    @Environment(\.scenePhase) private var phase
    
    // MARK: App Storage
    
    // MARK: State Objects
    
    // MARK: State
    
    // MARK: Bindings
    
    // MARK: Constants
    private let database = Database.shared
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sgairquality", category: "App")
    
    // MARK: Variables


    var body: some Scene {
        WindowGroup {
            SingaporeMapView()
        }
#if os(iOS)
        .onChange(of: phase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                do {
                    try scheduleAppRefresh()
                } catch {
                    Self.logger.error("Unable to schedule background refresh: \(error.localizedDescription)")
                }
            default: break
            }
        }
        
        .backgroundTask(.appRefresh("net.stuartbreckenridge.sgairquality.refresh")) { taskContext in
            do {
                let api = await DataAPI(repository: database)
                let _ = try await api.latestPM25Readings()
                let _ = try await api.latestPSIReadings()
                try await scheduleAppRefresh()
            } catch {
                await Self.logger.debug("Unable to process background refresh: \(error.localizedDescription)")
            }
        }
#endif
        
    }
    
    #if os(iOS)
    private func scheduleAppRefresh() throws {
        let request = BGAppRefreshTaskRequest(identifier: "net.stuartbreckenridge.sgairquality.refresh")
        request.earliestBeginDate = .now.addingTimeInterval(3600)
        try BGTaskScheduler.shared.submit(request)
    }
    #endif
}
