//
//  RegisterViewController.swift
//  Match and Chat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

var username = ""


class RegisterViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var locationManager:CLLocationManager!
    var userLat = 0.0
    var userLong = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude )
        userLat = location.latitude
        userLong = location.longitude
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty else {
            self.showMessage(messageToDisplay: "User email is required")
            return;
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            self.showMessage(messageToDisplay: "User password is required")
            return;
        }
        
        guard let _username = userNameTextField.text, !_username.isEmpty else {
            self.showMessage(messageToDisplay: "Username is required")
            return;
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error
            {
                print(error.localizedDescription)
                self.showMessage(messageToDisplay: error.localizedDescription)
                return
            }
            
            if let user = user {
                
                var databaseReference: DatabaseReference!
                databaseReference = Database.database().reference()
                
                let userDetails:[String:Any] = ["lat":self.userLat, "long":self.userLong, "name": _username]
                databaseReference.child("Users").child(user.uid).setValue(userDetails)
                username = _username
                UserDefaults.standard.set(username, forKey: "username")
                self.performSegue(withIdentifier: "mainFromRegisterSegue", sender: self)
            }
        }
    }
    
    func showMessage(messageToDisplay:String)
    {
        let alertController = UIAlertController(title: "Alert title", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
}

