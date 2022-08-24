//
//  WeatherService.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-08-17.
//

import Foundation

class WeatherService {
    
    static func getWeather(cityLongitude: Double, cityLatitude: Double, completion: @escaping (WeatherResponse?, Error?) -> Void) {
        
        if let url = Self.getWebsiteAPIUrl(cityLongitude: cityLongitude, cityLatitude: cityLatitude) {
            let task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
                   guard let data = data, error == nil else {
                       print(WeatherLocalizable.apiError.localized())
                       return
                   }
                // convert data to models object
                  do {
                      let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                      completion(weatherResponse, nil)
                  } catch {
                     completion(nil, error)
                  }
            })
            task.resume()
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            completion(nil, error)
        }
    }
    
    private static func getWebsiteAPIUrl(cityLongitude: Double, cityLatitude: Double) -> URL? {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(cityLatitude)&lon=\(cityLongitude)&exclude=minutely,alerts&units=metric&appid=f1266e7ef11b56cc3e6f353b3bb2c635")
        return url
    }
    
}

