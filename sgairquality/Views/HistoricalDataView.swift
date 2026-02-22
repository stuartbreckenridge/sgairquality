//
//  HistoricalDataView.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 22/02/2026.
//

import SwiftUI
import Charts

struct HistoricalDataView: View {

    // MARK: Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: State
    @State private var selectedRange: TimeRange = .last12Hours
    @State private var pm25Records: [PM25Record] = []
    @State private var psiRecords: [PSIRecord] = []
    @State private var selectedMetric: Metric = .pm25
    @State private var selectedDate: Date? = nil

    // MARK: Constants
    private let database = Database.shared

    // MARK: Variables

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedMetric) {
                    Text(verbatim: "PM2.5").tag(Metric.pm25)
                    Text(verbatim: "PSI").tag(Metric.psi)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                Picker("", selection: $selectedRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if chartData.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.line.downtrend.xyaxis",
                        description: Text("No readings are available for the selected time range.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        chartView
                            .padding()
                    }
                }
            }
            .navigationTitle(Text("Historical Data"))
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
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
            .task(id: selectedRange) {
                selectedDate = nil
                loadData()
            }
            .onChange(of: selectedMetric) {
                selectedDate = nil
            }
        }
    }

    // MARK: Private Methods

    /// Builds the chart for the currently selected metric.
    @ViewBuilder
    private var chartView: some View {
        let xDomain = selectedRange.startDate...Date.now

        switch selectedMetric {
        case .pm25:
            Chart {
                ForEach(Region.allCases) { region in
                    ForEach(pm25Records) { record in
                        LineMark(
                            x: .value("Time", record.timestamp),
                            y: .value("PM2.5", region.pm25Value(from: record)),
                            series: .value("Region", region.displayName)
                        )
                        .foregroundStyle(by: .value(region.localizedName, region.displayName))
                    }
                }
                if let selectedDate, let record = closestPM25Record(to: selectedDate) {
                    RuleMark(x: .value("Selected", record.timestamp))
                        .foregroundStyle(.secondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .annotation(position: .bottom, alignment: .center, overflowResolution: .init(x: .fit(to: .plot), y: .disabled)) {
                            pm25TooltipView(for: record)
                                .padding(.top, 12)
                        }
                }
            }
            .chartXScale(domain: xDomain)
            .chartXAxis {
                AxisMarks(position: .top, values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: selectedRange.xAxisFormat)
                }
            }
            .chartYAxisLabel("µg/m³")
            .chartLegend(position: .bottom, alignment: .center)
            .chartXSelection(value: $selectedDate)
            .frame(height: 300)

        case .psi:
            Chart {
                ForEach(Region.allCases) { region in
                    ForEach(psiRecords) { record in
                        LineMark(
                            x: .value("Time", record.timestamp),
                            y: .value("PSI", region.psiValue(from: record)),
                            series: .value("Region", region.displayName)
                        )
                        .foregroundStyle(by: .value(region.localizedName, region.displayName))
                    }
                }
                if let selectedDate, let record = closestPSIRecord(to: selectedDate) {
                    RuleMark(x: .value("Selected", record.timestamp))
                        .foregroundStyle(.secondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .annotation(position: .bottom, alignment: .center, overflowResolution: .init(x: .fit(to: .plot), y: .disabled)) {
                            psiTooltipView(for: record)
                                .padding(.top, 12)
                        }
                }
            }
            .chartXScale(domain: xDomain)
            .chartXAxis {
                AxisMarks(position: .top, values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: selectedRange.xAxisFormat)
                }
            }
            .chartYAxisLabel("PSI")
            .chartLegend(position: .bottom, alignment: .center)
            .chartXSelection(value: $selectedDate)
            .frame(height: 300)
        }
    }

    /// Returns flattened chart data points for the current metric selection (used to detect empty state).
    private var chartData: [Any] {
        switch selectedMetric {
        case .pm25: return pm25Records
        case .psi: return psiRecords
        }
    }

    /// Loads records from the database for the selected time range.
    private func loadData() {
        let since = selectedRange.startDate
        pm25Records = (try? database.fetchPM25Records(since: since)) ?? []
        psiRecords = (try? database.fetchPSIRecords(since: since)) ?? []
    }

    /// Returns the PM2.5 record whose timestamp is closest to the given date.
    private func closestPM25Record(to date: Date) -> PM25Record? {
        pm25Records.min(by: { abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date)) })
    }

    /// Returns the PSI record whose timestamp is closest to the given date.
    private func closestPSIRecord(to date: Date) -> PSIRecord? {
        psiRecords.min(by: { abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date)) })
    }

    /// Tooltip shown when a PM2.5 data point is selected on the chart.
    @ViewBuilder
    private func pm25TooltipView(for record: PM25Record) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(record.timestamp, format: .dateTime.month().day().hour().minute())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Divider()
            ForEach(Region.allCases) { region in
                HStack {
                    Text(region.localizedName)
                        .font(.caption2)
                    Spacer()
                    Text("\(region.pm25Value(from: record)) µg/m³")
                        .font(.caption2.monospacedDigit())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(8)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        .frame(minWidth: 140)
    }

    /// Tooltip shown when a PSI data point is selected on the chart.
    @ViewBuilder
    private func psiTooltipView(for record: PSIRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(record.timestamp, format: .dateTime.month().day().hour().minute())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Divider()
            ForEach(Region.allCases) { region in
                HStack {
                    Text(region.localizedName)
                        .font(.caption2)
                    Spacer()
                    Text("\(region.psiValue(from: record))")
                        .font(.caption2.monospacedDigit())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(8)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        .frame(minWidth: 120)
    }
}

// MARK: - Supporting Types

private enum Metric: CaseIterable {
    case pm25, psi
}

private enum TimeRange: String, CaseIterable, Identifiable {
    case last12Hours
    case last24Hours
    case last3Days

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .last12Hours: return "Last 12 Hours"
        case .last24Hours: return "Last 24 Hours"
        case .last3Days:   return "Last 3 Days"
        }
    }

    var startDate: Date {
        let now = Date.now
        switch self {
        case .last12Hours: return now.addingTimeInterval(-12 * 3600)
        case .last24Hours: return now.addingTimeInterval(-24 * 3600)
        case .last3Days:   return now.addingTimeInterval(-3 * 24 * 3600)
        }
    }

    var xAxisFormat: Date.FormatStyle {
        switch self {
        case .last12Hours: return .dateTime.hour()
        case .last24Hours: return .dateTime.hour()
        case .last3Days:   return .dateTime.day().month()
        }
    }
}

private enum Region: String, CaseIterable, Identifiable {
    case north, south, east, west, central

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var localizedName: LocalizedStringKey {
        switch self {
        case .north:   return "label.text.north"
        case .south:   return "label.text.south"
        case .east:    return "label.text.east"
        case .west:    return "label.text.west"
        case .central: return "label.text.central"
        }
    }

    func pm25Value(from record: PM25Record) -> Int {
        switch self {
        case .north:   return record.north
        case .south:   return record.south
        case .east:    return record.east
        case .west:    return record.west
        case .central: return record.central
        }
    }

    func psiValue(from record: PSIRecord) -> Int {
        switch self {
        case .north:   return record.psi_twenty_four_hourly_north
        case .south:   return record.psi_twenty_four_hourly_south
        case .east:    return record.psi_twenty_four_hourly_east
        case .west:    return record.psi_twenty_four_hourly_west
        case .central: return record.psi_twenty_four_hourly_central
        }
    }
}

#Preview {
    HistoricalDataView()
#if os(macOS)
        .frame(width: 500, height: 600)
#endif
}
