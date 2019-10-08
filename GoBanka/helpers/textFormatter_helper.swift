//
//  addCommas_helper.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 08/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

class TextFormatter {
    static func addCommas(balance: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: balance))
        return "N\(String(describing: formattedNumber!))"
    }
    
    static func convertTimeStamp(serverTimestamp: Double) -> String {
        let date = NSDate(timeIntervalSince1970: serverTimestamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
}
