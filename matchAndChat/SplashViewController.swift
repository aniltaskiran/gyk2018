//
//  ViewController.swift
//  Match and Chat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {

    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.performSegue(withIdentifier: "mainSegue", sender: self)
        
        print("asasdd")
    }
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
//
//        let user = Auth.auth().currentUser
//        if let usr = user {
//            print(usr.email)
//        }
        
        
//
//        if let existingEmail = UserDefaults.standard.value(forKey: "emailKey")  {
//           email = existingEmail as! String
//        }
//        if let existingPassword = UserDefaults.standard.value(forKey: "passwordKey")  {
//            password = existingPassword as! String
//        }
//
//        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
//
//            if(err != nil) {
//                print(err?.localizedDescription)
//            } else {
//                self.performSegue(withIdentifier: "mainSegue", sender: self)
//            }
//        }
        
    

}

