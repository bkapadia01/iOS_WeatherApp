//
//  WeatherMainViewController.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-05-22.
//

import UIKit
import CoreLocation
// group this (MARK) with like items and take common MARKED items into their own class -> gives blueprint of modularizing things
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

class WeatherMainViewController: UIViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.retrieveLocationOnAppStartup()
        }
        
        // Moved search/nav bar here since there was a UI issue if you tapped on search/done repeatedly very quickly
        // move this back to orignial positon and see if it can be handled where it should be - understand this issue better!!!
        // 2 tricks from apple  can help with UI debugging - debug view hiearchy and slow animation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(cityPickerController))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dailyWeatherTableView.register(DailyWeatherTableViewCell.nib(), forCellReuseIdentifier: DailyWeatherTableViewCell.identifer)
        dailyWeatherTableView.delegate = self
        dailyWeatherTableView.dataSource = self
        
        hourlyWeatherCollectionView.register(HourlyWeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifer)
        hourlyWeatherCollectionView.delegate = self
        hourlyWeatherCollectionView.dataSource = self
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
        
        // instead of emty hourly and daily weaather model arrays - we can do a city picker objec tthat only has names - long/lat for the city - everything with empty array would be another object...each vc represents a screen and respective model with each view, so home would have different model than the picker model
            // so main page only renders only the model for the city selected
        // limit the size of class to just do 1 thing only
            // MVVM allows to use a template to break up the logic into logical parts
            // break 1 class into 2 -> grouping functions in the logic portion -> retriving data can be a service that can be another class - so now the view model is split into 2 now
        //
        citiesWeatherModel = [currentLocationForecast,chicagoForecast,londonForecast,tokyoForecast,sydneyForecast,berlinForecast]
    }
    
    //MARK: City picker view with selection of cities and navigation bar
    @objc func cityPickerController() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        cityPickerView.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        cityPickerView.autoresizingMask = .flexibleHeight
        cityPickerView.backgroundColor = .init(white: 0.9, alpha: 0.9)
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.isHidden = false
        let indexOfCurrentlySelectedCity = citiesWeatherModel.firstIndex { element in
            if (element.cityName == currentCityRenderableInfo?.cityName) {
                return true
            } else {
                return false
            }
        }
        cityPickerView.selectRow(indexOfCurrentlySelectedCity ?? 0, inComponent: 0, animated: false)
        self.view.addSubview(cityPickerView)
        cityPickerView.center = self.view.center
        
        // NavBar options
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        let navBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: WeatherLocalizable.cancel.localized(), style: .plain, target: self, action: #selector(self.canceButtonTapped))
        
        navBarAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: cityPickerView.frame.width, height: 70))
        navBarAccessory.barStyle = .default
        navBarAccessory.isTranslucent = false
        navBarAccessory.isUserInteractionEnabled = true
        navBarAccessory.items = [cancelButton, navBarSpace, doneButton]
        self.view.addSubview (navBarAccessory)
    }
    
    @objc func doneButtonTapped() {
        let indexOfCurrentlySelectedCity = cityPickerView.selectedRow(inComponent: 0)
        let currentCity = citiesWeatherModel[indexOfCurrentlySelectedCity]
        currentCityRenderableInfo = currentCity
        
        DispatchQueue.main.async {
            self.requestWeatherForLocation(cityLongitude: currentCity.cityLongitude, cityLatitude: currentCity.cityLatitude)
        }
        
        self.currentLocationName = currentCity.cityName
        if indexOfCurrentlySelectedCity == 0 {
            self.locationManager.requestLocation()
            self.locationManager.stopUpdatingLocation()
        }
        cityPickerView.isHidden = true
        navBarAccessory.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func canceButtonTapped() {
        cityPickerView.isHidden = true
        navBarAccessory.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
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

        reloadUIViewToClearData()
        currentInfoView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.3)
        locationLabel =  UILabel(frame: CGRect(x: 15, y: 60, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/5))
        weatherConditionLabel = UILabel(frame: CGRect(x: 15, y: 60 + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/15))
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
        
        addGreyBackgroundToLabel(label: weatherConditionLabel)
        addGreyBackgroundToLabel(label: currentTemperatureLabel)
        addGreyBackgroundToLabel(label: locationLabel)
        
        hourlyWeatherCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        hourlyWeatherCollectionView.layer.borderWidth = 1.0
        hourlyWeatherCollectionView.layer.cornerRadius = 3.0
    }
    
    func reloadUIViewToClearData() {
        let parent = self.view.superview
        self.view.removeFromSuperview()
        self.view = nil
        parent?.addSubview(self.view)
    }
    
    func addGreyBackgroundToLabel(label: UILabel) {
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = label.bounds
        maskLayer.shadowPath = CGPath(roundedRect: label.bounds.insetBy(dx: 40, dy: -10), cornerWidth: 15, cornerHeight: 5, transform: nil)
        maskLayer.shadowOpacity =  1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        label.layer.mask = maskLayer
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
        view.translatesAutoresizingMaskIntoConstraints = false
 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCollectionViewCell.identifer, for: indexPath) as! HourlyWeatherCollectionViewCell
        guard let currentCity = currentCityRenderableInfo else {
            return cell
        }
        cell.configureWithModel(with: [currentCity.hourlyWeatherModel[indexPath.item]])
        return cell
    }
}

//MARK: City picker view
extension WeatherMainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return citiesWeatherModel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let city = citiesWeatherModel[row]
        return city.cityName
    }
    
    // do not selecte city/row since I handle this only if "Done" is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
                
                self.requestWeatherForLocation(cityLongitude: (currentLocation?.coordinate.longitude) ?? -79.347, cityLatitude: (currentLocation?.coordinate.latitude) ?? 43.651)
                self.cityData()
            }
        })
    }
}

extension String {
    func localized() -> String{
        var fileName = String()
        fileName = "WeatherLocalizable"
        return NSLocalizedString(self, tableName: fileName, bundle: Bundle.main, value: String(), comment: String())
    }
}
