//
//  SingaporeMapView.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import SwiftUI
import MapKit

struct SingaporeMapView: View {

    // MARK: Environment

    // MARK: App Storage

    // MARK: State Objects

    // MARK: State
    @State private var mapModel = SingaporeMapViewModel()
    @State private var dataModel = DataDownloaderModel()

    // MARK: Bindings

    // MARK: Constants

    // MARK: Variables

    var body: some View {
        NavigationStack {
            Map(position: $mapModel.mapCameraPosition) {

            }
            .task {
                try? await dataModel.downloadLatestData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            try? await dataModel.downloadLatestData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("map.refresh.button")
                }

                ToolbarItem(placement: .bottomBar) {
                    if let latestDownloadTime = dataModel.latestDownloadTime {
                        Text("label.text.last-refresh-\(latestDownloadTime.formatted())", comment: "Last Refresh: <date>")
                            .fixedSize()
                            .accessibilityIdentifier("map.lastRefresh.label")
                            .onTapGesture {
                                mapModel.showLatestDataView.toggle()
                            }
                    }
                }
            }
            .sheet(isPresented: $mapModel.showLatestDataView) {
                LatestDataView()
                    .environment(dataModel)
            }
        }
    }
}

#Preview {
    SingaporeMapView()
}
