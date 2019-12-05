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
    @IBOutlet weak var appReleaseDetailsLbl: UILabel!
    
    let currentUser = AuthModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginBtn.setTitle("Loading...", for: .disabled)
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        appReleaseDetailsLbl.text = "Version \(appVersionString) (\(buildNumber))"
    }
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if RequiredFields.requiredFieldsEmpty(fields: [emailField.text!, passwordField.text!]) {
            alert.showAlert(text: "Please fill all required information", type: "info", parentView: self.view)
            return
        }
        
        let email = RequiredFields.trimWhiteSpaces(text: emailField.text!)
        let password = RequiredFields.trimWhiteSpaces(text: passwordField.text!)
        loginBtn.isEnabled = false
        self.currentUser.login(email: email, password: password) { (user, error) in
            self.loginBtn.isEnabled = true
            if error != "" {
                self.logAttempt(valid: false)
                self.alert.showAlert(text: "Invalid username or password", type: "error", parentView: self.view)
            } else {
                self.currentUser.getUser(email: email) { (user, error) in
                    if let userDetails = user as? NSDictionary {
                        for (key, value) in userDetails {
                            let details = value as! NSDictionary
                            let id = key as! String
                            let email = details["email"] as! String
                            let fullName = details["fullName"] as! String
                            let accountNumber = details["accountNumber"] as! String
                            let balance = details["balance"] as! Double
                            let isActive = details["active"] as? Bool
                            self.currentUser.updateUserDetails(id: id, email: email, fullName: fullName, accountNumber: accountNumber, balance: balance, isActive: isActive ?? true)
                            
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
        self.currentUser.getUser(email: email) { (user, error) in
            if let userDetails = user as? NSDictionary {
                self.currentUser.logAttempt(id: userDetails.allKeys[0] as! String, valid: valid) { (blocked) in
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
        controller.currentUser = self.currentUser
        self.present(controller, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
}
