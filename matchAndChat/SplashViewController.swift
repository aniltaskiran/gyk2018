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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Splash callback  
        if let _ = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "mainSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
}

