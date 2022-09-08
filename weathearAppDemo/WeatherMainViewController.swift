//
//  WeatherMainViewController.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-05-22.
//

import UIKit
import CoreLocation

struct RenderableCityInfo {
    var cityLongitude: Double
    var cityLatitude: Double
    var cityName:String
    var currentTemperature: Double
    var weatherCondition: [Weather]
    var dailyWeatherModel:[Daily]
    var hourlyWeatherModel:[Current]
    var cityBackgroundImage: UIImage?
}

class WeatherMainViewController: UIViewController, CitySelectedProtocol {
    
    @IBOutlet weak var currentInfoView: UIView!
    @IBOutlet var dailyWeatherTableView: UITableView!
    @IBOutlet weak var hourlyWeatherCollectionView: UICollectionView!
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var currentConditions: UIImageView!
    
    
    let locationManager  = CLLocationManager()
    let geoCoder = CLGeocoder()
    let cityPickerView: UIPickerView = UIPickerView()
    
    let defautBackgroundImage = "default"
    var currentLocation: CLLocation?
    var currentCityRenderableInfo:RenderableCityInfo?
    var currentLocationName: String = ""
    var navBarAccessory:UIToolbar = UIToolbar()
    var locationLabel:UILabel = UILabel()
    var weatherConditionLabel:UILabel = UILabel()
    var currentTemperatureLabel:UILabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrieveLocationOnAppStartup()
        loadDailyWeatherTableCells()
        loadHourlyWeatherCollections()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(cityPickerController))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMainVCToCitySelector" {
            let secondVC: CitySelectorViewController = segue.destination as! CitySelectorViewController
            secondVC.delegate = self
        }
    }
    
    func userSelectedCity(cityLongitude: Double, cityLatitude: Double, cityName: String) {
        reloadUIViewToClearData()
        requestWeatherForLocation(cityLongitude: cityLongitude,
                                  cityLatitude: cityLatitude,
                                  cityName: cityName)
    }
    
    
    func loadHourlyWeatherCollections() {
        hourlyWeatherCollectionView.register(HourlyWeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifer)
        hourlyWeatherCollectionView.delegate = self
        hourlyWeatherCollectionView.dataSource = self
    }
    
    func loadDailyWeatherTableCells() {
        dailyWeatherTableView.register(DailyWeatherTableViewCell.nib(), forCellReuseIdentifier: DailyWeatherTableViewCell.identifer)
        dailyWeatherTableView.delegate = self
        dailyWeatherTableView.dataSource = self
    }
    
    //MARK: City picker view with selection of cities and navigation bar
    @objc func cityPickerController() {
        self.performSegue(withIdentifier: "segueMainVCToCitySelector", sender: self)
    }
    
    
    func retrieveLocationOnAppStartup() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func requestWeatherForLocation(cityLongitude: Double, cityLatitude: Double, cityName: String) {
        
        WeatherService.getWeather(cityLongitude: cityLongitude, cityLatitude: cityLatitude) { weatherResponse, error in
            if let error = error {
                // present user facing error
                print(error)
            } else {
                guard let results = weatherResponse else {
                    return
                }
                self.locationManager.stopUpdatingLocation()
                let dailyEntries = results.daily
                let hourlyEntries =  Array(results.hourly[1...12])
                
                DispatchQueue.main.async {
                    
                    self.currentCityRenderableInfo = RenderableCityInfo(cityLongitude: cityLongitude,
                                                                        cityLatitude: cityLatitude,
                                                                        cityName: WeatherLocalizable.currentLocation.localized(),
                                                                        currentTemperature: results.current.temp,
                                                                        weatherCondition: results.current.weather,
                                                                        dailyWeatherModel: dailyEntries,
                                                                        hourlyWeatherModel: hourlyEntries,
                                                                        cityBackgroundImage: UIImage(named: cityName))
                    self.dailyWeatherTableView.reloadData()
                    self.hourlyWeatherCollectionView.reloadData()
                    self.currentWeatherCondtionsForSelectedCity()
                }
            }
        }
    }
    
    func currentWeatherCondtionsForSelectedCity() {
        guard let currentSelectedCity = currentCityRenderableInfo else {
            return
        }
        let weatherIcon = currentSelectedCity.weatherCondition[0].main.lowercased()
        
        currentInfoView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.3)
        locationLabel =  UILabel(frame: CGRect(x: 15, y: 60, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/4))
        weatherConditionLabel = UILabel(frame: CGRect(x: 15, y: 20 + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/20))
        currentTemperatureLabel = UILabel(frame: CGRect(x: 15, y: 60 + weatherConditionLabel.frame.size.height + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/10))
        
        self.currentConditions.contentMode = .scaleAspectFit
        self.cityImage.contentMode = .scaleToFill
        self.cityImage.image = currentSelectedCity.cityBackgroundImage
        
        if weatherIcon.contains("clear") {
            self.currentConditions.image = UIImage(named: "clear")
        } else if weatherIcon.contains("rain") {
            self.currentConditions.image = UIImage(named: "rain")
        } else if weatherIcon.contains("drizzle") {
            self.currentConditions.image = UIImage(named: "rain")
        } else if weatherIcon.contains("thunderstrom") {
            self.currentConditions.image = UIImage(named: "thunderstorm")
        } else if weatherIcon.contains("snow") {
            self.currentConditions.image = UIImage(named: "snow")
        } else if weatherIcon.contains("clouds") {
            self.currentConditions.image = UIImage(named: "cloud")
        }
        currentInfoView.addSubview(locationLabel)
        currentInfoView.addSubview(weatherConditionLabel)
        currentInfoView.addSubview(currentTemperatureLabel)
        
        currentTemperatureLabel.textAlignment = .center
        currentTemperatureLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        currentTemperatureLabel.text = "\(Int(currentSelectedCity.currentTemperature))°"
        
        weatherConditionLabel.textAlignment = .center
        weatherConditionLabel.font = UIFont(name: "Helvetica-Bold", size: 22)
        weatherConditionLabel.text = "\(currentSelectedCity.weatherCondition[0].main)"
        
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont(name: "Helvetica", size: 22)
        locationLabel.text = currentSelectedCity.cityName
        
        hourlyWeatherCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        hourlyWeatherCollectionView.layer.borderWidth = 1.0
        hourlyWeatherCollectionView.layer.cornerRadius = 3.0
    }
}

//MARK: Daily Weather Table View
extension WeatherMainViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCityRenderableInfo?.dailyWeatherModel.count ?? 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyWeatherTableViewCell.identifer, for: indexPath) as! DailyWeatherTableViewCell
        cell.selectionStyle = .none
        
        guard let currentCity = currentCityRenderableInfo else {
            return cell
        }
        cell.configureWithModel(with: currentCity.dailyWeatherModel[indexPath.row])
        return cell
    }
    
    func reloadUIViewToClearData() {
        currentTemperatureLabel.removeFromSuperview()
        weatherConditionLabel.removeFromSuperview()
        locationLabel.removeFromSuperview()
    }
    
}

//MARK: Hourly Weather Table View
extension WeatherMainViewController: UICollectionViewDelegate {
}

extension WeatherMainViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCityRenderableInfo?.hourlyWeatherModel.count ?? 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCollectionViewCell.identifer, for: indexPath) as! HourlyWeatherCollectionViewCell
        guard let currentCity = currentCityRenderableInfo else {
            return cell
        }
        cell.configureWithModel(with: [currentCity.hourlyWeatherModel[indexPath.item]])
        return cell
    }
}


//MARK: Current Location Manager
extension WeatherMainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: WeatherLocalizable.error.localized(), message: WeatherLocalizable.locationErrorExpand.localized(), preferredStyle: .alert)
        let ok = UIAlertAction(title: WeatherLocalizable.ok.localized(), style: .default, handler: { action in })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
        }
        
        geoCoder.reverseGeocodeLocation(currentLocation!, completionHandler: { [self] (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                if let city = placemark.locality { self.currentLocationName = city}
                self.locationManager.stopUpdatingLocation()
                self.requestWeatherForLocation(cityLongitude: (currentLocation?.coordinate.longitude) ?? -79.347, cityLatitude: (currentLocation?.coordinate.latitude) ?? 43.651, cityName: self.currentLocationName)
            }
        })
    }
}
