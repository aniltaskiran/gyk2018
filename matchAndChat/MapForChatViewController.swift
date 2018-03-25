//
//  MapForChatViewController.swift
//  matchAndChat
//
//  Created by Veyis Egemen ERDEN on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class MapForChatViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    var requestCLLocation = CLLocation()
    var nearByUsers = [UserLocationModel]()
    var userLat = 0.0
    var userLong = 0.0
    
    @IBOutlet weak var illustrateButton: UIButton!
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.isRotateEnabled = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
  
    }

  

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude )
            userLat = location.latitude
            userLong = location.longitude
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        
        pullUserNearBy(){(exist) -> () in
            if exist == true && self.nearByUsers.count != 0{
              
                for i in 0...self.nearByUsers.count-1{
                    
                    
                    let annotion = MKPointAnnotation()
                    
                    annotion.coordinate.latitude = self.nearByUsers[i].lat
                    annotion.coordinate.longitude = self.nearByUsers[i].long
                    annotion.title = self.nearByUsers[i].name
                    
                    
                    self.mapView.addAnnotation(annotion)
                    
                }
                
            }else{
                
            }
            
            
        }
        
        
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseID = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
             pinView?.pinTintColor = UIColor.orange
                
  
            let button = UIButton(type: UIButtonType.contactAdd)
            pinView?.rightCalloutAccessoryView = button
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            
            
        }else {
            pinView?.annotation = annotation
        }
        
        
        return pinView
        
        
        
    }
    func pullUserNearBy(completionHandler: @escaping ((_ exist : Bool) -> Void)){
      
        
        Database.database().reference(withPath:
            "Users").observe(.value, with: { (snapShot) in
                if snapShot.exists() {
                     self.nearByUsers.removeAll(keepingCapacity: false)
                    let array:NSArray = snapShot.children.allObjects as NSArray
                    
                    for child in array {
                        let snap = child as! DataSnapshot
                        if snap.value is NSDictionary {
                            let data:NSDictionary = snap.value as! NSDictionary
                            
                            self.takeCloser(detectedPerson: UserLocationModel( lat: data.value(forKey: "lat")! as! Double, long: data.value(forKey: "long")! as! Double, name: data.value(forKey: "name")! as! String))
                           
          
                        }
                        
                        
                        
                    }
                
                    completionHandler(true)
                }
            })
        
        
        
}
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    func takeCloser(detectedPerson:UserLocationModel){
        let coordinate = CLLocation(latitude: self.userLat, longitude: self.userLong)
       
     
       
            let requestCoordinate = CLLocation(latitude: detectedPerson.lat, longitude: detectedPerson.long)
            
            let distanceInMeters = coordinate.distance(from: requestCoordinate)
            if distanceInMeters < 500  {
                print( detectedPerson.toString())
               self.nearByUsers.append(detectedPerson)
                
            }else{
                
            }
            
        
    }
    
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        print("buradayız")
        return nearByUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("convertMapToListCell", owner: self, options: nil)?.first as! convertMapToListCell
        cell.nameLabel.text = nearByUsers[indexPath.row].name
        return cell
    }
    
    
    @IBAction func listButtonTapped(_ sender: Any) {
        popupAnimate()
    }
    func popupAnimate(){
        UIView.animate(withDuration: 1.0,
                       delay: TimeInterval(0.2),
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.9,
                       options: UIViewAnimationOptions.curveLinear,
                       animations: {
                        if (self.tableViewConstraint.constant == 0){
                            
                            self.illustrateButton.setTitle("ListView", for: UIControlState.normal)
                            self.tableViewConstraint.constant = 550
                        }else{
                            self.illustrateButton.setTitle("MapView", for: UIControlState.normal)
                            
                               self.tableViewConstraint.constant = 0
                        }
                     
                        self.view.layoutIfNeeded()
                        
        }, completion: { finished in
            
            
            
        })
        
    }
    
    
}
