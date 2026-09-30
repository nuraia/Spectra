//
//  SignalSmoother.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 29/9/26.
//

import Foundation

final class SignalSmoother {

    private var previousValues: [Float] = []

    private let attack: Float
    private let decay: Float

    init(
        attack: Float = 0.75,
        decay: Float = 0.20
    ) {
        self.attack = attack
        self.decay = decay
    }

    func smooth(_ values: [Float]) -> [Float] {

        if previousValues.count != values.count {
            previousValues = Array(
                repeating: 0,
                count: values.count
            )
        }

        var output = values

        for index in values.indices {

            let current = values[index]
            let previous = previousValues[index]

            let factor =
                current > previous
                ? attack
                : decay

            output[index] =
                previous +
                (current - previous) * factor
        }

        previousValues = output

        return output
    }
}
