//
//  LatestDataView.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import SwiftUI

struct LatestDataView: View {

    // MARK: Environment
    @Environment(DataDownloaderModel.self) var dataModel
    @Environment(\.dismiss) private var dismiss

    // MARK: Private Methods

    /// Returns the sub-index values for a given region as (label, value) pairs,
    /// sorted descending so the determining pollutant appears first.
    private func subIndices(for region: RegionalSubIndices) -> [(label: String, value: Int)] {
        [
            ("PM2.5", region.pm25),
            ("PM10",  region.pm10),
            ("O₃",   region.o3),
            ("CO",    region.co),
            ("SO₂",   region.so2),
            ("NO₂",   region.no2),
        ].sorted { $0.value > $1.value }
    }

    // MARK: App Storage

    // MARK: State Objects

    // MARK: State

    // MARK: Bindings

    // MARK: Constants

    // MARK: Variables

    var body: some View {
        NavigationStack {
            List {
                if let psiData = dataModel.psiData {
                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.psiTwentyFourHourly.north ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.psiTwentyFourHourly.east ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.psiTwentyFourHourly.south ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.psiTwentyFourHourly.west ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.psiTwentyFourHourly.central ?? 0, dataType: .psi)
                    } header: {
                        Text(verbatim: "PSI - 24 Hour")
                    } footer: {
                        Text("label.text.psi-explainer", comment: "Pollutant Standards Index composed of PM10, PM2.5, O3, CO, NO2, and SO2. Use the 24-hour PSI rating for next day activities.")
                        #if os(macOS)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        #endif
                    }

                    // PSI Sub-Index Breakdown
                    let readings = psiData.data.items.first?.readings
                    let regions: [(name: LocalizedStringResource, subIndices: RegionalSubIndices)] = [
                        ("label.text.north", RegionalSubIndices(pm25: readings?.pm25SubIndex.north ?? 0, pm10: readings?.pm10SubIndex.north ?? 0, o3: readings?.o3SubIndex.north ?? 0, co: readings?.coSubIndex.north ?? 0, so2: readings?.so2SubIndex.north ?? 0, no2: readings?.no2OneHourMax.north ?? 0)),
                        ("label.text.east",  RegionalSubIndices(pm25: readings?.pm25SubIndex.east ?? 0,  pm10: readings?.pm10SubIndex.east ?? 0,  o3: readings?.o3SubIndex.east ?? 0,  co: readings?.coSubIndex.east ?? 0,  so2: readings?.so2SubIndex.east ?? 0,  no2: readings?.no2OneHourMax.east ?? 0)),
                        ("label.text.south", RegionalSubIndices(pm25: readings?.pm25SubIndex.south ?? 0, pm10: readings?.pm10SubIndex.south ?? 0, o3: readings?.o3SubIndex.south ?? 0, co: readings?.coSubIndex.south ?? 0, so2: readings?.so2SubIndex.south ?? 0, no2: readings?.no2OneHourMax.south ?? 0)),
                        ("label.text.west",  RegionalSubIndices(pm25: readings?.pm25SubIndex.west ?? 0,  pm10: readings?.pm10SubIndex.west ?? 0,  o3: readings?.o3SubIndex.west ?? 0,  co: readings?.coSubIndex.west ?? 0,  so2: readings?.so2SubIndex.west ?? 0,  no2: readings?.no2OneHourMax.west ?? 0)),
                        ("label.text.central", RegionalSubIndices(pm25: readings?.pm25SubIndex.central ?? 0, pm10: readings?.pm10SubIndex.central ?? 0, o3: readings?.o3SubIndex.central ?? 0, co: readings?.coSubIndex.central ?? 0, so2: readings?.so2SubIndex.central ?? 0, no2: readings?.no2OneHourMax.central ?? 0)),
                    ]

                    Section {
                        ForEach(regions, id: \.name.key) { region in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(region.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                let sorted = subIndices(for: region.subIndices)
                                let maxValue = sorted.first?.value ?? 0
                                ForEach(sorted, id: \.label) { item in
                                    HStack {
                                        Text(verbatim: item.label)
                                            .font(.caption)
                                            .frame(width: 44, alignment: .leading)
                                        // Sub-index bar
                                        GeometryReader { geo in
                                            let fraction = maxValue > 0 ? CGFloat(item.value) / CGFloat(maxValue) : 0
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(item.value == maxValue ? Color.accentColor : Color.secondary.opacity(0.25))
                                                .frame(width: max(geo.size.width * fraction, 2))
                                        }
                                        .frame(height: 10)
                                        Text(verbatim: "\(item.value)")
                                            .font(.caption)
                                            .monospacedDigit()
                                            .foregroundStyle(item.value == maxValue ? .primary : .secondary)
                                            .frame(width: 36, alignment: .trailing)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("label.text.psi-subindex-breakdown", comment: "PSI Sub-Index Breakdown")
                    } footer: {
                        Text("label.text.psi-subindex-footer", comment: "The PSI for each region equals the highest sub-index value. The highlighted bar shows the determining pollutant.")
                        #if os(macOS)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        #endif
                    }

                    if let pm25Data = dataModel.pm25Data {
                        Section {
                            RegionalDataRow(title: "label.text.north", value: pm25Data.data.items.first?.readings.pm25OneHourly.north ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.east", value: pm25Data.data.items.first?.readings.pm25OneHourly.east ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.south", value: pm25Data.data.items.first?.readings.pm25OneHourly.south ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.west", value: pm25Data.data.items.first?.readings.pm25OneHourly.west ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.central", value: pm25Data.data.items.first?.readings.pm25OneHourly.central ?? 0, dataType: .pm25)
                        } header: {
                            Text(verbatim: "PM2.5 - 1 Hour")
                        } footer: {
                            Text("label.text.pm251hour-explainer", comment: "Inhalable fine particulate matter that is generally 2.5 micrometers and smaller. Use the 1-hour PM2.5 rating for immediate activities.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                        }
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.north ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.east ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.south ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.west ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.central ?? 0, dataType: .pm25)
                    } header: {
                        Text(verbatim: "PM2.5 - 24 Hour")
                    } footer: {
                        Text("label.text.pm25-explainer", comment: "Inhalable fine particulate matter that is generally 2.5 micrometers and smaller.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.north ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.east ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.south ?? 0)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.west ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.central ?? 0)
                    } header: {
                        Text(verbatim: "PM10 - 24 Hour")
                    } footer: {
                        Text("label.text.pm10-explainer", comment: "Inhalable particulate matter that is generally 10 micrometers and smaller.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.o3EightHourMax.north ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.o3EightHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.o3EightHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.o3EightHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.o3EightHourMax.central ?? 0)
                    } header: {
                        Text(verbatim: "Ozone (O3) - 8 Hour Max")
                    } footer: {
                        Text("label.text.o3-explainer", comment: "Ozone levels measured as an 8-hour maximum.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.coEightHourMax.north ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.coEightHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.coEightHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.coEightHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.coEightHourMax.central ?? 0)
                    } header: {
                        Text(verbatim: "Carbon Monoxide (CO) - 8 Hour Max")
                    } footer: {
                        Text("label.text.co-explainer", comment: "Carbon monoxide levels measured as an 8-hour maximum.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.so2TwentyFourHourly.north ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.so2TwentyFourHourly.east ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.so2TwentyFourHourly.south ?? 0)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.so2TwentyFourHourly.west ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.so2TwentyFourHourly.central ?? 0)
                    } header: {
                        Text(verbatim: "Sulfur Dioxide (SO2) - 24 Hour")
                    } footer: {
                        Text("label.text.so2-explainer", comment: "Sulfur dioxide levels measured over 24 hours.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }

                    Section {
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.no2OneHourMax.north ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.no2OneHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.no2OneHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.no2OneHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.no2OneHourMax.central ?? 0)
                    } header: {
                        Text(verbatim: "Nitrogen Dioxide (NO2) - 1 Hour Max")
                    } footer: {
                        Text("label.text.no2-explainer", comment: "Nitrogen dioxide levels measured as a 1-hour maximum.")
#if os(macOS)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
#endif
                    }
                }
            }
            .listStyle(.automatic)
            .navigationTitle(Text("label.text.latest-readings", comment: "Latest Readings"))
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if !os(visionOS)
            .navigationSubtitle(Text(verbatim: dataModel.psiData?.data.items.first?.timestamp.formatted() ?? ""))
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        #if os(iOS)
                        Image(systemName: "xmark")
                        #else
                        Text("button.title.close", comment: "Close")
                        #endif
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

private struct RegionalSubIndices {
    let pm25: Int
    let pm10: Int
    let o3: Int
    let co: Int
    let so2: Int
    let no2: Int
}

#Preview {
    LatestDataView()
        .environment(DataDownloaderModel())
}
