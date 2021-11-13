//
//  User.swift
//  AOUN
//
//  Created by shatha on 12/03/1443 AH.
//

import Foundation

struct User : Codable {
    let FirstName : String
    let LastName : String
    let uid : String
    
    //
    var docID : String?
    
    var fullName : String? {
        get {
            let fullName = "\(FirstName) \(LastName)"
            return fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
