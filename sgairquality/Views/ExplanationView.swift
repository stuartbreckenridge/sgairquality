//
//  ExplanationView.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 22/02/2026.
//

import SwiftUI

struct ExplanationView: View {

    // MARK: Environment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                computationSection
                psiSection
                pm25Section
                pm10Section
                ozoneSection
                carbonMonoxideSection
                nitrogenDioxideSection
                sulfurDioxideSection
            }
            .listStyle(.automatic)
            .accessibilityIdentifier("explanation.list")
            .navigationTitle(Text("label.text.air-quality-guide", comment: "Air Quality Guide"))
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
                    .accessibilityIdentifier("explanation.close.button")
                }
            }
        }
    }

    // MARK: - Sections

    private var computationSection: some View {
        Section {
            Text("label.text.computation-description", comment: "For each of the six pollutants, a sub-index is calculated by linearly interpolating the measured concentration against a set of breakpoints. The overall PSI is the highest sub-index value across all pollutants.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            // Sub-index formula
            VStack(alignment: .leading, spacing: 6) {
                Text("label.text.computation-formula-title", comment: "Sub-Index Formula")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(verbatim: "Iₚ = (IHI − ILO) / (BPHI − BPLO) × (Cp − BPLO) + ILO")
                    .font(.caption)
                    .monospacedDigit()
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(formulaTerms, id: \.term) { item in
                        HStack(alignment: .top, spacing: 4) {
                            Text(verbatim: item.term)
                                .font(.caption)
                                .monospacedDigit()
                                .frame(width: 36, alignment: .leading)
                            Text(item.definition)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
        } header: {
            Text("label.text.computation-title", comment: "How PSI Is Computed")
        } footer: {
            Text("label.text.computation-footer", comment: "Source: National Environment Agency, Singapore (March 2014).")
        }
    }

    private var psiSection: some View {
        Section {
            Text("label.text.psi-description", comment: "PSI is a composite index calculated from PM10, PM2.5, O3, CO, NO2, and SO2. A sub-index is calculated for each pollutant per region and the highest value is used as the overall PSI for that region. Use the 24-hour PSI to plan next-day outdoor activities.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BandTableView(rows: psiBandRows)
        } header: {
            Text("label.text.psi-full", comment: "Pollutant Standards Index (PSI)")
        }
    }

    private var pm25Section: some View {
        Section {
            Text("label.text.pm25-description", comment: "PM2.5 refers to inhalable fine particulate matter 2.5 micrometres and smaller. These particles can penetrate deep into the lungs. Use the 1-hour PM2.5 reading to decide on immediate outdoor activities.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BandTableView(rows: pm25BandRows)
            BreakpointTableView(
                title: Text("label.text.breakpoints-24h", comment: "Sub-Index Breakpoints (24-hour, µg/m³)"),
                rows: pm25BreakpointRows
            )
        } header: {
            Text("label.text.pm25-full", comment: "Fine Particulate Matter (PM2.5)")
        }
    }

    private var pm10Section: some View {
        Section {
            Text("label.text.pm10-description", comment: "PM10 refers to inhalable particulate matter 10 micrometres and smaller. These particles include dust, pollen, and mould spores and can irritate the eyes, nose, and throat.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BreakpointTableView(
                title: Text("label.text.breakpoints-24h", comment: "Sub-Index Breakpoints (24-hour, µg/m³)"),
                rows: pm10BreakpointRows
            )
        } header: {
            Text("label.text.pm10-full", comment: "Particulate Matter (PM10)")
        }
    }

    private var ozoneSection: some View {
        Section {
            Text("label.text.o3-description", comment: "Ground-level ozone forms when pollutants from vehicles and industry react in sunlight. It can cause respiratory irritation, especially during physical activity outdoors. Measured as an 8-hour maximum.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BreakpointTableView(
                title: Text("label.text.breakpoints-8h", comment: "Sub-Index Breakpoints (8-hour, µg/m³)"),
                rows: o3BreakpointRows
            )
        } header: {
            Text("label.text.o3-full", comment: "Ozone (O3)")
        }
    }

    private var carbonMonoxideSection: some View {
        Section {
            Text("label.text.co-description", comment: "Carbon monoxide is a colourless, odourless gas produced by incomplete combustion. High levels reduce the blood's ability to carry oxygen. Measured as an 8-hour maximum.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BreakpointTableView(
                title: Text("label.text.breakpoints-8h-mg", comment: "Sub-Index Breakpoints (8-hour, mg/m³)"),
                rows: coBreakpointRows
            )
        } header: {
            Text("label.text.co-full", comment: "Carbon Monoxide (CO)")
        }
    }

    private var nitrogenDioxideSection: some View {
        Section {
            Text("label.text.no2-description", comment: "Nitrogen dioxide is produced from vehicle emissions and industrial processes. It can irritate the airways and aggravate respiratory conditions such as asthma. Measured as a 1-hour maximum.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BreakpointTableView(
                title: Text("label.text.breakpoints-1h", comment: "Sub-Index Breakpoints (1-hour, µg/m³)"),
                rows: no2BreakpointRows
            )
            Text("label.text.no2-footnote", comment: "NO2 sub-index is only used when the 1-hour concentration exceeds 1,130 µg/m³.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Text("label.text.no2-full", comment: "Nitrogen Dioxide (NO2)")
        }
    }

    private var sulfurDioxideSection: some View {
        Section {
            Text("label.text.so2-description", comment: "Sulphur dioxide is released from burning fossil fuels and volcanic activity. It can cause respiratory irritation and contributes to haze and acid rain. Measured as a 24-hour average.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            BreakpointTableView(
                title: Text("label.text.breakpoints-24h", comment: "Sub-Index Breakpoints (24-hour, µg/m³)"),
                rows: so2BreakpointRows
            )
        } header: {
            Text("label.text.so2-full", comment: "Sulphur Dioxide (SO2)")
        }
    }

    // MARK: - Formula Terms

    private var formulaTerms: [(term: String, definition: LocalizedStringResource)] {
        [
            ("Iₚ", LocalizedStringResource("label.text.formula.ip", defaultValue: "Sub-index for pollutant p", comment: "Formula term: Ip")),
            ("Cp", LocalizedStringResource("label.text.formula.cp", defaultValue: "Measured concentration of pollutant p", comment: "Formula term: Cp")),
            ("BPHI", LocalizedStringResource("label.text.formula.bphi", defaultValue: "Breakpoint concentration ≥ Cp", comment: "Formula term: BPhi")),
            ("BPLO", LocalizedStringResource("label.text.formula.bplo", defaultValue: "Breakpoint concentration ≤ Cp", comment: "Formula term: BPlo")),
            ("IHI", LocalizedStringResource("label.text.formula.ihi", defaultValue: "Index value corresponding to BPHI", comment: "Formula term: Ihi")),
            ("ILO", LocalizedStringResource("label.text.formula.ilo", defaultValue: "Index value corresponding to BPLO", comment: "Formula term: Ilo"))
        ]
    }

    // MARK: - Band Data

    private var psiBandRows: [BandRow] {
        [
            BandRow(label: LocalizedStringResource("label.text.psi-good", defaultValue: "Good", comment: "PSI: Good (0-50)"), range: "0–50", color: .green, advisory: LocalizedStringResource("label.text.advisory.psi-good", defaultValue: "Normal activities for everyone.", comment: "PSI Good advisory")),
            BandRow(label: LocalizedStringResource("label.text.psi-moderate", defaultValue: "Moderate", comment: "PSI: Moderate (51-100)"), range: "51–100", color: .blue, advisory: LocalizedStringResource("label.text.advisory.psi-moderate", defaultValue: "Normal activities for everyone.", comment: "PSI Moderate advisory")),
            BandRow(label: LocalizedStringResource("label.text.psi-unhealthy", defaultValue: "Unhealthy", comment: "PSI: Unhealthy (101-200)"), range: "101–200", color: .yellow, advisory: LocalizedStringResource("label.text.advisory.psi-unhealthy", defaultValue: "Reduce prolonged outdoor exertion. Vulnerable persons should minimise outdoor activity.", comment: "PSI Unhealthy advisory")),
            BandRow(label: LocalizedStringResource("label.text.psi-very-unhealthy", defaultValue: "Very Unhealthy", comment: "PSI: Very Unhealthy (201-300)"), range: "201–300", color: .orange, advisory: LocalizedStringResource("label.text.advisory.psi-very-unhealthy", defaultValue: "Avoid prolonged outdoor exertion. Vulnerable persons should avoid outdoor activity.", comment: "PSI Very Unhealthy advisory")),
            BandRow(label: LocalizedStringResource("label.text.psi-hazardous", defaultValue: "Hazardous", comment: "PSI: Hazardous (301+)"), range: "≥ 301", color: .red, advisory: LocalizedStringResource("label.text.advisory.psi-hazardous", defaultValue: "Minimise outdoor activity. Vulnerable persons should stay indoors.", comment: "PSI Hazardous advisory"))
        ]
    }

    private var pm25BandRows: [BandRow] {
        [
            BandRow(label: LocalizedStringResource("label.text.pm25-normal", defaultValue: "Normal", comment: "PM2.5: Normal (0-55)"), range: "0–55", color: .green, advisory: LocalizedStringResource("label.text.advisory.pm25-normal", defaultValue: "Normal activities for everyone.", comment: "PM2.5 Normal advisory")),
            BandRow(label: LocalizedStringResource("label.text.pm25-elevated", defaultValue: "Elevated", comment: "PM2.5: Elevated (56-150)"), range: "56–150", color: .yellow, advisory: LocalizedStringResource("label.text.advisory.pm25-elevated", defaultValue: "Reduce strenuous outdoor activities. Vulnerable persons should avoid strenuous outdoor activity.", comment: "PM2.5 Elevated advisory")),
            BandRow(label: LocalizedStringResource("label.text.pm25-high", defaultValue: "High", comment: "PM2.5: High (151-250)"), range: "151–250", color: .orange, advisory: LocalizedStringResource("label.text.advisory.pm25-high", defaultValue: "Avoid prolonged outdoor exertion. Vulnerable persons should avoid outdoor activity.", comment: "PM2.5 High advisory")),
            BandRow(label: LocalizedStringResource("label.text.pm25-very-high", defaultValue: "Very High", comment: "PM2.5: Very High (251+)"), range: "≥ 251", color: .red, advisory: LocalizedStringResource("label.text.advisory.pm25-very-high", defaultValue: "Minimise outdoor activity. Vulnerable persons should stay indoors.", comment: "PM2.5 Very High advisory"))
        ]
    }

    // MARK: - Breakpoint Data

    private var pm25BreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "0–50", concentration: "0–12"),
            BreakpointRow(psiRange: "51–100", concentration: "12–55"),
            BreakpointRow(psiRange: "101–200", concentration: "55–150"),
            BreakpointRow(psiRange: "201–300", concentration: "150–250"),
            BreakpointRow(psiRange: "301–400", concentration: "250–350"),
            BreakpointRow(psiRange: "401–500", concentration: "350–500")
        ]
    }

    private var pm10BreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "0–50", concentration: "0–50"),
            BreakpointRow(psiRange: "51–100", concentration: "50–150"),
            BreakpointRow(psiRange: "101–200", concentration: "150–350"),
            BreakpointRow(psiRange: "201–300", concentration: "350–420"),
            BreakpointRow(psiRange: "301–400", concentration: "420–500"),
            BreakpointRow(psiRange: "401–500", concentration: "500–600")
        ]
    }

    private var o3BreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "0–50", concentration: "0–118"),
            BreakpointRow(psiRange: "51–100", concentration: "118–157"),
            BreakpointRow(psiRange: "101–200", concentration: "157–235"),
            BreakpointRow(psiRange: "201–300", concentration: "235–785 †"),
            BreakpointRow(psiRange: "301–400", concentration: "785–980 †"),
            BreakpointRow(psiRange: "401–500", concentration: "980–1,180 †")
        ]
    }

    private var coBreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "0–50", concentration: "0–5.0"),
            BreakpointRow(psiRange: "51–100", concentration: "5.0–10.0"),
            BreakpointRow(psiRange: "101–200", concentration: "10.0–17.0"),
            BreakpointRow(psiRange: "201–300", concentration: "17.0–34.0"),
            BreakpointRow(psiRange: "301–400", concentration: "34.0–46.0"),
            BreakpointRow(psiRange: "401–500", concentration: "46.0–57.5")
        ]
    }

    private var no2BreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "201–300", concentration: "1,130–2,260"),
            BreakpointRow(psiRange: "301–400", concentration: "2,260–3,000"),
            BreakpointRow(psiRange: "401–500", concentration: "3,000–3,750")
        ]
    }

    private var so2BreakpointRows: [BreakpointRow] {
        [
            BreakpointRow(psiRange: "0–50", concentration: "0–80"),
            BreakpointRow(psiRange: "51–100", concentration: "80–365"),
            BreakpointRow(psiRange: "101–200", concentration: "365–800"),
            BreakpointRow(psiRange: "201–300", concentration: "800–1,600"),
            BreakpointRow(psiRange: "301–400", concentration: "1,600–2,100"),
            BreakpointRow(psiRange: "401–500", concentration: "2,100–2,620")
        ]
    }
}

// MARK: - Supporting Types

private struct BandRow {
    let label: LocalizedStringResource
    let range: String
    let color: Color
    let advisory: LocalizedStringResource
}

private struct BreakpointRow {
    let psiRange: String
    let concentration: String
}

// MARK: - Band Table View

private struct BandTableView: View {
    let rows: [BandRow]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("label.text.band", comment: "Band")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("label.text.range", comment: "Range")
                    .frame(width: 70, alignment: .center)
                Text("label.text.advisory", comment: "Advisory")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.vertical, 6)

            Divider()

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(alignment: .top, spacing: 8) {
                    Text(row.label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(row.color, in: Capsule())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(verbatim: row.range)
                        .font(.caption)
                        .monospacedDigit()
                        .frame(width: 70, alignment: .center)
                    Text(row.advisory)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 6)

                if index < rows.count - 1 {
                    Divider()
                }
            }
        }
    }
}

// MARK: - Breakpoint Table View

private struct BreakpointTableView: View {
    let title: Text
    let rows: [BreakpointRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            title
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.bottom, 6)

            HStack {
                Text("label.text.psi-index", comment: "PSI")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("label.text.concentration", comment: "Concentration")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)

            Divider()

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack {
                    Text(verbatim: row.psiRange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(verbatim: row.concentration)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.caption)
                .monospacedDigit()
                .padding(.vertical, 4)

                if index < rows.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    ExplanationView()
}
