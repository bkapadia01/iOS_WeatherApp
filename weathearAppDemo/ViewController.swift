//
//  ViewController.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-05-22.
//

import UIKit
import CoreLocation


struct RenderableCityInfo {
    var long: Int
    var lat: Int
    var cityName:String
    var currentTemp: Double
    var weatherCondition: [Weather]
    var dailyWeatherModel:[Daily]
    var hourlyWeatherModel:[Current]
    var cityBackgroundImage: UIImage?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var currentInfoView: UIView!
    @IBOutlet var dailyWeatherTableView: UITableView!
    @IBOutlet weak var hourlyWeatherCollectionView: UICollectionView!
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var currentConditions: UIImageView!
    
    let locationManager  = CLLocationManager()
    let geoCoder = CLGeocoder()
    let picker: UIPickerView = UIPickerView()

    var currentLocation: CLLocation?
    var cities: [RenderableCityInfo] = []
    var selectedCity = 0
    var cityNameString: String = ""
    var navBarAccessory:UIToolbar = UIToolbar()
    var locationLabel:UILabel = UILabel()
    var weatherConditionLabel:UILabel = UILabel()
    var tempLabel:UILabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        DispatchQueue.main.async {
            self.retrieveLocationOnAppStartup()
        }
        
        // Moved search/nav bar here since there was UI issue if you tapped on search/done repeatedly very quickly
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(cityPickerController))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        dailyWeatherTableView.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifer)
        dailyWeatherTableView.delegate = self
        dailyWeatherTableView.dataSource = self
        
        hourlyWeatherCollectionView.register(HourlyWeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifer)
        hourlyWeatherCollectionView.delegate = self
        hourlyWeatherCollectionView.dataSource = self
        hourlyWeatherCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        hourlyWeatherCollectionView.layer.borderWidth = 1.0
        hourlyWeatherCollectionView.layer.cornerRadius = 3.0
    }
    
    
    //MARK: List of city data
    private func cityData() {
        guard let currentLocation = currentLocation else {
            return
        }
        let long: Int = Int(currentLocation.coordinate.longitude)
        let lat: Int = Int(currentLocation.coordinate.latitude)
        
        
        let currentLocationForecast = RenderableCityInfo(long: long, lat: lat, cityName: "Current Location", currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: cityNameString))
        let chicagoForecast = RenderableCityInfo(long: Int(-87.623), lat: Int(41.881), cityName: "Chicago",  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: "Chicago"))
        let londonForecast = RenderableCityInfo(long: Int(-0.118), lat: Int(51.509), cityName: "London",  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: "London"))
        let tokyoForecast = RenderableCityInfo(long: Int(139.839), lat: Int(35.65), cityName: "Tokyo",  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: "Tokyo"))
        let sydneyForecast = RenderableCityInfo(long: Int(151.20), lat: Int(-33.86), cityName: "Sydney",  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: "Sydney"))
        let berlinForecast = RenderableCityInfo(long: Int(13.404), lat: Int(52.520), cityName: "Berlin",  currentTemp: 0, weatherCondition: [], dailyWeatherModel: [], hourlyWeatherModel: [], cityBackgroundImage: UIImage(named: "Berlin"))
        
        cities = [currentLocationForecast,chicagoForecast,londonForecast,tokyoForecast,sydneyForecast,berlinForecast]
    }
    
    //MARK: City picker view with selection of cities and navigation bar
    @objc func cityPickerController() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        picker.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        picker.autoresizingMask = .flexibleHeight
        picker.backgroundColor = .init(white: 0.9, alpha: 0.9)
        picker.delegate = self
        picker.dataSource = self
        picker.isHidden = false
        picker.selectRow(selectedCity, inComponent: 0, animated: false)

        self.view.addSubview(picker)
        picker.center = self.view.center
        
        // Toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.canceButtonTapped))
        
        navBarAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: picker.frame.width, height: 70))
        navBarAccessory.barStyle = .default
        navBarAccessory.isTranslucent = false
        navBarAccessory.isUserInteractionEnabled = true
        navBarAccessory.items = [cancelButton, spaceButton, doneButton]
        self.view.addSubview (navBarAccessory)
    }
    
    @objc func doneButtonTapped() {
        let index = picker.selectedRow(inComponent: 0)
        let currentCity = cities[index]
        selectedCity = index
        
        DispatchQueue.main.async {
            self.requestWeatherForLocation(long: currentCity.long, lat: currentCity.lat)
        }
        self.cityNameString = currentCity.cityName
        if index == 0 {
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
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely,alerts&units=metric&appid=f1266e7ef11b56cc3e6f353b3bb2c635"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            
            // Validation
            guard let data = data, error == nil else {
                print("Unable to get data from API")
                return
            }
            
            // convert data to models object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("Error: \(error)")
            }
            
            guard let results = json else {
                return
            }
            
            let dailyEntries = results.daily
            let hourlyEntries =  Array(results.hourly[1...12])
            
            DispatchQueue.main.async {
                let index = self.picker.selectedRow(inComponent: 0)
                var selectedCity = self.cities[index]
                selectedCity.dailyWeatherModel = dailyEntries
                selectedCity.hourlyWeatherModel = hourlyEntries
                selectedCity.currentTemp = results.current.temp
                selectedCity.weatherCondition = results.current.weather
                selectedCity.hourlyWeatherModel.append(contentsOf: hourlyEntries)
                selectedCity.dailyWeatherModel.append(contentsOf: dailyEntries)
                
                self.cities[index] = selectedCity
                self.dailyWeatherTableView.reloadData()
                self.hourlyWeatherCollectionView.reloadData()
                self.currentWeatherCondtionsForSelectedCity()
            }
        }).resume()
    }
    
    func currentWeatherCondtionsForSelectedCity() {
        let city = self.cities[self.picker.selectedRow(inComponent: 0)]
        let weatherIcon = city.weatherCondition[0].main.lowercased()

        reloadUIViewToClearData()
        currentInfoView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.3)
        locationLabel =  UILabel(frame: CGRect(x: 15, y: 60, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/5))
        weatherConditionLabel = UILabel(frame: CGRect(x: 15, y: 60 + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/15))
        tempLabel = UILabel(frame: CGRect(x: 15, y: 60 + weatherConditionLabel.frame.size.height + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: currentInfoView.frame.size.height/10))
        
        self.currentConditions.contentMode = .scaleAspectFit
        self.cityImage.contentMode = .scaleToFill
        self.cityImage.image = city.cityBackgroundImage
        
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
        tempLabel.text = "\(Int(city.currentTemp))°"
        
        weatherConditionLabel.textAlignment = .center
        weatherConditionLabel.font = UIFont(name: "Helvetica-Bold", size: 22)
        weatherConditionLabel.text = "\(city.weatherCondition[0].main)"
        
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont(name: "Helvetica", size: 22)
        locationLabel.text = city.cityName
        
        addBlurryEdgeToLabel(label: weatherConditionLabel)
        addBlurryEdgeToLabel(label: tempLabel)
        addBlurryEdgeToLabel(label: locationLabel)
    }
    
    func reloadUIViewToClearData() {
        let parent = self.view.superview
        self.view.removeFromSuperview()
        self.view = nil
        parent?.addSubview(self.view)
    }
    
    func addBlurryEdgeToLabel(label: UILabel) {
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = label.bounds
        maskLayer.shadowRadius = 1
        maskLayer.shadowPath = CGPath(roundedRect: label.bounds.insetBy(dx: 40, dy: -10), cornerWidth: 15, cornerHeight: 5, transform: nil)
        maskLayer.shadowOpacity =  1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        label.layer.mask = maskLayer
    }
}

//MARK: Daily Weather Table View
extension ViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.cities.count > 0 else {
            return 0
        }
        let city = self.cities[self.picker.selectedRow(inComponent: 0)]
        return city.dailyWeatherModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = self.cities[self.picker.selectedRow(inComponent: 0)]
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifer, for: indexPath) as! WeatherTableViewCell
        cell.configureWithModel(with: city.dailyWeatherModel[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: Hourly Weather Table View
extension ViewController: UICollectionViewDelegate {
}

extension ViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.cities.count > 0 else {
            return 0
        }
        let city = self.cities[self.picker.selectedRow(inComponent: 0)]
        return city.hourlyWeatherModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        view.translatesAutoresizingMaskIntoConstraints = false

        let city = self.cities[self.picker.selectedRow(inComponent: 0)]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCollectionViewCell.identifer, for: indexPath) as! HourlyWeatherCollectionViewCell
        cell.configureWithModel(with: [city.hourlyWeatherModel[indexPath.item]])
        return cell
    }
}

//MARK: City picker view
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Location Error", message: "Unable to determine location", preferredStyle: .alert)
            
             let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
             })
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
                if let city = placemark.locality { self.cityNameString = city}
                self.requestWeatherForLocation(long: Int((currentLocation?.coordinate.longitude)!), lat: Int((currentLocation?.coordinate.latitude)!))
                self.cityData()
            }
        })
    }
}
