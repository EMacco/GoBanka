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
    @IBOutlet var transactionContainerView: UIView!
    @IBOutlet weak var transactionFormView: UIView!
    @IBOutlet weak var transactionBlurView: UIVisualEffectView!
    @IBOutlet weak var transactionTypeLbl: UILabel!
    @IBOutlet weak var transactionAmountField: UITextField!
    @IBOutlet weak var transactionPasswordField: UITextField!
    @IBOutlet weak var confirmTransactionBtn: UIButton!
    let alert = CustomAlert()
    var transactionType = ""
    
    @IBOutlet weak var receiptTypeLbl: UILabel!
    @IBOutlet weak var receiptAmountLbl: UILabel!
    @IBOutlet weak var receiptBalanceLbl: UILabel!
    @IBOutlet weak var receiptLocationLbl: UILabel!
    @IBOutlet weak var receiptDateLbl: UILabel!
    @IBOutlet weak var receiptAccountNumberLbl: UILabel!
    @IBOutlet weak var receiptContainerView: UIView!
    var currentReceipt: TransactionModel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountDetailsView.dropShadow()
        
        if self.currentUser.id == nil {
            self.getCurrentUser()
        } else {
            self.populateUserDetails()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideTransactionContainerView))
        self.transactionBlurView.addGestureRecognizer(tap)
        
        let tapForm = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.transactionFormView.addGestureRecognizer(tapForm)
        self.confirmTransactionBtn.setTitle("Please wait...", for: .disabled)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func depositBtnClicked(_ sender: UIButton) {
        self.transactionType = "Deposit"
        self.showTransactionContainerView(isReceipt: false)
    }
    
    @IBAction func withdrawBtnClicked(_ sender: UIButton) {
        self.transactionType = "Withdrawal"
        self.showTransactionContainerView(isReceipt: false)
    }
    
    @IBAction func transactionBtnClicked(_ sender: UIButton) {
        if RequiredFields.requiredFieldsEmpty(fields: [transactionAmountField.text!, transactionPasswordField.text!]) {
            alert.showAlert(text: "Please fill all required information", type: "info", parentView: self.transactionContainerView)
            return
        }
        
        if self.transactionType.lowercased() == "withdrawal" {
            if !TransactionValidation.multipleOf500(amount: transactionAmountField.text!) {
                alert.showAlert(text: "You can only withdraw in multiples of 500", type: "error", parentView: self.transactionContainerView)
                return
            }
            
            if !TransactionValidation.sufficientBalance(amount: transactionAmountField.text!, balance: self.currentUser.balance) {
                alert.showAlert(text: "You have insufficient balance", type: "error", parentView: self.transactionContainerView)
                return
            }
        }
        
        if !TransactionValidation.minimumAmount(amount: transactionAmountField.text!) {
            alert.showAlert(text: "Minimum amount is N500", type: "error", parentView: self.transactionContainerView)
            return
        }
        
        let confirmUser = AuthModel()
        self.confirmTransactionBtn.isEnabled = false
        confirmUser.login(email: self.currentUser.email, password: self.transactionPasswordField.text!) { (user, error) in
            if error != "" {
                self.confirmTransactionBtn.isEnabled = true
                self.alert.showAlert(text: "Password is incorrect", type: "error", parentView: self.transactionContainerView)
            } else {
                var transactionDetails = [String: Any]()
                transactionDetails["accountNumber"] = self.currentUser.accountNumber
                transactionDetails["amount"] = Double(self.transactionAmountField.text!)
                
                if self.transactionType.lowercased() == "withdrawal" {
                    transactionDetails["balance"] = self.currentUser.balance - (Double(self.transactionAmountField.text!)!)
                } else {
                    transactionDetails["balance"] = self.currentUser.balance + (Double(self.transactionAmountField.text!)!)
                }
                
                transactionDetails["location"] = "Lagos, Nigeria"
                transactionDetails["timestamp"] = [".sv": "timestamp"]
                transactionDetails["type"] = self.transactionType
                
                self.transactionModel.performTransaction(userId: self.currentUser.id, transactionDetails: transactionDetails) { (success) in
                    self.confirmTransactionBtn.isEnabled = true
                    if success {
                        self.hideTransactionContainerView()
                        self.transactionPasswordField.text = ""
                        self.transactionAmountField.text = ""
                        self.alert.showAlert(text: "Transaction Successful", type: "success", parentView: self.view)
                        self.currentUser.balance = transactionDetails["balance"] as? Double
                        self.availableBalanceLbl.text = TextFormatter.addCommas(balance: self.currentUser.balance)
                    }
                }
            }
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
    
    func showTransactionContainerView(isReceipt: Bool) {
        let newView = self.transactionContainerView!
        
        self.view.addSubview(newView)
        self.transactionContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: newView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: newView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: newView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: newView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.transactionTypeLbl.text = self.transactionType
        if isReceipt {
            self.receiptContainerView.alpha = 1
            self.populateReceipt()
        } else {
            self.receiptContainerView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            newView.alpha = 1
        }
    }
    
    func populateReceipt() {
        self.receiptTypeLbl.text = self.currentReceipt.type
        self.receiptAmountLbl.text = TextFormatter.addCommas(balance: self.currentReceipt.amount)
        self.receiptBalanceLbl.text = TextFormatter.addCommas(balance: self.currentReceipt.balance)
        self.receiptLocationLbl.text = self.currentReceipt.location
        self.receiptDateLbl.text = TextFormatter.convertTimeStamp(serverTimestamp: self.currentReceipt.timestamp)
        self.receiptAccountNumberLbl.text = self.currentReceipt.accountNumber
    }
    
    @objc func hideTransactionContainerView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transactionContainerView.alpha = 0
        }) { (true) in
            self.transactionContainerView.removeFromSuperview()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentReceipt = self.userTransactions[indexPath.row]
        showTransactionContainerView(isReceipt: true)
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
