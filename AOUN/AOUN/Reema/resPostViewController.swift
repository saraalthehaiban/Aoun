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

class resPostViewController: UIViewController, UIDocumentPickerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var delegate: resPostViewControllerDelegate?
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var resTitle: UILabel!
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var resourceV: UITextField!
    @IBOutlet weak var authorV: UITextField!
    @IBOutlet weak var publisherV: UITextField!
    // @IBOutlet weak var descV: UITextField!
    @IBOutlet weak var descV: UITextView!
    
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
    
    var documentFileData : Data!
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .open, let url = urls.last, url.startAccessingSecurityScopedResource() else {return}
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let document = try Data(contentsOf: url.absoluteURL)
            documentFileData = document
        } catch {
            print("Error loadin file", error)
        }
        
        files = urls
        //        let strUrl = "\(urls)"
        //        let range = strUrl.lastIndex(of: "/")!
        //        let name = strUrl[strUrl.index(after: range)...]
        //        let newString = name.replacingOccurrences(of: "%20", with: " ")
        fileType.text = "A file has been attached [\(urls.last?.lastPathComponent ?? "")]"
    } //end func documentPicker
    
    
    @IBAction func submit(_ sender: UIButton) {
        //*****************************************
   
        if resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

                     if resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

                         resourceV.attributedPlaceholder = NSAttributedString(string: "*Resource Name",

                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                     }

                      if authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

                         authorV.attributedPlaceholder = NSAttributedString(string: "*Author Name",

                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                         

                     }

                      if publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

                         publisherV.attributedPlaceholder = NSAttributedString(string: "*Publisher Name",

                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                     }

                 }

         

         if resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

             msg.attributedText = NSAttributedString(string: "Please fill in resource name.",

                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

         }else if authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

             msg.attributedText = NSAttributedString(string: "Please fill in author name.",

                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

         } else if publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{

             msg.attributedText = NSAttributedString(string: "Please fill in publisher name.",

                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

         }
        if resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&  authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            msg.attributedText = NSAttributedString(string: "Please fill in all missing fields.",

                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return}
        
        let editedRes =  resourceV.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedAuth =  authorV.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedPub =  publisherV.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if editedRes!.count < 4{
            msg.attributedText = NSAttributedString(string: "Resource name must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedAuth!.count < 4{
            msg.attributedText = NSAttributedString(string: "Author name must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedPub!.count < 4{
            msg.attributedText = NSAttributedString(string: "Publisher name must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }
        
        
        guard let fs = files, fs.count > 0, let localFile = fs.last, resourceV.text != "",  authorV.text != "", publisherV.text != ""
        else {
            msg.attributedText = NSAttributedString(string: "Please attach file",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }
        msg.text = ""
        
        
        print("Selected file paths", files, localFile)
        let filename = localFile.lastPathComponent
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("uid = ", uid, filename)
        
        let storageRef = Storage.storage().reference()
        // File located on disk
        // Create a reference to the file you want to upload
        let resRef = storageRef.child("Resources/\(uid)/\(filename)")
        
        // Upload the file to the path "images/rivers.jpg"
        //        var filePath = localFile.absoluteString
        //        filePath = filePath.replacingOccurrences(of: "file:/", with: "")//making url to file path
        //        let u = URL(string: filePath)
        
        /* FIRStorageErrorDomain Code=-13000 "File at URL: file:///private/var/mobile/Library/Mobile%20Documents/com~apple~CloudDocs/Desktop/Level%20VII/SWE%20%5BHWs%20+%20Quizzes%5D%20Level%207%20-%202021/SWE%20434/HW1.pdf is not reachable. Ensure file URL is not a directory, symbolic link, or invalid url." UserInfo={NSLocalizedDescription=File at URL: file:///private/var/mobile/Library/Mobile%20Documents/com~apple~CloudDocs/Desktop/Level%20VII/SWE%20%5BHWs%20+%20Quizzes%5D%20Level%207%20-%202021/SWE%20434/HW1.pdf is not reachable. Ensure file URL is not a directory, symbolic link, or invalid url., NSUnderlyingError=0x2827a5830 {Error Domain=NSCocoaErrorDomain Code=257 "The file “HW1.pdf” couldn’t be opened because you don’t have permission to view it."*/
        let ut = resRef.putData(documentFileData, metadata: nil) { metaData, error in
            if let e =  error {
                print (e)
                self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                //  self.msg.text = "File couldn't be uploaded."
                return
            }
            guard let metadata = metaData else {
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
        ut.resume()
        
//        let uploadTask = resRef.putFile(from: localFile, metadata: nil) { metadata, error in
//            if let e =  error {
//                print (e)
//                self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
//                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//                //  self.msg.text = "File couldn't be uploaded."
//                return
//            }
//            guard let metadata = metadata else {
//                // Uh-oh, an error occurred!
//                self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
//                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//                //     self.msg.text = "File couldn't be uploaded."
//                return
//            }
//            // Metadata contains file metadata such as size, content-type.
//            //let size = metadata.size
//            // You can also access to download URL after upload.
//            resRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//                self.createDocument(with : downloadURL)
//            }
//        }
//        uploadTask.resume()
        
        
    } //end func submit
    
    
    func createDocument(with resURL : URL) {
        let url = resURL.absoluteString
        let db = Firestore.firestore()
        let res = resourceV.text!
        let author = authorV.text!
        let pub = publisherV.text!
        let desc = descV.text ?? ""
        let data = ["ResName": res, "authorName": author, "pubName":pub, "desc":desc, "url":url, "uid":Auth.auth().currentUser?.uid]
        let resource = resFile(name: res, author: author, publisher: pub, desc: desc, urlString: url)
        
        db.collection("Resources").document().setData(data) { error in
            if let e = error {
                print (e)
                self.delegate?.resPost(self, resource: resource, added: false)
                return
            } else {
                //Show susccess message and go out
                let alert = UIAlertController.init(title: "Posted", message: "Your resource posted successfully.", preferredStyle: .alert)
                alert.view.tintColor = .black
                var imageView = UIImageView(frame: CGRect(x: 125, y: 60, width: 20, height: 20))
                imageView.image = UIImage(named: "Check")
                alert.view.addSubview(imageView)
                let cancleA = UIAlertAction(title: "Ok", style: .cancel) { action in
                    self.dismiss(animated: true) {
                        //inform main controller t update the information
                        self.delegate?.resPost(self, resource: resource, added: true)
                    }
                }
                alert.addAction(cancleA)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resourceV.delegate = self
        authorV.delegate = self
        publisherV.delegate = self
        descV.delegate = self
        descV.layer.borderColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
        descV.text = "Description"
        descV.textColor = #colorLiteral(red: 0.7685510516, green: 0.7686815858, blue: 0.7814407945, alpha: 1)
        descV.layer.borderWidth = 1.0; //check in runtime
        descV.layer.cornerRadius = 8;// runtime
    } //end func viewDidLoad
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    func textView
    (_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        let numberOfChars = newText.count

        return numberOfChars < 191    // 190 Limit Value

    }
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        //if descV.textColor == #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1){
               descV.text = nil
                    descV.textColor = UIColor.black
      //  }
    }
    //
    //[3] Placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if descV.text.isEmpty {
            descV.text = "Description"
            descV.textColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
        }
    }
} //end func resPostViewController
