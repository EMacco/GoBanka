//
//  UserHomeViewController.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import UIKit

class UserHomeViewController: UIViewController {
    
    var currentUser: AuthModel!
    @IBOutlet weak var accountDetailsView: UIView!
    @IBOutlet weak var availableBalanceLbl: UILabel!
    @IBOutlet weak var accountNumberLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var userTransactions = [TransactionModel]()
    let transactionModel = TransactionModel()
    @IBOutlet weak var noTransactionsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountDetailsView.dropShadow()
        
        if self.currentUser.id == nil {
            self.getCurrentUser()
        } else {
            self.populateUserDetails()
        }
    }
    
    func populateUserDetails() {
        self.availableBalanceLbl.text = TextFormatter.addCommas(balance: self.currentUser.balance)
        self.accountNumberLbl.text = self.currentUser.accountNumber
        
        self.transactionModel.fetchUserTransactions(id: self.currentUser.id) { (transaction, key) in
            let details = transaction
            let id = key
            let accountNumber = details["accountNumber"] as! String
            let amount = details["amount"] as! Double
            let balance = details["balance"] as! Double
            let location = details["location"] as! String
            let timestamp = details["timestamp"] as! Double
            let type = details["type"] as! String
            self.userTransactions.append(TransactionModel(id: id, accountNumber: accountNumber, balance: balance, amount: amount, location: location, timestamp: timestamp, type: type))
            self.sortViaTimestamp()
            self.tableView.reloadData()
            self.noTransactionsLbl.alpha = 0
        }
    }
    
    func getCurrentUser() {
        self.currentUser.getUser(email: self.currentUser.email) { (user, error) in
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
                    self.populateUserDetails()
                }
            }
        }
    }
}

extension UserHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        cell.transactionTypeLbl.text = self.userTransactions[indexPath.row].type
        cell.timeLbl.text = TextFormatter.convertTimeStamp(serverTimestamp: self.userTransactions[indexPath.row].timestamp)
        cell.amountLbl.text = TextFormatter.addCommas(balance: self.userTransactions[indexPath.row].amount)
        
        switch self.userTransactions[indexPath.row].type.lowercased() {
        case "deposit":
            cell.amountLbl.textColor = UIColor(displayP3Red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
            break
        case "withdrawal":
            cell.amountLbl.textColor = UIColor.red
            break
        default:
            cell.amountLbl.textColor = UIColor.black
        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userTransactions.count
    }
    
    func sortViaTimestamp() {
        self.userTransactions = self.userTransactions.sorted(by: { $0.timestamp > $1.timestamp })
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 5
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

class TransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionTypeLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
}
