//
//  AddDataVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/6.
//

import UIKit
import CoreLocation

class AddDataVC: UIViewController {

    static var newUser = User(id: "N7vGHwNdqCGTb0B1gkhA", name: "", email: "", latitude: 0, longitude: 0, age: 0, story: "", video: "", createdTime: 0, index: 0)
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if let name = nameField.text,
           let age = ageField.text,
           let email = emailField.text {
            AddDataVC.newUser.name = name
            AddDataVC.newUser.age = Int(age) ?? 0
            AddDataVC.newUser.email = email
        }
        
        add(with: &AddDataVC.newUser)
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "\(UploadStoryVC.self)") as? UploadStoryVC {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
    
    private func add(with user: inout User) {
        FireBaseManager.shared.addUser(user: &user) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
    
    private func updateLocation(lat latitude: CLLocationDegrees, lon longitude: CLLocationDegrees) {
        AddDataVC.newUser.longitude = longitude
        AddDataVC.newUser.latitude = latitude
        FireBaseManager.shared.updateLocation(user: AddDataVC.newUser) { result in
            switch result {
            case .success(let success):
                print("Success: update location \(success)")
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
}

extension AddDataVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingHeading()
        }
        AddDataVC.newUser.latitude = location.coordinate.latitude
        AddDataVC.newUser.longitude = location.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
