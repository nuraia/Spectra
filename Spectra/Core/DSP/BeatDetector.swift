//
//  BeatDetector.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 29/9/26.
//

import Foundation

final class BeatDetector {

    private var previousEnergy: Float = 0
    private var averageEnergy: Float = 0

    private let smoothing: Float = 0.9
    private let threshold: Float = 1.18

    func detect(from bands: [Float]) -> Float {

        guard !bands.isEmpty else {
            return 0
        }

        let bassBandCount = min(6, bands.count)

        let bassEnergy =
            bands.prefix(bassBandCount).reduce(0, +)
            / Float(bassBandCount)

        averageEnergy =
            smoothing * averageEnergy
            + (1 - smoothing) * bassEnergy

        let suddenIncrease =
            bassEnergy - previousEnergy

        previousEnergy = bassEnergy

        guard averageEnergy > 0 else {
            return 0
        }

        let ratio =
            bassEnergy / averageEnergy

        if ratio > threshold && suddenIncrease > 0 {

            return min(
                (ratio - threshold) * 2,
                1
            )
        }

        return 0
    }
}
