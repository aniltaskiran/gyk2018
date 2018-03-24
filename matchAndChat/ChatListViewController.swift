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


class ChatListViewController: UIViewController {
    var ref: DatabaseReference!
//    var users: [String] = []
    var userChatArr: [UserChat] = []
    var userDetailArr: [UserDetail] = []
//    var allUsers: [String:Any] = [:]
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
                for (key, currentValue) in allValues {
                    var isContainsUser = false

                    let usr = UserChat(key: key as! String, values: currentValue)
                    if usr.isMyChat && self.userChatArr.count > 0 {
                        for checkUsr in self.userChatArr {
                            print("checkUSR id \(checkUsr.id)")
                            print("key id \(key as! String)")
                            if checkUsr.id == key as! String {
                                isContainsUser = true
                            }
                        }
                    }
                    
                     if usr.isMyChat && !isContainsUser {
                        self.userChatArr.append(usr)
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
    
    func write(){
        self.ref.child("allChats").child("-19033434").child("messages").childByAutoId().setValue(["senderID":Auth.auth().currentUser?.uid,"senderName":Auth.auth().currentUser?.email,"text":"asdasdas"])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            if let usr = sender as? UserDetail {
                let chatVc = segue.destination as! ChatViewController
                chatVc.usr = usr
                
            } else {
                let chatVc = segue.destination as! ChatViewController
                chatVc.usr = UserDetail(id: (sender as? String)!)
            }
        }
    }
}


extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

        if "-\(authID!)" == receiverID {
            displayName = userChatArr[indexPath.row].senderID
        }
        
        for user in userDetailArr {
            if user.id == displayName {
                cell.usernameLabel.text = user.name
                lat = user.lat
                long = user.long
            }
        }
        print("all user detail")
        print(userDetailArr)
        cell.lastLocationDistance.text = "\(lat):\(long)"
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print(userChatArr[indexPath.row].id)
        
        if let usr = userIDToDetail[userChatArr[indexPath.row].getReceiverID()] {
            self.performSegue(withIdentifier: "chatSegue", sender: usr)
        } else {
//            userChatArr[indexPath.row].id
            
            self.performSegue(withIdentifier: "chatSegue", sender: userChatArr[indexPath.row].getReceiverID())
        }

    }
    
    
}

