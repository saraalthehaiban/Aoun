//
//  Test_image.swift
//  Test_image
//
//  Created by Macbook pro on 14/11/2021.
//

import Foundation


func uploadImage() {
    let url = URL(string: "YOUR SERVER URL");
    let request = NSMutableURLRequest(url: url!);
    request.httpMethod = "POST"
    let boundary = "Boundary-\(NSUUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var retreivedImage: UIImage? = nil
    //Get image
    do {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let readData = try Data(contentsOf: URL(string: "file://\(documentsPath)/myImage")!)
        retreivedImage = UIImage(data: readData)
        addProfilePicView.setImage(retreivedImage, for: .normal)
    }
    catch {
        print("Error while opening image")
        return
    }

    let imageData = UIImageJPEGRepresentation(retreivedImage!, 1)
    if (imageData == nil) {
        print("UIImageJPEGRepresentation return nil")
        return
    }

    let body = NSMutableData()
    body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
    body.append(NSString(format: "Content-Disposition: form-data; name=\"api_token\"\r\n\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
    body.append(NSString(format: (UserDefaults.standard.string(forKey: "api_token")! as NSString)).data(using: String.Encoding.utf8.rawValue)!)
    body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
    body.append(NSString(format:"Content-Disposition: form-data; name=\"profile_img\"; filename=\"testfromios.jpg\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
    body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
    body.append(imageData!)
    body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)

    request.httpBody = body as Data

    let task =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
        (data, response, error) -> Void in
        if let data = data {
           // do what you want in success case
        } else if let error = error {
            print(error.localizedDescription)
        }
    })

    task.resume()
}
