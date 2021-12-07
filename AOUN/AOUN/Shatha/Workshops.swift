//
//  workshop.swift
//  AOUN
//
//  Created by shatha on 26/03/1443 AH.
//

import Foundation
import Firebase


class PriceUtils {
    static func usd(fromSAR sar:Decimal) -> Decimal {
        return sar / K_SAR_TO_USD_CONVERSION_RATE
    }
    
    static func usdString (fromSAR sar : Decimal) -> String {
        let doubleValue = Double(truncating: PriceUtils.usd(fromSAR: sar) as NSNumber)
        return String(format: "%.2f", doubleValue)
    }
}

struct Workshops {
    let Title : String
    let presenter : String
    let price : String
    var seat : String
    let description : String
    let dateTime: Timestamp
    var documentId : String?
    let uid:String?
    //there wasn (?)
    
    var numberOfAvailableSeats : Int {
        get {
            return Int(seat) ?? 0
        }
    }
    
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
                return PriceUtils.usd(fromSAR: pd)
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
    
    //for purchased tickets
    var purchasedDate : Timestamp?
    var ticket : Ticket?
}


