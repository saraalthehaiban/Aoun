//
//  Utilities.swift
//  Utilities
//
//  Created by Macbook pro on 03/10/2021.
//

import Foundation
import UIKit

class Utilities {
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isValidName(testStr:String) -> Bool {
        guard testStr.count > 2, testStr.count < 14 else { return false }
        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return predicateTest.evaluate(with: testStr)
    }

    static func isValidEmail(_ email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email)
    }
    
    //Server Format "yyyyy-MM-dd HH:mm:ss+Z"
    static func serverDateFormatter (format:String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = format
        return df
    }
}

extension Date {
    func displayString () -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .short
        dateFormat.locale = Locale.current
        return dateFormat.string(from: self)
    }
    
    var dateString : String {
        get {
            let df = DateFormatter()
            df.dateStyle = .medium
            return df.string(from: self)
        }
    }
    
    var timeString : String {
        get {
            let df = DateFormatter()
            df.timeStyle = .short
            return df.string(from: self)
        }
    }
}

//2021-11-23 07:38:00 +0000


