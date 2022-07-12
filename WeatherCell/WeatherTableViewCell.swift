//
//  WeatherTableViewCell.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-05-22.
//
import Foundation
import UIKit

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static let identifer = "WeatherTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configureWithModel(with model: Daily) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        self.lowTempLabel.text = "\(Int(model.temp.min))°"
        self.highTempLabel.text = "\(Int(model.temp.max))°"
        
        self.dayLabel.text = getFormattedDayForDate(Date(timeIntervalSince1970: Double(model.dt)))
        self.iconImageView.contentMode = .scaleAspectFit
        
        let weatherIcon = model.weather[0].main.lowercased()
        
        if weatherIcon.contains("clear") {
            self.iconImageView.image = UIImage(named: "clear")
        } else if weatherIcon.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        } else if weatherIcon.contains("thunderstrom") {
            self.iconImageView.image = UIImage(named: "thunderstorm")
        } else if weatherIcon.contains("snow") {
            self.iconImageView.image = UIImage(named: "snow")
        } else if weatherIcon.contains("clouds") {
            self.iconImageView.image = UIImage(named: "cloud")
        }
    }
    
    func getFormattedDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: inputDate)
    }
}
