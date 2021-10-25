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
    varquestions : [Question]?
    
    init(description:String, title:String) {
        self.description = description
        self.title = title
    }
}

