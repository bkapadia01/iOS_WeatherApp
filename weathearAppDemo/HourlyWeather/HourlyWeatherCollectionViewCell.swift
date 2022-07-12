//
//  HourlyWeatherCollectionViewCell.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-06-14.
//

import Foundation
import UIKit

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    static let identifer = "HourlyWeatherCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "HourlyWeatherCollectionViewCell", bundle: nil)
    }
    
    func configureWithModel(with model: [Current]) {
        let currentTime = formatHourForHourlyForecast(Date(timeIntervalSince1970: Double(model[0].dt)))
        self.timeLabel.text = "\(currentTime)"
        self.tempLabel.text = "\(Int(model[0].temp))°C"
        
        self.weatherImage.contentMode = .scaleAspectFit
        let weatherIcon = model[0].weather[0].main.lowercased()

        if weatherIcon.contains("clear") {
            self.weatherImage.image = UIImage(named: "clear")
        } else if weatherIcon.contains("rain") {
            self.weatherImage.image = UIImage(named: "rain")
        } else if weatherIcon.contains("thunderstrom") {
            self.weatherImage.image = UIImage(named: "thunderstorm")
        } else if weatherIcon.contains("snow") {
            self.weatherImage.image = UIImage(named: "snow")
        } else if weatherIcon.contains("clouds") {
            self.weatherImage.image = UIImage(named: "cloud")
        }
    }
    
    func formatHourForHourlyForecast(_ hour: Date?) -> String {
        guard let inputData = hour else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: inputData)
    }
}
