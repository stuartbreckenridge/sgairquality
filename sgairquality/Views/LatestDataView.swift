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
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.psiTwentyFourHourly.west ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.psiTwentyFourHourly.east ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.psiTwentyFourHourly.central ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.psiTwentyFourHourly.south ?? 0, dataType: .psi)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.psiTwentyFourHourly.north ?? 0, dataType: .psi)
                    } header: {
                        Text(verbatim: "PSI - 24 Hour")
                    } footer: {
                        Text("label.text.psi-explainer", comment: "Pollutant Standards Index composed of PM10, PM2.5, O3, CO, NO2, and SO2. Use the 24-hour PSI rating for next day activities.")
                    }

                    if let pm25Data = dataModel.pm25Data {
                        Section {
                            RegionalDataRow(title: "label.text.west", value: pm25Data.data.items.first?.readings.pm25OneHourly.west ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.east", value: pm25Data.data.items.first?.readings.pm25OneHourly.east ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.central", value: pm25Data.data.items.first?.readings.pm25OneHourly.central ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.south", value: pm25Data.data.items.first?.readings.pm25OneHourly.south ?? 0, dataType: .pm25)
                            RegionalDataRow(title: "label.text.north", value: pm25Data.data.items.first?.readings.pm25OneHourly.north ?? 0, dataType: .pm25)
                        } header: {
                            Text(verbatim: "PM2.5 - 1 Hour")
                        } footer: {
                            Text("label.text.pm251hour-explainer", comment: "Inhalable fine particulate matter that is generally 2.5 micrometers and smaller. Use the 1-hour PM2.5 rating for immediate activities.")
                        }
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.west ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.east ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.central ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.south ?? 0, dataType: .pm25)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.pm25TwentyFourHourly.north ?? 0, dataType: .pm25)
                    } header: {
                        Text(verbatim: "PM2.5 - 24 Hour")
                    } footer: {
                        Text("label.text.pm25-explainer", comment: "Inhalable fine particulate matter that is generally 2.5 micrometers and smaller.")
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.west ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.east ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.central ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.south ?? 0)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.pm10TwentyFourHourly.north ?? 0)
                    } header: {
                        Text(verbatim: "PM10 - 24 Hour")
                    } footer: {
                        Text("label.text.pm10-explainer", comment: "Inhalable particulate matter that is generally 10 micrometers and smaller.")
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.o3EightHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.o3EightHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.o3EightHourMax.central ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.o3EightHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.o3EightHourMax.north ?? 0)
                    } header: {
                        Text(verbatim: "Ozone (O3) - 8 Hour Max")
                    } footer: {
                        Text("label.text.o3-explainer", comment: "Ozone levels measured as an 8-hour maximum.")
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.coEightHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.coEightHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.coEightHourMax.central ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.coEightHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.coEightHourMax.north ?? 0)
                    } header: {
                        Text(verbatim: "Carbon Monoxide (CO) - 8 Hour Max")
                    } footer: {
                        Text("label.text.co-explainer", comment: "Carbon monoxide levels measured as an 8-hour maximum.")
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.so2TwentyFourHourly.west ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.so2TwentyFourHourly.east ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.so2TwentyFourHourly.central ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.so2TwentyFourHourly.south ?? 0)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.so2TwentyFourHourly.north ?? 0)
                    } header: {
                        Text(verbatim: "Sulfur Dioxide (SO2) - 24 Hour")
                    } footer: {
                        Text("label.text.so2-explainer", comment: "Sulfur dioxide levels measured over 24 hours.")
                    }

                    Section {
                        RegionalDataRow(title: "label.text.west", value: psiData.data.items.first?.readings.no2OneHourMax.west ?? 0)
                        RegionalDataRow(title: "label.text.east", value: psiData.data.items.first?.readings.no2OneHourMax.east ?? 0)
                        RegionalDataRow(title: "label.text.central", value: psiData.data.items.first?.readings.no2OneHourMax.central ?? 0)
                        RegionalDataRow(title: "label.text.south", value: psiData.data.items.first?.readings.no2OneHourMax.south ?? 0)
                        RegionalDataRow(title: "label.text.north", value: psiData.data.items.first?.readings.no2OneHourMax.north ?? 0)
                    } header: {
                        Text(verbatim: "Nitrogen Dioxide (NO2) - 1 Hour Max")
                    } footer: {
                        Text("label.text.no2-explainer", comment: "Nitrogen dioxide levels measured as a 1-hour maximum.")
                    }

                }
            }
            .navigationTitle(Text("label.text.latest-readings", comment: "Latest Readings"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle(Text(verbatim: dataModel.psiData?.data.items.first?.timestamp.formatted() ?? ""))
        }
    }
}

#Preview {
    LatestDataView()
        .environment(DataDownloaderModel())
}
