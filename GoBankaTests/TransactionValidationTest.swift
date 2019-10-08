//
//  TransactionValidationTest.swift
//  GoBankaTests
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import XCTest
@testable import GoBanka

class TransactionValidationTest: XCTestCase {
    func testMultipleOf500() {
        XCTAssertFalse(TransactionValidation.multipleOf500(amount: "300"))
        XCTAssertTrue(TransactionValidation.multipleOf500(amount: "1000"))
    }
    
    func testSufficientBalance() {
        XCTAssertFalse(TransactionValidation.sufficientBalance(amount: "5000", balance: 2000))
        XCTAssertTrue(TransactionValidation.sufficientBalance(amount: "5000", balance: 20000))
    }
    
    func testMinimumAmount() {
        XCTAssertFalse(TransactionValidation.minimumAmount(amount: "200"))
        XCTAssertTrue(TransactionValidation.minimumAmount(amount: "1000"))
    }
}
