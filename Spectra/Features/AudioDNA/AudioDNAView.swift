//
//  AudioDNAView.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import SwiftUI

struct AudioDNAView: View {

    let track: Track
    let features: AudioFeatures
    
    private func featureRow(
        title: String,
        value: Float
    ) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(title)

                Spacer()

                Text("\(Int(value * 100))%")
                    .foregroundStyle(.secondary)
            }

            ProgressView(
                value: Double(value),
                total: 1
            )
            .tint(.purple)
        }
    }

    var body: some View {
        VStack(spacing: 18) {

            Text("AUDIO DNA")
                .font(.title.bold())

            featureRow(
                title: "Bass",
                value: features.bass
            )

            featureRow(
                title: "Mids",
                value: features.mids
            )

            featureRow(
                title: "Treble",
                value: features.treble
            )

            featureRow(
                title: "Energy",
                value: features.energy
            )

            featureRow(
                title: "Brightness",
                value: features.brightness
            )
        }
        .padding()
    }
}
