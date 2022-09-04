//
//  CitySelectorViewController.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-08-28.
//

import Foundation
import UIKit
import CoreLocation

struct RenderableCityPickerrInfo {
    var cityLongitude: Double
    var cityLatitude: Double
    var cityName:String
}

// Protocol used for sending data back
protocol CitySelectedProtocol: AnyObject {
    func userSelectedCity(cityIndex: Int)
}


class CitySelectorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cityPicker: UIPickerView!
    var citiesPickerModel: [RenderableCityPickerrInfo] = []
    var pickerData: [String] = [String]()
    var currentLocation: CLLocation?
    let geoCoder = CLGeocoder()
    var currentLocationName: String = ""
    let locationManager  = CLLocationManager()

    weak var delegate: CitySelectedProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.cityPicker.delegate = self
        self.cityPicker.dataSource = self

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtons))
        pickerData = ["Current Location", "Chicago", "London", "Tokyo", "Sydney", "Berlin"]

       cityPickerData()
    }
    
    private func cityPickerData() {
        guard let currentLocation = currentLocation else {
            return
        }
        let cityLongitude: Double = currentLocation.coordinate.longitude
        let cityLatitude: Double = currentLocation.coordinate.latitude
               
        let currentLocationModel = RenderableCityPickerrInfo(cityLongitude: cityLongitude, cityLatitude: cityLatitude, cityName: WeatherLocalizable.currentLocation.localized())
        let chicagoLocationModel = RenderableCityPickerrInfo(cityLongitude:  -87.623, cityLatitude: 41.881, cityName: WeatherLocalizable.cityChicago.localized())
        let londonLocationodel = RenderableCityPickerrInfo(cityLongitude: -0.118, cityLatitude: 51.509, cityName:WeatherLocalizable.cityLondon.localized())
        
        citiesPickerModel = [currentLocationModel, chicagoLocationModel, londonLocationodel]
        pickerData = [currentLocationModel.cityName]
    }
    
    @objc func returnToMainViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtons() {
        
        let indexOfCurrentlySelectedCity = cityPicker.selectedRow(inComponent: 0)

        self.delegate?.userSelectedCity(cityIndex: indexOfCurrentlySelectedCity)
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
//    @objc func doneButtonTapped() {
        
        
//        let indexOfCurrentlySelectedCity = cityPicker.selectedRow(inComponent: 0)
//        let currentCity = citiesWeatherModel[indexOfCurrentlySelectedCity]
//
        
//        currentCityRenderableInfo = currentCity
//
//        DispatchQueue.main.async {
//            self.requestWeatherForLocation(cityLongitude: currentCity.cityLongitude, cityLatitude: currentCity.cityLatitude)
//        }
//
//        self.currentLocationName = currentCity.cityName
//        if indexOfCurrentlySelectedCity == 0 {
//            self.locationManager.requestLocation()
//            self.locationManager.stopUpdatingLocation()
//        }
        
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerData[row])
    }
}


extension CitySelectorViewController: CLLocationManagerDelegate {
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
//                self.requestWeatherForLocation(cityLongitude: (currentLocation?.coordinate.longitude) ?? -79.347, cityLatitude: (currentLocation?.coordinate.latitude) ?? 43.651)
//                self.cityData()
            }
        })
    }
}
