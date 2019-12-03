//
//  TextFormatterTest.swift
//  GoBankaTests
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import XCTest
@testable import GoBanka

class TextFormatterTest: XCTestCase {
    func testNumberFormatter() {
        let amount = 5000.0
        let formattedNumber = TextFormatter.addCommas(balance: amount)
        XCTAssertTrue(formattedNumber == "N5,000")
    }
    
//    func testConvertTimeStamp() {
//        let timestamp = 1570545033440.0
//        let formattedTime = TextFormatter.convertTimeStamp(serverTimestamp: timestamp)
//        XCTAssertTrue(formattedTime == "Oct 08 2019 03:30 PM")
//    }
}
