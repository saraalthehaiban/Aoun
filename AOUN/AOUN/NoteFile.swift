//
//  noteFile.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import Foundation

let K_SAR_TO_USD_CONVERSION_RATE : Decimal = 3.75
struct NoteFile {
    let noteLable : String
    let autherName : String
    let desc : String
    let price : String?
    let urlString : String
    
    //...
    var priceDecimal : Decimal? {
        get {
            if let p = price, p.count > 0, let price = Decimal(string: p), price > 0 {
                return price
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
    
    var url : URL? {
        get {
            return URL (string: urlString)
        }
    }
}
