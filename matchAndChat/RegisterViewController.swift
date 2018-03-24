//
//  RegisterViewController.swift
//  Match and Chat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            if err != nil {
                // alert
            } else {
                
                UserDefaults.standard.set(self.emailTextField.text!, forKey: "emailKey")
                UserDefaults.standard.set(self.passwordTextField.text!, forKey: "passwordKey")
                
                self.performSegue(withIdentifier: "mainFromRegisterSegue", sender: self)
            }
        }
    }
}
