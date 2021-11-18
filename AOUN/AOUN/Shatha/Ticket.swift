//
//  Ticket.swift
//  AOUN
//
//  Created by shatha on 10/04/1443 AH.
//

import Foundation
import Firebase

struct Ticket  {
    var buyerName : String,
        price : String,
        time : Timestamp,
        user : String,
        workshop : String,
        workshopTitle : String,
        bookingID : String,
        seats : Int
    
    var documentID : String?
    
    var dictionary : [String:Any] {
        get {
            return [
                "buyerName" : buyerName,
                "price" : price,
                "time" : time,
                "user" : user,
                "workshop" : workshop,
                "workshopTitle" : workshopTitle,
                "bookingID" : bookingID,
                "seats" : seats
            ]
        }
    }
}

extension Ticket {
    init?(dictionary:[String: Any]) {
        guard let buyerName  = dictionary["buyerName"] as? String,
              let price  = dictionary["price"] as? String,
              let time  = dictionary["time"] as? Timestamp,
              let user  = dictionary["user"] as? String,
              let workshop  = dictionary["workshop"] as? String,
              let workshopTitle  = dictionary["workshopTitle"] as?  String,
              let bookingID = dictionary["bookingID"] as?  String,
              let seats = dictionary["seats"] as? Int
        else {
            return nil
        }
        
        self.init(buyerName: buyerName, price: price, time: time, user: user, workshop: workshop, workshopTitle: workshopTitle, bookingID:bookingID, seats:seats)
    }
}

