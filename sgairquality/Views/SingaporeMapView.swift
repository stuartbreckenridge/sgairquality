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
                if let pm25Readings = dataModel.pm25Data?.data.items.first?.readings.pm25OneHourly,
                   let psiReadings = dataModel.psiData?.data.items.first?.readings.psiTwentyFourHourly {

                    // West
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.7)) {
                        ReadingsAnnotationView(pm25: pm25Readings.west, psi: psiReadings.west)
                            .accessibilityIdentifier("annotation.west")
                    } label: {
                        Text("label.text.west", comment: "West")
                    }

                    // East
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.94)) {
                        ReadingsAnnotationView(pm25: pm25Readings.east, psi: psiReadings.east)
                            .accessibilityIdentifier("annotation.east")
                    } label: {
                        Text("label.text.east", comment: "East")
                    }

                    // North
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.41803, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: pm25Readings.north, psi: psiReadings.north)
                            .accessibilityIdentifier("annotation.north")
                    } label: {
                        Text("label.text.north", comment: "North")
                    }

                    // South
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.29587, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: pm25Readings.south, psi: psiReadings.south)
                            .accessibilityIdentifier("annotation.south")

                    } label: {
                        Text("label.text.south", comment: "South")
                    }

                    // Central
                    Annotation(coordinate: CLLocationCoordinate2D(latitude: 1.35735, longitude: 103.82)) {
                        ReadingsAnnotationView(pm25: pm25Readings.central, psi: psiReadings.central)
                            .accessibilityIdentifier("annotation.central")
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
