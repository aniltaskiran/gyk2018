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


class ChatListViewController: UIViewController {
    var ref: DatabaseReference!
    var users: [String] = []
    var allUsers: [String:Any] = [:]
    var userIDToName: [String:[String:String]] = [:]

    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        read()
    }
    
    func create(){
        let uuid = UUID().uuidString
        print(uuid)
    }
    
    func read(){
        print(Auth.auth().currentUser?.uid ?? "")
        ref.child("allChats").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let allValues = value {
                for (key, value) in allValues {
                    let chatValues = value as! [String:Any]
                    let receiverID = chatValues["receiverID"] as! String
                    let senderID = chatValues["senderID"] as! String
                    
                    let currentUserID = Auth.auth().currentUser?.uid
                    
                    if currentUserID == receiverID || currentUserID == senderID {
                        self.users.append(key as! String)
                        self.allUsers[key as! String] = value
                        self.userIDToName["-\(receiverID)"] = ["name":"","lat":"","long":""]
                        self.userIDToName["-\(senderID)"] = ["name":"","lat":"","long":""]
                    }
                }
            }
            
            self.ref.child("Users").observeSingleEvent(of: .value, with: { (snapshotUsers) in
                
                let idValues = snapshotUsers.value as? NSDictionary
                if let _ = idValues {
                    for (idKey, idValue) in idValues! {
                        var _key = idKey as! String
                        let allIDS = idValue as! [String:Any]
                        if let x = self.userIDToName[_key]{
                           self.userIDToName[idKey as! String]!["name"] = allIDS["name"] as? String
                            self.userIDToName[idKey as! String]!["lat"] = String(describing: allIDS["lat"])
                            self.userIDToName[idKey as! String]!["long"] = String(describing: allIDS["long"])
                            print("lat")
                            print(allIDS["lat"] as? Double)
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
    
    func write(){
        self.ref.child("allChats").child("-19033434").child("messages").childByAutoId().setValue(["senderID":Auth.auth().currentUser?.uid,"sender:Name":Auth.auth().currentUser?.email,"text":"asdasdas"])
        
    }
}


extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("chatList", owner: self, options: nil)?.first as! chatListCell
        
        var displayName = ""
        
        let chatValues = allUsers[users[indexPath.row]] as! [String:Any]
        let receiverID = chatValues["receiverID"] as! String
        displayName = receiverID
        
        if Auth.auth().currentUser?.uid == receiverID {
            displayName = chatValues["senderID"] as! String
        }
        
        cell.usernameLabel.text = userIDToName["-\(displayName)"]?["name"]
        
        print(userIDToName)
        let lat = userIDToName["-\(displayName)"]?["lat"]
        let long = userIDToName["-\(displayName)"]?["long"]
        cell.lastLocationDistance.text = "\(lat):\(long)"


        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

