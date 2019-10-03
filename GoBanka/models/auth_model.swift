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
    static func login(email: String, password: String, completionHandler: @escaping((_ data: Any, _ error: String) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            completionHandler(user ?? "", error?.localizedDescription ?? "")
        })
    }
    
    static func getUser(email: String, completionHandler: @escaping((_ user: Any, _ error: String) -> Void)) {
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
    
    static func logAttempt(id: String, valid: Bool, completionHandler: @escaping((_ blocked: Bool) -> Void)) {
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
}
