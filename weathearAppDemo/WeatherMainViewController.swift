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
    var long: Int // dont use short form espeically if it's a data type -> what type long is this, it can mean anything
    var lat: Int
    var cityName:String
    var currentTemp: Double
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
    let picker: UIPickerView = UIPickerView() // same with this -> which picker, think of how others are reading, be more obvious with the naming!!!

    let defautBackgroundImage = "defaultBackground"
    var currentLocation: CLLocation?
    var cities: [RenderableCityInfo] = []
    var currentCityRenderableInfo:RenderableCityInfo?
    var currentLocationName: String = ""
    var navBarAccessory:UIToolbar = UIToolbar()
    var locationLabel:UILabel = UILabel()
    var weatherConditionLabel:UILabel = UILabel()
    var tempLabel:UILabel = UILabel()
    
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
        let long: Int = Int(currentLocation.coordinate.longitude)
        let lat: Int = Int(currentLocation.coordinate.latitude)
        
        if !(currentLocationName == "Toronto") {
            currentLocationName = defautBackgroundImage
        }
        
        
        
        let currentLocationForecast = RenderableCityInfo(long: long, lat: lat, cityName: WeatherLocalizable.currentLocation.localized(), currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: currentLocationName))
        let chicagoForecast = RenderableCityInfo(long: Int(-87.623), lat: Int(41.881), cityName: WeatherLocalizable.cityChicago.localized(),  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityChicago.localized()))
        let londonForecast = RenderableCityInfo(long: Int(-0.118), lat: Int(51.509), cityName:WeatherLocalizable.cityLondon.localized(),  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityLondon.localized()))
        let tokyoForecast = RenderableCityInfo(long: Int(139.839), lat: Int(35.65), cityName: WeatherLocalizable.cityTokyo.localized(),  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityTokyo.localized()))
        let sydneyForecast = RenderableCityInfo(long: Int(151.20), lat: Int(-33.86), cityName: WeatherLocalizable.citySydney.localized(),  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.citySydney.localized()))
        let berlinForecast = RenderableCityInfo(long: Int(13.404), lat: Int(52.520), cityName: WeatherLocalizable.cityBerlin.localized(),  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: WeatherLocalizable.cityBerlin.localized()))
        
        // instead of emty hourly and daily weaather model arrays - we can do a city picker objec tthat only has names - long/lat for the city - everything with empty array would be another object...each vc represents a screen and respective model with each view, so home would have different model than the picker model
            // so main page only renders only the model for the city selected
        // limit the size of class to just do 1 thing only
            // MVVM allows to use a template to break up the logic into logical parts
            // break 1 class into 2 -> grouping functions in the logic portion -> retriving data can be a service that can be another class - so now the view model is split into 2 now
        //
        cities = [currentLocationForecast,chicagoForecast,londonForecast,tokyoForecast,sydneyForecast,berlinForecast]
    }
    
    //MARK: City picker view with selection of cities and navigation bar
    @objc func cityPickerController() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        picker.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        picker.autoresizingMask = .flexibleHeight
        picker.backgroundColor = .init(white: 0.9, alpha: 0.9)
        picker.delegate = self
        picker.dataSource = self
        picker.isHidden = false
        let indexOfCurrentlySelectedCity = cities.firstIndex { element in
            if (element.cityName == currentCityRenderableInfo?.cityName) {
                return true
            } else {
                return false
            }
        }
        picker.selectRow(indexOfCurrentlySelectedCity ?? 0, inComponent: 0, animated: false)
        self.view.addSubview(picker)
        picker.center = self.view.center
        
        // NavBar options
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        let navBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: WeatherLocalizable.cancel.localized(), style: .plain, target: self, action: #selector(self.canceButtonTapped))
        
        navBarAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: picker.frame.width, height: 70))
        navBarAccessory.barStyle = .default
        navBarAccessory.isTranslucent = false
        navBarAccessory.isUserInteractionEnabled = true
        navBarAccessory.items = [cancelButton, navBarSpace, doneButton]
        self.view.addSubview (navBarAccessory)
    }
    
    @objc func doneButtonTapped() {
        let indexOfCurrentlySelectedCity = picker.selectedRow(inComponent: 0)
        let currentCity = cities[indexOfCurrentlySelectedCity]
        currentCityRenderableInfo = currentCity
        
        DispatchQueue.main.async {
            self.requestWeatherForLocation(long: currentCity.long, lat: currentCity.lat)
        }
        
        self.currentLocationName = currentCity.cityName
        if indexOfCurrentlySelectedCity == 0 {
            self.locationManager.requestLocation()
            self.locationManager.stopUpdatingLocation()
        }
        picker.isHidden = true
        navBarAccessory.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func canceButtonTapped() {
        picker.isHidden = true
        navBarAccessory.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func retrieveLocationOnAppStartup() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func requestWeatherForLocation(long: Int, lat: Int) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely,alerts&units=metric&appid=f1266e7ef11b56cc3e6f353b3bb2c635")!
        // api calling helper/service should make call and this is only job it should do and not do any parsing/UI related tasks - tell me endpoint and get the raw data for me
            // all the UI should only be handled by the VC and the parsing of the data should shoould be handled by view model as well the calling of api
        // business logic = view model
        
         let task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            
            // Validation
            guard let data = data, error == nil else {
                print(WeatherLocalizable.apiError.localized())
                return
            }
            
            // convert data to models object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                let alert = UIAlertController(title: WeatherLocalizable.error.localized(), message: "\(error)", preferredStyle: .alert)
                let ok = UIAlertAction(title: WeatherLocalizable.ok.localized(), style: .default, handler: { action in })
                alert.addAction(ok)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
                })
            }
            
            guard let results = json else {
                return
            }
            
            let dailyEntries = results.daily
            let hourlyEntries =  Array(results.hourly[1...12])
            
            DispatchQueue.main.async {
                let indexOfCurrentlySelectedCity = self.cities.firstIndex { element in
                    if (element.cityName == self.currentCityRenderableInfo?.cityName) {
                        return true
                    } else {
                        return false
                    }
                }
                
                var selectedCity = self.cities[indexOfCurrentlySelectedCity ?? 0]
                selectedCity.currentTemp = results.current.temp
                selectedCity.weatherCondition = results.current.weather
                selectedCity.hourlyWeatherModel.append(contentsOf: hourlyEntries)
                selectedCity.dailyWeatherModel.append(contentsOf: dailyEntries)
                
                self.cities[indexOfCurrentlySelectedCity ?? 0] = selectedCity
                self.currentCityRenderableInfo = selectedCity
                self.dailyWeatherTableView.reloadData()
                self.hourlyWeatherCollectionView.reloadData()
                self.currentWeatherCondtionsForSelectedCity()
            }
        })
        task.resume()
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
        tempLabel = UILabel(frame: CGRect(x: 15, y: 60 + weatherConditionLabel.frame.size.height + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/10))
        
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
        currentInfoView.addSubview(tempLabel)
        
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        tempLabel.text = "\(Int(currentSelectedCity.currentTemp))°"
        
        weatherConditionLabel.textAlignment = .center
        weatherConditionLabel.font = UIFont(name: "Helvetica-Bold", size: 22)
        weatherConditionLabel.text = "\(currentSelectedCity.weatherCondition[0].main)"
        
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont(name: "Helvetica", size: 22)
        locationLabel.text = currentSelectedCity.cityName
        
        addGreyBackgroundToLabel(label: weatherConditionLabel)
        addGreyBackgroundToLabel(label: tempLabel)
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
        guard self.cities.count > 0 else {
            return 0
        }
        let indexOfCurrentlySelectedCity = cities.firstIndex { element in
            if (element.cityName == currentCityRenderableInfo?.cityName) {
                return true
            } else {
                return false
            }
        }
        let city = self.cities[indexOfCurrentlySelectedCity ?? 0]
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
        guard self.cities.count > 0 else {
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
        return cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let city = cities[row]
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
                self.requestWeatherForLocation(long: Int((currentLocation?.coordinate.longitude) ?? -79.347), lat: Int((currentLocation?.coordinate.latitude) ?? 43.651))
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
