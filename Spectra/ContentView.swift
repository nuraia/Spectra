//
//  ContentView.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {

        NavigationStack(path: $coordinator.path) {

            ImportView()

                .navigationDestination(for: AppRoute.self) { route in

                    switch route {

                    case .player(let track):
                        PlayerView(track: track)

                    case .visualizer(let track):
                        VisualizerView(track: track)

                    case .audioDNA(let track, let features):
                        AudioDNAView(
                            track: track,
                            features: features
                        )
                    }
                }
        }
    }
}
