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

class resPostViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet weak var smallBackground: UIImageView!

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rIcon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    
    @IBOutlet weak var postL: UILabel!
    
    @IBOutlet weak var resourceL: UILabel!
    @IBOutlet weak var autherL: UILabel!
    @IBOutlet weak var publisherL: UILabel!
    @IBOutlet weak var resourceV: UITextField!
    @IBOutlet weak var autherV: UITextField!
    @IBOutlet weak var publisherV: UITextField!
    
    
    @IBOutlet weak var linkL: UILabel!
    @IBOutlet weak var linkV: UITextField!

    
    @IBOutlet weak var error: UILabel!
    
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
         } //end func documentPicker
    
    
    @IBAction func submit(_ sender: UIButton) {
        
        guard let fs = files, fs.count > 0, let localFile = fs.last, resourceV.text != "" && autherV.text != "" && publisherV.text != ""
                else {
                    error.text = "Missing field!!"
                    return
                }
        
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
                        self.error.text = "File couldn't be uploaded!!"
                        return
                    }
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        self.error.text = "File couldn't be uploaded!!"
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
        
        
//
//        if resourceV.text != "" && autherV.text != "" && publisherV.text != "" && (linkV.text != "") /* || file != "" */  {
//            let db = Firestore.firestore()
//                            let  res = resourceV.text
//                            let auther = autherV.text
//                            let pub = publisherV.text
//                            let link = linkV.text
//

//                  db.collection("Resources").document().setData(["ResName": res, "autherName":auther, "pubName":pub, "link":link, ])
            
//        }
//         else {
//            error.text = "Missing field!!"
//         }
            
      
              
    } //end func submit
    
    func createDocument(with resURL : URL) {
            let url = resURL.absoluteString
            let db = Firestore.firestore()
            let  res = resourceV.text
            let auther = autherV.text
            let pub = publisherV.text
            let link = linkV.text
            
        db.collection("Resources").document().setData(["ResName": res, "autherName":auther, "pubName":pub, "link":link, "url":url])

        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcome2.text = "Sara!"
       
        // Do any additional setup after loading the view.
    } //end func viewDidLoad
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
} //end func resPostViewController

/*
extension UTType {
   // Word documents are not an existing property on UTType
    static var word: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}
*/
