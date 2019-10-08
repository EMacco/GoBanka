//
//  transaction_model.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class TransactionModel {
    var id: String!
    var accountNumber: String!
    var balance: Double!
    var amount: Double!
    var location: String!
    var timestamp: Double!
    var type: String!
    
    init(id: String, accountNumber: String, balance: Double, amount: Double, location: String, timestamp: Double, type: String) {
        self.id = id
        self.accountNumber = accountNumber
        self.balance = balance
        self.amount = amount
        self.location = location
        self.timestamp = timestamp
        self.type = type
    }
    
    init() {
        
    }
}

extension TransactionModel: TransactionAPIProtocol {
    func fetchUserTransactions(id: String, completionHandler: @escaping((_ transaction: NSDictionary, _ key: String) -> Void)) {
        let databaseRef = Database.database().reference().child("Transactions").child(id)
        databaseRef.observe(.childAdded) { (snapshot) in
            if let transaction = snapshot.value as? NSDictionary {
                completionHandler(transaction, snapshot.key)
            } else {
                completionHandler([:], "")
            }
        }
    }
    
    func performTransaction(userId: String, transactionDetails: [String: Any], completionHandler: @escaping((_ success: Bool) -> Void)) {
        let databaseRef = Database.database().reference().child("Transactions").child(userId).childByAutoId()
        let userRef = Database.database().reference().child("Users").child(userId).child("balance")
        databaseRef.setValue(transactionDetails) { (error, _) in
            if (error != nil) { completionHandler(false) }
            else {
                userRef.setValue(transactionDetails["balance"] as! Double) { (error, _) in
                    if (error != nil) { completionHandler(false) }
                    else { completionHandler(true) }
                }
            }
        }
    }
}
