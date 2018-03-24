//
//  LoginViewController.swift
//  Match and Chat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            if err != nil {
                // alert
            } else {
                self.performSegue(withIdentifier: "mainScreenSegue", sender: self)
            }
        }
    }
    @IBAction func registerButtonPressed(_ sender: UIButton) {
            self.performSegue(withIdentifier: "registerSegue", sender: self)
    }
    

}
