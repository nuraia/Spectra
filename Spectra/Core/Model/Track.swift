//
//  Track.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import Foundation

struct Track: Hashable, Identifiable {
    let id = UUID()
    let url: URL
    let title: String
}
