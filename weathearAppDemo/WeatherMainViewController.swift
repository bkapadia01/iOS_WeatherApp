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
    
    let defautBackgroundImage = "defaultBackground"
    var currentLocation: CLLocation?
    var citiesWeatherModel: [RenderableCityInfo] = []
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
    
    // Protocol
    func userSelectedCity(cityIndex: Int) {
        print(cityIndex)
        let currentCity = citiesWeatherModel[cityIndex]
        reloadUIViewToClearData()
        currentCityRenderableInfo = currentCity
        self.requestWeatherForLocation(cityLongitude: currentCity.cityLongitude, cityLatitude: currentCity.cityLatitude)
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
    
    //MARK: List of city data
    private func cityData() {
        guard let currentLocation = currentLocation else {
            return
        }
        let cityLongitude: Double = currentLocation.coordinate.longitude
        let cityLatitude: Double = currentLocation.coordinate.latitude
        
        if !(currentLocationName == "Toronto") {
            currentLocationName = defautBackgroundImage
        }
        
        let currentLocationForecast = RenderableCityInfo(cityLongitude: cityLongitude, cityLatitude: cityLatitude, cityName: WeatherLocalizable.currentLocation.localized(), currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: currentLocationName))
        let chicagoForecast = RenderableCityInfo(cityLongitude: -87.623, cityLatitude: 41.881, cityName: WeatherLocalizable.cityChicago.localized(),  currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityChicago.localized()))
        let londonForecast = RenderableCityInfo(cityLongitude: -0.118, cityLatitude: 51.509, cityName:WeatherLocalizable.cityLondon.localized(),  currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityLondon.localized()))
        let tokyoForecast = RenderableCityInfo(cityLongitude: 139.839, cityLatitude: 35.65, cityName: WeatherLocalizable.cityTokyo.localized(),  currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityTokyo.localized()))
        let sydneyForecast = RenderableCityInfo(cityLongitude: 151.20, cityLatitude: -33.86, cityName: WeatherLocalizable.citySydney.localized(),  currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.citySydney.localized()))
        let berlinForecast = RenderableCityInfo(cityLongitude: 13.404, cityLatitude: 52.520, cityName: WeatherLocalizable.cityBerlin.localized(),  currentTemperature: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityBerlin.localized()))
        citiesWeatherModel = [currentLocationForecast,chicagoForecast,londonForecast,tokyoForecast,sydneyForecast,berlinForecast]
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
    
    func requestWeatherForLocation(cityLongitude: Double, cityLatitude: Double) {
        
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
                    let indexOfCurrentlySelectedCity = self.citiesWeatherModel.firstIndex { element in
                        if (element.cityName == self.currentCityRenderableInfo?.cityName) {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    var selectedCity = self.citiesWeatherModel[indexOfCurrentlySelectedCity ?? 0]
                    selectedCity.currentTemperature = results.current.temp
                    selectedCity.weatherCondition = results.current.weather
                    selectedCity.hourlyWeatherModel.append(contentsOf: hourlyEntries)
                    selectedCity.dailyWeatherModel.append(contentsOf: dailyEntries)
                    
                    self.citiesWeatherModel[indexOfCurrentlySelectedCity ?? 0] = selectedCity
                    self.currentCityRenderableInfo = selectedCity
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
        guard self.citiesWeatherModel.count > 0 else {
            return 0
        }
        let indexOfCurrentlySelectedCity = citiesWeatherModel.firstIndex { element in
            if (element.cityName == currentCityRenderableInfo?.cityName) {
                return true
            } else {
                return false
            }
        }
        let city = self.citiesWeatherModel[indexOfCurrentlySelectedCity ?? 0]
        return city.dailyWeatherModel.count
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
        guard self.citiesWeatherModel.count > 0 else {
            return 0
        }
        guard let currentCity = currentCityRenderableInfo else {
            return 0
        }
        return currentCity.hourlyWeatherModel.count
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
                self.requestWeatherForLocation(cityLongitude: (currentLocation?.coordinate.longitude) ?? -79.347, cityLatitude: (currentLocation?.coordinate.latitude) ?? 43.651)
                self.cityData()
            }
        })
    }
}
