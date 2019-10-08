//
//  auth.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase

class AuthModel {
    
    var id: String!
    var email: String!
    var fullName: String!
    var accountNumber: String!
    var balance: Double!
    var isActive: Bool!
    
    func updateUserDetails(id: String, email: String, fullName: String, accountNumber: String, balance: Double, isActive: Bool) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.accountNumber = accountNumber
        self.balance = balance
        self.isActive = isActive
    }
}

extension AuthModel: AuthAPIProtocol {
    func login(email: String, password: String, completionHandler: @escaping((_ data: Any, _ error: String) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            completionHandler(user ?? "", error?.localizedDescription ?? "")
        })
    }
    
    func getUser(email: String, completionHandler: @escaping((_ user: Any, _ error: String) -> Void)) {
        let databaseRef = Database.database().reference().child("Users")
        let query = databaseRef.queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: "\(email)\\uf8ff")
        query.observeSingleEvent(of: .value) { (snapshot) in
            if let user = snapshot.value as? NSDictionary {
                completionHandler(user, "")
            } else {
                completionHandler("", "User does not exist")
            }
        }
    }
    
    func logAttempt(id: String, valid: Bool, completionHandler: @escaping((_ blocked: Bool) -> Void)) {
        let databaseRef = Database.database().reference().child("LoginAttempts").child(id)
        let userRef = Database.database().reference().child("Users").child(id)
        if valid {
            databaseRef.setValue(nil)
        } else {
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                var attempts = (snapshot.value as? Int) ?? 0
                attempts += 1
                if attempts >= 3 {
                    userRef.updateChildValues(["active": false])
                    completionHandler(true)
                } else {
                    databaseRef.setValue(attempts)
                }
            }
        }
    }
    
    func createUser(userDetails: [String: Any], completionHandler: @escaping((_ success: Bool) -> Void)) {
        let userRef = Database.database().reference().child("Users").childByAutoId()
        userRef.setValue(userDetails) { (error, _) in
            if error == nil {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
}
