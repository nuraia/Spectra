//
//  FrequencyBandAnalyzer.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 29/9/26.
//

import Foundation

final class FrequencyBandAnalyzer {

    private let bandCount: Int

    init(bandCount: Int = 32) {
        self.bandCount = bandCount
    }

    func analyze(
        magnitudes: [Float],
        sampleRate: Double
    ) -> [Float] {
        
        guard !magnitudes.isEmpty else {
            return Array(repeating: 0, count: bandCount)
        }
        
        let nyquist = sampleRate / 2
        let binFrequency = nyquist / Double(magnitudes.count)
        
        let minFrequency = 20.0
        let maxFrequency = min(14_000.0, nyquist)
        
        var bands = [Float](repeating: 0, count: bandCount)
        
        for bandIndex in 0..<bandCount {
            
            let startRatio = Double(bandIndex) / Double(bandCount)
            let endRatio = Double(bandIndex + 1) / Double(bandCount)
            
            let startFrequency =
            minFrequency * pow(maxFrequency / minFrequency, startRatio)
            
            let endFrequency =
            minFrequency * pow(maxFrequency / minFrequency, endRatio)
            
            let startBin = max(
                0,
                Int(startFrequency / binFrequency)
            )
            
            let endBin = min(
                magnitudes.count - 1,
                Int(endFrequency / binFrequency)
            )
            
            guard endBin >= startBin else {
                continue
            }
            
            var sum: Float = 0
            
            for bin in startBin...endBin {
                sum += magnitudes[bin]
            }
            
            let count = Float(endBin - startBin + 1)
            
            let average = sum / count
            
            bands[bandIndex] = average
        }
        
        let maxValue = bands.max() ?? 1
        
        if maxValue > 0 {
            bands = bands.map {
                min(max($0 / maxValue, 0), 1)
            }
        }
        return bands
    }
}
