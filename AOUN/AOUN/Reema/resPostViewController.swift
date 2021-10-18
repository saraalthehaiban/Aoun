//
//  resPostViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit
import FirebaseStorage
import Firebase
import UniformTypeIdentifiers

protocol resPostViewControllerDelegate{
    func resPost(_ vc: resPostViewController, resource: resFile?, added: Bool)
}

class resPostViewController: UIViewController, UIDocumentPickerDelegate {
    
    var delegate: resPostViewControllerDelegate?
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var resTitle: UILabel!
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var resourceV: UITextField!
    @IBOutlet weak var authorV: UITextField!
    @IBOutlet weak var publisherV: UITextField!
    @IBOutlet weak var descV: UITextField!
    
    @IBOutlet weak var fileType: UILabel!
    @IBOutlet weak var msg: UILabel!
    
    var files : [URL]?
    
    @IBAction func attach(_ sender: Any) {
        let attachSheet = UIAlertController(title: nil, message: "File attaching", preferredStyle: .actionSheet)
        
        
        attachSheet.addAction(UIAlertAction(title: "File", style: .default,handler: { (action) in
            let supportedTypes: [UTType] = [UTType.pdf,UTType.zip/*, UTType.word*/]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            self.present(documentPicker, animated: true, completion: nil)
        }))

        
        attachSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(attachSheet, animated: true, completion: nil)
    } //end func attach
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        files = urls
        fileType.text = "A file has been attached."

    } //end func documentPicker
    
    
    @IBAction func submit(_ sender: UIButton) {
        //*****************************************
        if resourceV.text == "" ||  authorV.text == "" || publisherV.text == ""{
                    if resourceV.text == ""{
                        resourceV.attributedPlaceholder = NSAttributedString(string: "*Resource Name",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                     if authorV.text == ""{
                        authorV.attributedPlaceholder = NSAttributedString(string: "*Author Name",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                        
                    }
                     if publisherV.text == ""{
                        publisherV.attributedPlaceholder = NSAttributedString(string: "*Publisher Name",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
            msg.attributedText = NSAttributedString(string: "Please fill in any missing field",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                }
                
                if resourceV.text == "" ||  authorV.text == "" || publisherV.text == ""{
                    return}
        
        
        guard let fs = files, fs.count > 0, let localFile = fs.last, resourceV.text != "",  authorV.text != "", publisherV.text != ""
                else {
            msg.attributedText = NSAttributedString(string: "Please attach file",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    return
                }
                msg.text = ""
        
        
                print("Selected File paths", files, localFile)
                let filename = localFile.lastPathComponent
                
                let uid = Auth.auth().currentUser?.uid ?? ""
                print("uid = ", uid, filename)
                
                let storageRef = Storage.storage().reference()
                // File located on disk
                // Create a reference to the file you want to upload
                let resRef = storageRef.child("Resources/\(uid)/\(filename)")
                
                // Upload the file to the path "images/rivers.jpg"
                let uploadTask = resRef.putFile(from: localFile, metadata: nil) { metadata, error in
                    if let e =  error {
                        print (e)
                        self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                      //  self.msg.text = "File couldn't be uploaded."
                        return
                    }
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                   //     self.msg.text = "File couldn't be uploaded."
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    //let size = metadata.size
                    // You can also access to download URL after upload.
                    resRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        self.createDocument(with : downloadURL)
                    }
                }
                uploadTask.resume()
        
 
    } //end func submit
    
    
    func createDocument(with resURL : URL) {
        let url = resURL.absoluteString
        let db = Firestore.firestore()
        let res = resourceV.text!
        let author = authorV.text!
        let pub = publisherV.text!
        let desc = descV.text ?? ""
        let data = ["ResName": res, "authorName": author, "pubName":pub, "desc":desc, "url":url, "uid":Auth.auth().currentUser?.uid]
        
//        db.collection("Resources").document().setData(["ResName": res, "authorName":author, "pubName":pub, "desc":desc, "url":url])
              
        let resource = resFile(name: res, author: author, publisher: pub, desc: desc, urlString: url)
        
        db.collection("Resources").document().setData(data) { error in
            if let e = error {
                print (e)
                self.delegate?.resPost(self, resource: resource, added: false)
            return
            }
            
            self.delegate?.resPost(self, resource: resource, added: true)
        }
        
        msg.attributedText = NSAttributedString(string: "Resource submitted.",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    } //end func viewDidLoad
    
} //end func resPostViewController
