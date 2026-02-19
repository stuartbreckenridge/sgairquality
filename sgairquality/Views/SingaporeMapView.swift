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
                if dataModel.pm25Data != nil && dataModel.psiData != nil {

                    // West
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.7)) {
                        ReadingsAnnotationView(pm25: dataModel.pm25Data!.data.items.first?.readings.pm25OneHourly.west ?? 0, psi: dataModel.psiData!.data.items.first?.readings.psiTwentyFourHourly.west ?? 0)
                    } label: {
                        Text("label.text.west", comment: "West")
                    }

                    // East
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.94)) {
                        ReadingsAnnotationView(pm25: dataModel.pm25Data!.data.items.first?.readings.pm25OneHourly.east ?? 0, psi: dataModel.psiData!.data.items.first?.readings.psiTwentyFourHourly.east ?? 0)
                    } label: {
                        Text("label.text.east", comment: "East")
                    }

                    // North
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.41803, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: dataModel.pm25Data!.data.items.first?.readings.pm25OneHourly.north ?? 0, psi: dataModel.psiData!.data.items.first?.readings.psiTwentyFourHourly.north ?? 0)
                    } label: {
                        Text("label.text.north", comment: "North")
                    }

                    // South
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.29587, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: dataModel.pm25Data!.data.items.first?.readings.pm25OneHourly.south ?? 0, psi: dataModel.psiData!.data.items.first?.readings.psiTwentyFourHourly.south ?? 0)
                    } label: {
                        Text("label.text.south", comment: "South")
                    }

                    // Central
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: dataModel.pm25Data!.data.items.first?.readings.pm25OneHourly.central ?? 0, psi: dataModel.psiData!.data.items.first?.readings.psiTwentyFourHourly.central ?? 0)
                    } label: {
                        Text("label.text.central", comment: "Central")
                    }
                }
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
