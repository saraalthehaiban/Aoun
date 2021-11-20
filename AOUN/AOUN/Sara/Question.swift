//
//  Question.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 15/10/2021.
//

import Foundation
import Firebase
struct Question{
    let documentId : String
    let title: String //title of question
    let body: String //body of question
    let answer: [String] //Array of answers
    var askingUserID:String?
    var createDate : Timestamp
}

  
