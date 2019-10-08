//
//  RegitrationViewController.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegitrationViewController: UIViewController {

    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    let alert = CustomAlert()
    let currentUser = AuthModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerBtn.setTitle("Creating...", for: .disabled)
        
    }

    @IBAction func registerBtnClicked(_ sender: UIButton) {
        let fullName = RequiredFields.trimWhiteSpaces(text: fullNameField.text!)
        let email =  RequiredFields.trimWhiteSpaces(text: emailField.text!)
        let password =  RequiredFields.trimWhiteSpaces(text: passwordField.text!)
        if RequiredFields.requiredFieldsEmpty(fields: [fullName, email, password]) {
            alert.showAlert(text: "Please fill all required information", type: "info", parentView: self.view)
            return
        }
        
        registerBtn.isEnabled = false
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            self.registerBtn.isEnabled = true
            if (error != nil) {
                self.alert.showAlert(text: error?.localizedDescription ?? "Error creating user", type: "error", parentView: self.view)
            } else {
                var userDetails = [String: Any]()
                userDetails["fullName"] = fullName
                userDetails["email"] = email
                userDetails["balance"] = 5000
                userDetails["active"] = true
                
                var acctNum = ""
                for _ in 0..<10 {
                    acctNum += String(Int.random(in: 0...9))
                }
                userDetails["accountNumber"] = acctNum
                
                self.currentUser.createUser(userDetails: userDetails) { (success) in
                    if success {
                        self.redirectToHome()
                    } else {
                        self.alert.showAlert(text: "Error creating user", type: "error", parentView: self.view)
                    }
                }
                
            }
        }
    }
    
    func redirectToHome() {
        let controller = storyboard?.instantiateViewController(identifier: "userHomeVC") as! UserHomeViewController
        controller.modalTransitionStyle = .flipHorizontal
        self.currentUser.email = RequiredFields.trimWhiteSpaces(text: emailField.text!)
        controller.currentUser = self.currentUser
        self.present(controller, animated: true, completion: nil)
        self.passwordField.text = ""
        self.fullNameField.text = ""
        self.emailField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
