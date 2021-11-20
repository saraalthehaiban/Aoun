//
//  Answer.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 20/11/2021.
//

import Firebase

struct Answer  {
   
    var answer : String,
        createDate : Timestamp,
        user : String,
        username : String
    var documentID : String?
    var dictionary : [String:Any] {
        get {
            return [
                "answer" : answer,
                "createDate" : createDate,
                "user" : user,
                "username" : username
            ]
        }
    }
}

extension Answer {
    init?(dictionary:[String: Any]) {
        guard let answer  = dictionary["answer"] as? String,
              let createDate  = dictionary["createDate"] as? Timestamp,
              let user  = dictionary["user"] as? String,
              let username  = dictionary["username"] as? String
        else {
            return nil
        }
        
        self.init(answer: answer, createDate: createDate, user: user, username: username)
    }
}

