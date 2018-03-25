//
//  ViewController.swift
//  matchAndChat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import CoreLocation

var userIDToDetail: [String:UserDetail] = [:]
var userChatArr: [UserChat] = []


class ChatListViewController: UIViewController {
    var ref: DatabaseReference!
//    var users: [String] = []
    var userDetailArr: [UserDetail] = []
//    var allUsers: [String:Any] = [:]
    var userIDToName: [String:[String:String]] = [:]
    let locationManager = CLLocationManager()

    var userLat = 0.0
    var userLong = 0.0
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        read()
    }
 
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("fail log")
        }
    }
    
    func create(){
        let uuid = UUID().uuidString
        print(uuid)
    }
    func writeUser(){
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).setValue(["lat":self.userLat,"long":self.userLong,"name":username])
//        self.ref.child("Users").child("4nCbFJhOUHhqPcqDJAsf1K3MwzI3").setValue(["lat":41.066570,"long":28.942630,"name":"Egemen Erden"])
//         self.ref.child("Users").child("43sdbFsdkfHhqPcqDJAklkMwzI3").setValue(["lat":41.064570,"long":28.941030,"name":"Yücel Karacalar"])
//        
    }
    func writeChat(){
        self.ref.child("allChats").child("19033434").child("messages").childByAutoId().setValue(["senderID":Auth.auth().currentUser?.uid,"senderName":Auth.auth().currentUser?.email,"text":"Merhaba!"])
        
    }

    
    func read(){
        print(Auth.auth().currentUser?.uid ?? "")
        ref.child("allChats").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let allValues = value {
                for (key, currentValue) in allValues {
                    var isContainsUser = false

                    let usr = UserChat(key: key as! String, values: currentValue)
                    if usr.isMyChat && userChatArr.count > 0 {
                        for checkUsr in userChatArr {
                            print("checkUSR id \(checkUsr.id)")
                            print("key id \(key as! String)")
                            if checkUsr.id == key as! String {
                                isContainsUser = true
                            }
                        }
                    }
                    
                     if usr.isMyChat && !isContainsUser {
                        userChatArr.append(usr)
                    }
                }
            }
            
            self.ref.child("Users").observeSingleEvent(of: .value, with: { (snapshotUsers) in
                
                let idValues = snapshotUsers.value as? NSDictionary
                if let _ = idValues {
                    for (idKey, idValue) in idValues! {
                        if let _ = userIDToDetail[idKey as! String] {
                            print("user detail contains")
                        } else {
                            let usrDetail = UserDetail(key: idKey as! String, values: idValues! as! [String : Any])
                            userIDToDetail[idKey as! String] = usrDetail
                            self.userDetailArr.append(usrDetail)
                        }
                      

                }
                
                }
                DispatchQueue.main.async {
                    self.chatListTableView.reloadData()
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
        
        }) { (error) in
            print(error.localizedDescription)
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.white
            navigationItem.backBarButtonItem = backItem
            
            if let user = sender as? UserChat {
                let chatVc = segue.destination as! ChatViewController
                chatVc.usr = user
            }
        }
    }
}


extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userChatArr.count < 0 {
            chatListTableView.isHidden = true
        } else {
            chatListTableView.isHidden = false
        }
        return userChatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("chatList", owner: self, options: nil)?.first as! chatListCell
        
        var displayName = ""
        var lat = ""
        var long = ""
        
        let receiverID = userChatArr[indexPath.row].receiverID
        displayName = receiverID
        print("auth uid")
        print(Auth.auth().currentUser?.uid)
        print("receiver id")
        print(receiverID)

        var authID = Auth.auth().currentUser?.uid

        if "\(authID!)" == receiverID {
            displayName = userChatArr[indexPath.row].senderID
        }
        
        for user in userDetailArr {
            if user.id == displayName {
                cell.usernameLabel.text = user.name
                lat = user.lat
                long = user.long
                let coordinate = CLLocation(latitude: self.userLat, longitude: self.userLong)
                
                let requestCoordinate = CLLocation(latitude: Double(user.lat)!, longitude: Double(user.long)!)
                
                let distanceInMeters = coordinate.distance(from: requestCoordinate)
                
                cell.lastLocationDistance.text = "\(String(format: "%.f", distanceInMeters)) metre yakınınızda"
                cell.lastLocationDistance.adjustsFontSizeToFitWidth = true
            }
        }
        
        cell.profileImageView.image = UIImage(named: "\(indexPath.row%3)")
        
        cell.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        let cons = cell.profileImageView.layer
        cons.borderWidth = 1
        cons.masksToBounds = false
        cons.borderColor = UIColor.black.cgColor
        cons.cornerRadius = cell.profileImageView.frame.height/2
             cell.profileImageView.clipsToBounds = true
        print("all user detail")
        print(userDetailArr)
        
  
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print(userChatArr[indexPath.row].id)
        channelID = userChatArr[indexPath.row].id
        groupPhoto = "\(indexPath.row % 3)"
        self.performSegue(withIdentifier: "chatSegue", sender: userChatArr[indexPath.row])
        

    }
    
    
}

extension ChatListViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude )
        userLat = location.latitude
        userLong = location.longitude
        writeUser()
        chatListTableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                // authorized location status when app is in use; update current location
                locationManager.startUpdatingLocation()
                // implement additional logic if needed...
            }
            // implement logic for other status values if needed...
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

