//
//  WeatherAPIResponse.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-05-31.
//
// passing this by value vs passing by reference...when you write a renderer (ui view controller), always start with struct - pass by value when possible rather than object....passing by ref is conveinient but also very dangerous that can cause the data to be changed when you dont want it to be changed


import Foundation
 
// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    var lat: Int?
    var lon: Int?
    var timezone: String?
    var timezoneOffset: Int?
    var current: Current
    var hourly: [Current]
    var daily: [Daily]
}

// MARK: - Current
struct Current: Codable  {
    var dt: Int
    var sunrise: Int?
    var sunset: Int?
    var temp: Double
    var feelsLike: Double?
    var pressure: Int?
    var humidity: Int?
    var dewPoint: Double?
    var uvi: Double?
    var clouds: Int?
    var visibility: Int?
    var windSpeed: Double?
    var windDeg: Int?
    var weather: [Weather]
}

// MARK: - Weather
struct Weather: Codable  {
    var id: Int?
    var main: String
    var weatherDescription: String?
    var icon: String?
}

// MARK: - Daily
struct Daily: Codable  {
    var dt: Int
    var sunrise: Int?
    var sunset: Int?
    var moonrise: Int?
    var moonset: Int?
    var moonPhase: Double?
    var temp: Temp
    var feelsLike: FeelsLike?
    var pressure: Int?
    var humidity: Int?
    var dewPoint: Double?
    var windSpeed: Double?
    var windDeg: Int?
    var windGust: Double?
    var weather: [Weather]
    var clouds: Int?
    var pop: Float?
    var uvi: Double?
}

// MARK: - FeelsLike
struct FeelsLike: Codable  {
    var day: Double?
    var night: Double?
    var eve: Double?
    var morn: Double?
}

// MARK: - Temp
struct Temp: Codable  {
    var day: Double
    var min: Double
    var max: Double
    var night: Double?
    var eve: Double?
    var morn: Double?
}

