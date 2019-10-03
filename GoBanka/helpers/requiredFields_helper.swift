//
//  requiredFields.swift
//  GoBanka
//
//  Created by Itunu Adekoya on 03/10/2019.
//  Copyright © 2019 Itunu Adekoyaaa. All rights reserved.
//

import Foundation

class RequiredFields {
    static func requiredFieldsEmpty(fields: [String]) -> Bool {
        var empty = false;
        for field in fields {
            if trimWhiteSpaces(text: field) == "" {
                empty = true
                break
            }
        }
        return empty
    }
    
    static func trimWhiteSpaces(text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
