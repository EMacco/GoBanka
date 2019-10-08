//
//  transactionApiProtocol.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

protocol TransactionAPIProtocol {
    func fetchUserTransactions(id: String, completionHandler: @escaping((_ transaction: NSDictionary, _ key: String) -> Void))
    func performTransaction(userId: String, transactionDetails: [String: Any], completionHandler: @escaping((_ success: Bool) -> Void))
}
