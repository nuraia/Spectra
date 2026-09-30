//
//  ImportView.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {

    @EnvironmentObject private var coordinator: AppCoordinator

      @State private var isFileImporterPresented = false

      var body: some View {
          ImportContentView(
              coordinator: coordinator,
              isFileImporterPresented: $isFileImporterPresented
          )
      }
  }

  private struct ImportContentView: View {

      @StateObject private var viewModel: ImportViewModel

      @Binding var isFileImporterPresented: Bool

      init(
          coordinator: AppCoordinator,
          isFileImporterPresented: Binding<Bool>
      ) {
          _viewModel = StateObject(
              wrappedValue: ImportViewModel(coordinator: coordinator)
          )

          _isFileImporterPresented = isFileImporterPresented
      }

      var body: some View {
          VStack(spacing: 20) {

              Image(systemName: "waveform.circle.fill")
                  .font(.system(size: 80))

              Text("SPECTRA")
                  .font(.largeTitle.bold())

              Text("See what you're hearing.")
                  .foregroundStyle(.secondary)

              Button("Choose a Song") {
                  isFileImporterPresented = true
              }
              .buttonStyle(.borderedProminent)

              if let errorMessage = viewModel.errorMessage {
                  Text(errorMessage)
                      .foregroundStyle(.red)
                      .font(.caption)
              }
          }
          .padding()
          .fileImporter(
              isPresented: $isFileImporterPresented,
              allowedContentTypes: [.audio],
              allowsMultipleSelection: false
          ) { result in
              switch result {

              case .success(let urls):
                  guard let url = urls.first else { return }

                  viewModel.handleSelectedFile(url: url)

              case .failure(let error):
                  viewModel.handleError(error)
              }
          }
      }
}

#Preview {
    ImportView()
}
