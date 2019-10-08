//
//  AuthValidationTest.swift
//  GoBankaTests
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import XCTest
@testable import GoBanka

class AuthValidationTest: XCTestCase {

    func testValidEmail() {
        let email = "invalidemail"
        let authValidation = AuthValidation()
        XCTAssertFalse(authValidation.validEmail(email: email))
        
        let correctEmail = "test@test.com"
        XCTAssertTrue(authValidation.validEmail(email: correctEmail))
    }
    
    func testValidPassword() {
        let password = "pass"
        let authValidation = AuthValidation()
        XCTAssertFalse(authValidation.validatePassword(password: password))
        
        let correctPassword = "validPassword"
        XCTAssertTrue(authValidation.validatePassword(password: correctPassword))
    }
}
