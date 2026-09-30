//
//  PlayerViewModel.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import Foundation
import Combine
internal import AVFAudio

@MainActor
final class PlayerViewModel: ObservableObject {
    
    @Published var isPlaying = false
    @Published var errorMessage: String?
    
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    @Published var frequencyBands: [Float] = Array(repeating: 0, count: 24)
    
    @Published var beatIntensity: Float = 0
    
    @Published var audioFeatures = AudioFeatures(
        bass: 0,
        mids: 0,
        treble: 0,
        energy: 0,
        brightness: 0
    )
    
    private let fftProcessor = FFTProcessor()
    private let bandAnalyzer = FrequencyBandAnalyzer(bandCount: 24)
    private let signalSmoother = SignalSmoother()
    private let beatDetector = BeatDetector()
    private let audioDNAAnalyzer = AudioDNAAnalyzer()
    
    let track: Track
    
    private let audioPlayer = AudioPlayerService()
    private var timer: Timer?
    
    init(track: Track) {
        self.track = track
        
        do {
            try audioPlayer.load(url: track.url)
            duration = audioPlayer.duration
            startTimer()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        audioPlayer.onAudioBuffer = { [weak self] buffer in
            guard let self else { return }

            let magnitudes = self.fftProcessor.process(buffer: buffer)
            
            let bands = self.bandAnalyzer.analyze(
                magnitudes: magnitudes,
                sampleRate: buffer.format.sampleRate
            )
            
            let beat = self.beatDetector.detect(
                from: bands
            )

            let smoothedBands = self.signalSmoother.smooth(bands)
            
            let features =
                self.audioDNAAnalyzer.analyze(
                    bands: smoothedBands
                )
            
            Task { @MainActor in
                self.frequencyBands = smoothedBands
                self.beatIntensity = max(
                    beat,
                    self.beatIntensity * 0.82
                )
                self.audioFeatures = features
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            Task { @MainActor in
                guard self.isPlaying else { return }
                
                self.currentTime = self.audioPlayer.currentTime
            }
        }
    }
    
    func togglePlayback() {
        do {
            if isPlaying {
                currentTime = audioPlayer.currentTime
                audioPlayer.pause()
                isPlaying = false
            } else {
                try audioPlayer.play()
                isPlaying = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
