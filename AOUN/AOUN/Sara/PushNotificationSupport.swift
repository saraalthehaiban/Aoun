//
//  PushNotificationSupport.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 30/10/2021.
//

import UIKit
import Firebase
class PushNotificationSender {
    class func sendPushNotification(to token: String, title: String, body: String, type:String = "answer") {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
//        let thisUserId = FirebaseAuth.au
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id", "type":type]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAhpL55LQ:APA91bG4d2e7skBHWQpALw-x2cqRdNNxMo2KBs1HdYLIDHvC-95LFbFrZFaZto2s8iBoiylkUs5wC6lVi91pcj7UZqRUnEKziyEEtwgUy3thNp-q7H_xXQYMzTc9joWjXLs52_ZDmIz7", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
