//
//  AudioPlayerService.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import Foundation
import AVFoundation

final class AudioPlayerService {

    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    private var audioFile: AVAudioFile?
    private var securityScopedURL: URL?
    
    var onAudioBuffer: ((AVAudioPCMBuffer) -> Void)?
    
    private var shouldAnalyzeAudio = false

    init() {
        audioEngine.attach(playerNode)

    }

    func load(url: URL) throws {
        if let oldURL = securityScopedURL {
            oldURL.stopAccessingSecurityScopedResource()
            securityScopedURL = nil
        }

        if url.startAccessingSecurityScopedResource() {
            securityScopedURL = url
        }
        
        let file = try AVAudioFile(forReading: url)
        print("URL:", url)
        print("File length frames:", file.length)
        print("Processing sample rate:", file.processingFormat.sampleRate)
        print("File sample rate:", file.fileFormat.sampleRate)
        print("Processing format:", file.processingFormat)
        print("Calculated duration:", Double(file.length) / file.processingFormat.sampleRate)
        audioFile = file
        audioEngine.disconnectNodeOutput(playerNode)

        audioEngine.connect(
            playerNode,
            to: audioEngine.outputNode,
            format: file.processingFormat
        )

        audioEngine.prepare()
        
        playerNode.removeTap(onBus: 0)

        playerNode.installTap(
            onBus: 0,
            bufferSize: 2048,
            format: file.processingFormat
        ) { [weak self] buffer, _ in
            guard let self else { return }
            guard self.shouldAnalyzeAudio else { return }
            
            self.onAudioBuffer?(buffer)
        }
        
        playerNode.stop()

        file.framePosition = 0

        playerNode.scheduleSegment(
            file,
            startingFrame: 0,
            frameCount: AVAudioFrameCount(file.length),
            at: nil,
            completionHandler: nil
        )
    }

    func play() throws {
        print("Audio engine running:", audioEngine.isRunning)
        print("Player node playing:", playerNode.isPlaying)
        if !audioEngine.isRunning {
            try audioEngine.start()
        }

        playerNode.play()
        shouldAnalyzeAudio = true
        
        print("Player started:", playerNode.isPlaying)
    }

    func pause() {
        playerNode.pause()
        shouldAnalyzeAudio = false
    }

    func stop() {
        playerNode.stop()
        shouldAnalyzeAudio = false
    }
    
    var duration: Double {
        guard let audioFile else { return 0 }

        return Double(audioFile.length) / audioFile.processingFormat.sampleRate
    }
    
    var currentTime: Double {
        guard
            let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime)
        else {
            return 0
        }

        return Double(playerTime.sampleTime) / playerTime.sampleRate
    }
    
    deinit {
        securityScopedURL?.stopAccessingSecurityScopedResource()
    }
}
