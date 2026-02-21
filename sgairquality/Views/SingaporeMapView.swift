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
            .mapStyle(.standard(emphasis: .muted))
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
                    if let _ = dataModel.psiData {
                        Button {
                            mapModel.showLatestDataView.toggle()
                        } label: {
                            VStack {
                                Text("label.text.latest-readings", comment: "Latest Readings")
                                    .font(.headline)
                                Text("label.text.tap-to-view", comment: "Tap to View")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("map.lastRefresh.label")
                    }
                }
            }
            .sheet(isPresented: $mapModel.showLatestDataView) {
                LatestDataView()
                    .environment(dataModel)
            }
            .overlay(alignment: .bottom) {
                if let hazeSummary = dataModel.hazeSummary {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: hazeSummary)
                                .italic()
                            Text("label.text.summarised-by-apple-intelligence", comment: "Summarised by Apple Intelligence")
                                .font(.caption)
                                .bold()
                                .textCase(.uppercase)
                        }

                    } icon: {
                        Image(systemName: "text.line.3.summary")
                    }
                    .padding(8)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                    .padding(8)
                }
            }
        }
    }
}

#Preview {
    SingaporeMapView()
}
