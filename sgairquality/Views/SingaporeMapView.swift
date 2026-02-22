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
    @State private var hapticTrigger: Bool = false

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
                await dataModel.backfillHistoricalDataIfNeeded()
                try? await dataModel.downloadLatestData()
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        hapticTrigger.toggle()
                        Task {
                            try? await dataModel.downloadLatestData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("map.refresh.button")
                    .sensoryFeedback(.selection, trigger: hapticTrigger)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            hapticTrigger.toggle()
                            mapModel.showExplanationView.toggle()
                        } label: {
                            Label(String(localized: "button.title.explanation", comment: "Explanation"), systemImage: "questionmark")
                        }
                        .accessibilityIdentifier("map.showexplanation.button")

                        Button {
                            hapticTrigger.toggle()
                            mapModel.showHistoricalDataView.toggle()
                        } label: {
                            Label(String(localized: "button.title.historical-readings", comment: "Historical Readings"), systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .accessibilityIdentifier("map.showhistorical.button")

                        Button {
                            hapticTrigger.toggle()
                            mapModel.showLatestDataView.toggle()
                        } label: {
                            Label(String(localized: "button.title.latest-readings", comment: "Latest Readings"), systemImage: "chart.bar.horizontal.page")
                        }
                        .disabled(dataModel.psiData == nil)
                        .accessibilityIdentifier("map.lastRefresh.label")
                        
                        Divider()
                        
                        #if DEBUG
                        Button {
                            hapticTrigger.toggle()
                            Task {
                                try? await dataModel.regenerateSummary()
                            }
                        } label: {
                            Label("Regenerate Summary", systemImage: "apple.intelligence")
                        }
                        #endif
                        
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .accessibilityIdentifier("map.menu.button")
                    .sensoryFeedback(.selection, trigger: hapticTrigger)
                }
#else
                ToolbarItem(placement: .navigation) {
                    Button {
                        Task {
                            try? await dataModel.downloadLatestData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("map.refresh.button")
#if DEBUG
                    .contextMenu {
                        Button {
                            Task {
                                try? await dataModel.regenerateSummary()
                            }
                        } label: {
                            Label("Regenerate Summary", systemImage: "apple.intelligence")
                        }
                    }
#endif
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        mapModel.showExplanationView.toggle()
                    } label: {
                        Image(systemName: "questionmark")
                    }
                    .accessibilityIdentifier("map.showexplanation.button")
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        mapModel.showHistoricalDataView.toggle()
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                    .accessibilityIdentifier("map.showhistorical.button")
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        mapModel.showLatestDataView.toggle()
                    } label: {
                        Image(systemName: "chart.bar.horizontal.page")
                    }
                    .disabled(dataModel.psiData == nil)
                    .accessibilityIdentifier("map.lastRefresh.label")
                }
#endif
            }
            .sheet(isPresented: $mapModel.showLatestDataView) {
                LatestDataView()
                    .environment(dataModel)
#if os(macOS)
                    .frame(width: 500, height: 600)
#endif
            }
            .sheet(isPresented: $mapModel.showExplanationView) {
                ExplanationView()
#if os(macOS)
                    .frame(width: 500, height: 600)
#endif
            }
            .sheet(isPresented: $mapModel.showHistoricalDataView) {
                HistoricalDataView()
#if os(macOS)
                    .frame(width: 500, height: 600)
#endif
            }
            .alert("alert.title.data-up-to-date", isPresented: $dataModel.showUpToDateAlert) {
                Button("button.title.ok", role: .cancel) {}
            } message: {
                Text("alert.message.data-up-to-date", comment: "The readings are already current for this hour.")
            }
        }
        .overlay(alignment: .bottom) {
            if let hazeSummary = dataModel.hazeSummary {
                Label {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: hazeSummary)
                            .italic()
                        Text("label.text.summarised-by-apple-intelligence", comment: "Summarised by Apple Intelligence")
                            .font(.caption)
                            .bold()
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    Image(systemName: "apple.intelligence")
                        .frame(alignment: .top)
                }
                .accessibilityIdentifier("overlay.airquality.summary")
                .padding(8)
                .frame(maxWidth: .infinity)
#if !os(visionOS)
                .glassEffect(in: ConcentricRectangle(topLeadingCorner: .fixed(8), topTrailingCorner: .fixed(8)))
                .padding(4)
#else
                .glassBackgroundEffect()
#endif

            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    SingaporeMapView()
}
