//
//  transaction_validation.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

class TransactionValidation {
    static func multipleOf500(amount: String) -> Bool {
        return (Int(amount) ?? 0) % 500 == 0
    }
    
    static func sufficientBalance(amount: String, balance: Double) -> Bool {
        return (balance - (Double(amount)!) > 0)
    }
    
    static func minimumAmount(amount: String) -> Bool {
         return (Int(amount) ?? 0) > 500
    }
}
