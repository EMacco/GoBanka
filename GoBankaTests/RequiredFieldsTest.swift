//
//  RequiredFieldsTest.swift
//  GoBankaTests
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import XCTest
@testable import GoBanka

class RequiredFieldsTest: XCTestCase {
    func testRequiredFields() {
        XCTAssertTrue(RequiredFields.requiredFieldsEmpty(fields: ["email", ""]))
    }
    
    func testWhitespaceTrim() {
        let text = "    Peter Griffin  "
        let trimmedText = RequiredFields.trimWhiteSpaces(text: text)
        XCTAssertTrue(trimmedText == "Peter Griffin")
    }
}
