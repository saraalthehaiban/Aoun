//
//  Review.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 04/11/2021.
//

import Foundation
import Cosmos
import Firebase
struct Review{
    let nameOfUser: String //user name
    let review: String //body
    let point: Double //star rating
    let user : DocumentReference
    
    var dictionary : [String : Any] {
        return [
            "nameOfUser":nameOfUser,
            "review":review,
            "point":point,
            "user" :user
        ]
    }
}

extension Review {
    init?(dictionary:[String:Any]) {
        guard let review = dictionary["review"] as? String,
              let point =  dictionary["point"] as? Double,
              let nameOfUser =  dictionary["nameOfUser"] as? String,
              let user = dictionary["user"] as? DocumentReference else {return nil}
        self.init(nameOfUser: nameOfUser, review: review, point: point, user: user)
    }
}

