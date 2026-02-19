//
//  ReadingsAnnotationView.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 20/02/2026.
//

import SwiftUI

struct ReadingsAnnotationView: View {

    // MARK: Environment

    // MARK: App Storage

    // MARK: State Objects

    // MARK: State

    // MARK: Bindings

    // MARK: Constants

    // MARK: Variables
    var pm25: Int
    var psi: Int

    // MARK: Computed Properties
    private var pm25Color: Color {
        switch pm25 {
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

    private var psiColor: Color {
        switch psi {
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

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                Text(verbatim: "PM2.5")
                    .bold()
                Text(verbatim: String(pm25))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(pm25Color)
            Divider()
                .overlay {
                    Color.white
                }
            VStack(alignment: .center) {
                Text(verbatim: "PSI")
                    .bold()
                Text(verbatim: String(psi))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(psiColor)
        }
        .font(.caption)
        .fixedSize()
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

}

#Preview("Good Air Quality") {
    ReadingsAnnotationView(pm25: 30, psi: 40)
}
#Preview("Moderate PSI") {
    ReadingsAnnotationView(pm25: 40, psi: 75)
}

#Preview("Elevated PM2.5") {
    ReadingsAnnotationView(pm25: 100, psi: 45)
}

#Preview("Unhealthy") {
    ReadingsAnnotationView(pm25: 180, psi: 150)
}

#Preview("Hazardous") {
    ReadingsAnnotationView(pm25: 280, psi: 350)
}
