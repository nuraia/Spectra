//
//  AppRoute.swift
//  Spectra
//
//  Created by Nuraia Nahrin Fahmida on 28/9/26.
//

import Foundation

enum AppRoute: Hashable{
    case player(Track)
    case visualizer(Track)
    case audioDNA(Track, AudioFeatures)
}
