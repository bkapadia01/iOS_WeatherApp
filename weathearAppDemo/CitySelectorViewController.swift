//
//  CitySelectorViewController.swift
//  weathearAppDemo
//
//  Created by Bhavin Kapadia on 2022-08-28.
//

import Foundation
import UIKit
var citiesWeatherModel: [RenderableCityInfo] = []

// Protocol used for sending data back
protocol citySelected: AnyObject {
    func userSelectedCity(cityIndex: Int)
}


class CitySelectorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cityPicker: UIPickerView!
    
    var pickerData: [String] = [String]()
    weak var delegate: citySelected? = nil

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.cityPicker.delegate = self
        self.cityPicker.dataSource = self

//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(returnToMainViewController))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtons))
        
        pickerData = ["Current Location", "Chicago", "Tokyo", "London", "Sydney", "Berlin"]
    }
    
    @objc func returnToMainViewController() {
        self.dismiss(animated: true, completion: nil)

    }
    @objc func doneButtons() {
        
        let indexOfCurrentlySelectedCity = cityPicker.selectedRow(inComponent: 0)
//        let currentCity = citiesWeatherModel[indexOfCurrentlySelectedCity]
        
        delegate?.userSelectedCity(cityIndex: indexOfCurrentlySelectedCity)
        
//        _ = navigationController?.popToRootViewController(animated: true)
        navigationController?.popViewController(animated: true)
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

