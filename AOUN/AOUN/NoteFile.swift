//
//  noteFile.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import Foundation

struct NoteFile {
    let noteLable : String
    let autherName : String
    let desc : String
    let price : String?
    let urlString : String
    var documentId : String?
    
    var url : URL? {
        get {
            return URL (string: urlString)
        }
    }
}
