//
//  WeatherAppStrings.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-07-17.
//

import Foundation
import CoreData

enum WeatherLocalizable: String {
    case currentLocation = "currentLocation"
    case cityChicago = "cityChicago"
    case cityLondon = "cityLondon"
    case cityTokyo = "cityTokyo"
    case citySydney = "citySydney"
    case cityBerlin = "cityBerlin"
    case cancel = "cancel"
    case apiError = "apiError"
    case error = "error"
    case locationErrorExpand = "locationErrorExpand"
    case ok = "ok"
    
    func localized() -> String {
        rawValue.localized()
    }
}
