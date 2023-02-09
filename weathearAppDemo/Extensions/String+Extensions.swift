//
//  String+Extensions.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-08-30.
//

import Foundation

extension String {
    func localized() -> String{
        var fileName = String()
        fileName = "WeatherLocalizable"
        return NSLocalizedString(self, tableName: fileName, bundle: Bundle.main, value: String(), comment: String())
    }
}
