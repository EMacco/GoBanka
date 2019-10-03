//
//  ViewController.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let alert = CustomAlert()
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginBtn.setTitle("Loading...", for: .disabled)
    }
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if RequiredFields.requiredFieldsEmpty(fields: [emailField.text!, passwordField.text!]) {
            alert.showAlert(text: "Please fill all required information", type: "info", parentView: self.view)
            return
        }
        
        let email = RequiredFields.trimWhiteSpaces(text: emailField.text!)
        let password = RequiredFields.trimWhiteSpaces(text: passwordField.text!)
        loginBtn.isEnabled = false
        AuthModel.login(email: email, password: password) { (user, error) in
            self.loginBtn.isEnabled = true
            if error != "" {
                self.logAttempt(valid: false)
                self.alert.showAlert(text: "Invalid username or password", type: "error", parentView: self.view)
            } else {
                AuthModel.getUser(email: email) { (user, error) in
                    if let userDetails = user as? NSDictionary {
                        for (_, value) in userDetails {
                            let details = value as! NSDictionary
                            let isActive = details["active"] as? Bool
                            if isActive ?? true {
                                self.redirectToHome()
                                self.logAttempt(valid: true)
                            } else {
                                self.alert.showAlert(text: "This account has been deactivated", type: "error", parentView: self.view)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func logAttempt(valid: Bool) {
        let email = RequiredFields.trimWhiteSpaces(text: emailField.text!)
        AuthModel.getUser(email: email) { (user, error) in
            if let userDetails = user as? NSDictionary {
                AuthModel.logAttempt(id: userDetails.allKeys[0] as! String, valid: valid) { (blocked) in
                    if blocked {
                        self.alert.showAlert(text: "This account has been blocked", type: "error", parentView: self.view)
                    }
                }
            }
        }
    }
    
    func redirectToHome() {
        self.passwordField.text = ""
        let controller = storyboard?.instantiateViewController(identifier: "userHomeVC") as! UserHomeViewController
        controller.modalTransitionStyle = .flipHorizontal
        controller.userEmail = RequiredFields.trimWhiteSpaces(text: emailField.text!)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
}

