//
//  AudioDNAAnalyzer.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 29/9/26.
//

import Foundation

final class AudioDNAAnalyzer {

    func analyze(bands: [Float]) -> AudioFeatures {

        guard bands.count >= 24 else {
            return AudioFeatures(
                bass: 0,
                mids: 0,
                treble: 0,
                energy: 0,
                brightness: 0
            )
        }

        let bassValues = bands[0..<6]
        let midValues = bands[6..<16]
        let trebleValues = bands[16..<24]

        let bass = average(bassValues)
        let mids = average(midValues)
        let treble = average(trebleValues)

        let energy =
            bands.reduce(0, +) /
            Float(bands.count)

        let brightness =
            min(treble * 1.3, 1)

        return AudioFeatures(
            bass: bass,
            mids: mids,
            treble: treble,
            energy: energy,
            brightness: brightness
        )
    }

    private func average(
        _ values: ArraySlice<Float>
    ) -> Float {

        guard !values.isEmpty else {
            return 0
        }

        return values.reduce(0, +)
            / Float(values.count)
    }
}
