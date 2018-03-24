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

var users: [String] = []
var allUsers: [String:Any] = [:]


class ChatListViewController: UIViewController {
    var ref: DatabaseReference!
    
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
        write()
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
                    users.append(key as! String)
                    allUsers[key as! String] = value
                    DispatchQueue.main.async {
                        self.chatListTableView.reloadData()
                    }
                }
            }
        
            // ...
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
        
        cell.usernameLabel.text = displayName
        cell.lastMessageLabel.text = "asdasd"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

