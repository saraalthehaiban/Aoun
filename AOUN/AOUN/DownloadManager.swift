//
//  DownloadManager.swift
//  AOUN
//
//  Created by Reema Turki on 23/02/1443 AH.
//


//delete it before merging
import Foundation
import FirebaseStorage

class DownloadManager {
    class func download (url : URL, completion:@escaping (_ success:Bool, _ url:Data?) -> Void) {
        //**********FILES***********
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: 12 * 1024 * 1024) { data, error in
            if let e = error {
                //TODO: Show and alert of error
                print( "Download Error: ", e)
            } else if let d = data {
                
                completion(true, d)
            }
        }
    }
}
