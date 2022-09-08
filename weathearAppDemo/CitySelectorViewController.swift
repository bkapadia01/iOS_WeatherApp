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
    func userSelectedCity(cityLongitude: Double, cityLatitude: Double, cityName: String)
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
        setupCityPickerModel()
    }
    
    private func setupCityPickerModel() {
        
        let currentLocationForecast = RenderableCityPickerrInfo(cityLongitude: 0,
                                                                cityLatitude: 0,
                                                                cityName: WeatherLocalizable.currentLocation.localized())
        let chicagoForecast = RenderableCityPickerrInfo(cityLongitude: -87.623,
                                                        cityLatitude: 41.881,
                                                        cityName: WeatherLocalizable.cityChicago.localized())
        let londonForecast = RenderableCityPickerrInfo(cityLongitude: -0.118,
                                                       cityLatitude: 51.509,
                                                       cityName:WeatherLocalizable.cityLondon.localized())
        let tokyoForecast = RenderableCityPickerrInfo(cityLongitude: 139.839,
                                                      cityLatitude: 35.65,
                                                      cityName: WeatherLocalizable.cityTokyo.localized())
        let sydneyForecast = RenderableCityPickerrInfo(cityLongitude: 151.20,
                                                       cityLatitude: -33.86,
                                                       cityName: WeatherLocalizable.citySydney.localized())
        let berlinForecast = RenderableCityPickerrInfo(cityLongitude: 13.404,
                                                       cityLatitude: 52.520,
                                                       cityName: WeatherLocalizable.cityBerlin.localized())
        
        citiesPickerModel = [currentLocationForecast,chicagoForecast,londonForecast,tokyoForecast,sydneyForecast,berlinForecast]
        
    }
    
    @objc func returnToMainViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtons() {
        
        let indexOfCurrentlySelectedCity = cityPicker.selectedRow(inComponent: 0)
        
        self.delegate?.userSelectedCity(cityLongitude: citiesPickerModel[indexOfCurrentlySelectedCity].cityLongitude,
                                        cityLatitude: citiesPickerModel[indexOfCurrentlySelectedCity].cityLatitude,
                                        cityName: citiesPickerModel[indexOfCurrentlySelectedCity].cityName)
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return citiesPickerModel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return citiesPickerModel[row].cityName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(citiesPickerModel[row].cityName)
    }
}
