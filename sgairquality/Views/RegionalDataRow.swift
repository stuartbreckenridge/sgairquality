//
//  RegionalDataRow.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 20/02/2026.
//

import SwiftUI

/// Helper view to display a regional data row with a title and value
struct RegionalDataRow: View {
    let title: LocalizedStringResource
    let value: Int
    var dataType: DataType = .other

    enum DataType {
        case psi
        case pm25
        case other
    }

    /// Returns the PSI band information (label and color)
    private var psiBand: (label: LocalizedStringResource, color: Color)? {
        switch value {
        case 0...50:
            return (LocalizedStringResource("label.text.psi-good", defaultValue: "Good", comment: "PSI: Good (0-50)"), .green)
        case 51...100:
            return (LocalizedStringResource("label.text.psi-moderate", defaultValue: "Moderate", comment: "PSI: Moderate (51-100)"), .blue)
        case 101...200:
            return (LocalizedStringResource("label.text.psi-unhealthy", defaultValue: "Unhealthy", comment: "PSI: Unhealthy (101-200)"), .yellow)
        case 201...300:
            return (LocalizedStringResource("label.text.psi-very-unhealthy", defaultValue: "Very Unhealthy", comment: "PSI: Very Unhealthy (201-300)"), .orange)
        default:
            return (LocalizedStringResource("label.text.psi-hazardous", defaultValue: "Hazardous", comment: "PSI: Hazardous (301+)"), .red)
        }
    }

    /// Returns the PM2.5 band information (label and color)
    private var pm25Band: (label: LocalizedStringResource, color: Color)? {
        switch value {
        case 0...55:
            return (LocalizedStringResource("label.text.pm25-normal", defaultValue: "Normal", comment: "PM2.5: Normal (0-55)"), .green)
        case 56...150:
            return (LocalizedStringResource("label.text.pm25-elevated", defaultValue: "Elevated", comment: "PM2.5: Elevated (56-150)"), .yellow)
        case 151...250:
            return (LocalizedStringResource("label.text.pm25-high", defaultValue: "High", comment: "PM2.5: High (151-250)"), .orange)
        default:
            return (LocalizedStringResource("label.text.pm25-very-high", defaultValue: "Very High", comment: "PM2.5: Very High (251+)"), .red)
        }
    }

    /// Returns the appropriate band information based on data type
    private var bandInfo: (label: LocalizedStringResource, color: Color)? {
        switch dataType {
        case .psi:
            return psiBand
        case .pm25:
            return pm25Band
        case .other:
            return nil
        }
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let band = bandInfo {
                Text(band.label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(band.color, in: Capsule())
            }
            Text("\(value)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
