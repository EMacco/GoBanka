//
//  File.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

class AuthValidation {
    func validEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailTest.evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return false
        }
        return true
    }
    
    func validatePassword(password: String) -> Bool {
        return password.trimmingCharacters(in: .whitespacesAndNewlines).count > 6
    }
}
