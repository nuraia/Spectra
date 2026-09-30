//
//  SpectraApp.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import SwiftUI

@main
struct SpectraApp: App {

    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {

        WindowGroup {

            RootView()
                .environmentObject(coordinator)
        }
    }
}
