//
//  AppCoordinator.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    func showPlayer(track: Track) {
        path.append(AppRoute.player(track))
    }

    func showVisualizer(track: Track) {
        path.append(AppRoute.visualizer(track))
    }

    func showAudioDNA(track: Track, features: AudioFeatures) {
        path.append(AppRoute.audioDNA(
                track,
                features
            )
        )
    }

    func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
