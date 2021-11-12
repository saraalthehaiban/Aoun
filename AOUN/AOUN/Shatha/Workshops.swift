//
//  workshop.swift
//  AOUN
//
//  Created by shatha on 26/03/1443 AH.
//

import Foundation
struct Workshops {
    let Title : String
    let presenter : String
    let price : String
    var seat : String
    let description : String
    let dateTime: String
    var documentId : String?
    let uid:String?
    //there wasn (?)
    
    //...
    var priceDecimal : Decimal? {
        get {
            if price.count > 0, let dprice = Decimal(string: price), dprice > 0 {
                return dprice
            }
            return nil
        }
    }
    
    var usdPrice: Decimal? {
        get {
            if let pd = self.priceDecimal {
                return pd / K_SAR_TO_USD_CONVERSION_RATE
            }
            return nil
        }
    }
    
    var usdString : String! {
        get {
            if let d = self.usdPrice {
                let doubleValue = Double(truncating: d as NSNumber)
                return String(format: "%.2f", doubleValue)
            }
            return ""
        }
    }
}


