//
//  AuthProtocol.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

protocol AuthAPIProtocol {
    func login(email: String, password: String, completionHandler: @escaping((_ data: Any, _ error: String) -> Void))
    func getUser(email: String, completionHandler: @escaping((_ user: Any, _ error: String) -> Void))
    func logAttempt(id: String, valid: Bool, completionHandler: @escaping((_ blocked: Bool) -> Void))
    func createUser(userDetails: [String: Any], completionHandler: @escaping((_ success: Bool) -> Void))
}
