//
//  Community.swift
//  Community
//
//  Created by Macbook pro on 19/10/2021.
//

import Foundation

class CommunityObject {
    var description : String = ""
    var title  : String = ""
    var questions : [Question]?
    var ID : String = ""
    
    init(description:String, title:String, ID: String) {
        self.description = description
        self.title = title
        self.ID = ID
    }
}

