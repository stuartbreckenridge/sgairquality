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
    
    /// Returns the color indicator for PSI values based on categorization
    private var psiColor: Color {
        switch value {
        case 0...50:
            return .green
        case 51...100:
            return .blue
        case 101...200:
            return .yellow
        case 201...300:
            return .orange
        default:
            return .red
        }
    }
    
    /// Returns the color indicator for PM2.5 values based on categorization
    private var pm25Color: Color {
        switch value {
        case 0...55:
            return .green
        case 56...150:
            return .yellow
        case 151...250:
            return .orange
        default:
            return .red
        }
    }
    
    /// Returns the appropriate color based on data type
    private var indicatorColor: Color? {
        switch dataType {
        case .psi:
            return psiColor
        case .pm25:
            return pm25Color
        case .other:
            return nil
        }
    }

    var body: some View {
        HStack {
            if let color = indicatorColor {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
            Text(title)
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
        }
    }
}
