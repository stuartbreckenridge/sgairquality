//
//  SgAirQualityApp.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import SwiftUI

@main
struct SgAirQualityApp: App {
    
    @State private var database = Database.shared
    
    var body: some Scene {
        WindowGroup {
            SingaporeMapView()
        }
    }
}
