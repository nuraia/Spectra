//
//  FFTProcessor.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 29/9/26.
//

import Foundation
import AVFoundation
import Accelerate

final class FFTProcessor {

    private let fftSize: Int
    private let log2n: vDSP_Length
    private let fftSetup: FFTSetup?

    init(fftSize: Int = 2048) {
        self.fftSize = fftSize
        self.log2n = vDSP_Length(log2(Float(fftSize)))
        self.fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
    }

    deinit {
        if let fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }

    func process(buffer: AVAudioPCMBuffer) -> [Float] {
        
        guard
            let channelData = buffer.floatChannelData?[0],
            let fftSetup
        else {
            return []
        }
        
        let frameCount = min(Int(buffer.frameLength), fftSize)
        
        var samples = [Float](repeating: 0, count: fftSize)
        
        for index in 0..<frameCount {
            samples[index] = channelData[index]
        }
        
        var window = [Float](repeating: 0, count: fftSize)
        
        vDSP_hann_window(
            &window,
            vDSP_Length(fftSize),
            Int32(vDSP_HANN_NORM)
        )
        
        vDSP_vmul(
            samples,
            1,
            window,
            1,
            &samples,
            1,
            vDSP_Length(fftSize)
        )
        
        var real = [Float](repeating: 0, count: fftSize / 2)
        var imag = [Float](repeating: 0, count: fftSize / 2)
        
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        
        real.withUnsafeMutableBufferPointer { realBuffer in
            imag.withUnsafeMutableBufferPointer { imagBuffer in
                
                var splitComplex = DSPSplitComplex(
                    realp: realBuffer.baseAddress!,
                    imagp: imagBuffer.baseAddress!
                )
                
                samples.withUnsafeBytes { rawBuffer in
                    
                    let complexPointer = rawBuffer
                        .bindMemory(to: DSPComplex.self)
                    
                    vDSP_ctoz(
                        complexPointer.baseAddress!,
                        2,
                        &splitComplex,
                        1,
                        vDSP_Length(fftSize / 2)
                    )
                }
                
                vDSP_fft_zrip(
                    fftSetup,
                    &splitComplex,
                    1,
                    log2n,
                    FFTDirection(FFT_FORWARD)
                )
                
                vDSP_zvabs(
                    &splitComplex,
                    1,
                    &magnitudes,
                    1,
                    vDSP_Length(fftSize / 2)
                )
            }
        }
        
        let scale = Float(fftSize)
        
        return magnitudes.map {
            $0 / scale
        }
    }
}
