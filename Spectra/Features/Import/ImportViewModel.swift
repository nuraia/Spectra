//
//  ImportViewModel.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import Foundation
import Combine

@MainActor
final class ImportViewModel: ObservableObject {

    @Published var selectedTrack: Track?
    @Published var errorMessage: String?
    
    private let coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func handleSelectedFile(url: URL) {
          let track = Track(
              url: url,
              title: url.deletingPathExtension().lastPathComponent
          )

          selectedTrack = track
          coordinator.showPlayer(track: track)
      }

      func handleError(_ error: Error) {
          errorMessage = error.localizedDescription
      }
    
}
