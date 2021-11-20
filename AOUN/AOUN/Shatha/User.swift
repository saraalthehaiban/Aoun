//
//  User.swift
//  AOUN
//
//  Created by shatha on 12/03/1443 AH.
//

import Foundation

struct User  {
    var FirstName : String,
        LastName : String,
        uid : String
    
    var docID : String?
    var documentID : String? {
        get {
            return docID
        }
    }
    
    var fullName : String? {
        get {
            let fullName = "\(FirstName) \(LastName)"
            return fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var displayName : String {
        get {
            let name = "\(FirstName) \(LastName)"
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var dictionary : [String:Any] {
        get {
            return [
                "FirstName" : FirstName,
                "LastName" : LastName,
                "uid" : uid,
            ]
        }
    }
}

extension User {
    init?(dictionary:[String: Any]) {
        guard let FirstName  = dictionary["FirstName"] as? String,
              let LastName  = dictionary["LastName"] as? String,
              let uid = dictionary["uid"] as? String
        else {
            return nil
        }
        
        self.init(FirstName: FirstName, LastName: LastName, uid: uid)
    }
}

