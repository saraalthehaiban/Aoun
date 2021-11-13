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
}
