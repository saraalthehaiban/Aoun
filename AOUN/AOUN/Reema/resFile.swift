//
//  resFile.swift
//  AOUN
//
//  Created by Reema Turki on 21/02/1443 AH.
//


import Foundation
struct resFile {
    let name : String
    let author : String
    let publisher : String
    let desc : String
    let urlString : String
    
    var documentId : String?
    var url : URL? {
        get {
            return URL (string: urlString)
        }
    }
}
