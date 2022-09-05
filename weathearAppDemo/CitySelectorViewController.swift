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

    }
    
    @objc func returnToMainViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtons() {
        
        let indexOfCurrentlySelectedCity = cityPicker.selectedRow(inComponent: 0)

        self.delegate?.userSelectedCity(cityIndex: indexOfCurrentlySelectedCity)
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
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
