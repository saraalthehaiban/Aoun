//
//  PostNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit
import UniformTypeIdentifiers
import FirebaseStorage
import Firebase


protocol PostNoteViewControllerDelegate  {
    func postNote (_ vc: PostNoteViewController, note:NoteFile?, added:Bool)
}

class PostNoteViewController: UIViewController, UIDocumentPickerDelegate, UITextFieldDelegate {
    var delegate : PostNoteViewControllerDelegate?
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var postNotePageTitle: UILabel!
    @IBOutlet weak var noteTitleTextbox: UITextField!
    @IBOutlet weak var autherTextbox: UITextField!
    @IBOutlet weak var descriptionTextbox: UITextField!
    @IBOutlet weak var priceTextbox: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var priceSwitch: UISwitch!
    @IBOutlet weak var fileMsg: UILabel!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var files : [URL]?
    
    @IBAction func importButton(_ sender: Any) {
        
        let attachSheet = UIAlertController(title: nil, message: "File attaching", preferredStyle: .actionSheet)
        
        
        attachSheet.addAction(UIAlertAction(title: "File", style: .default,handler: { (action) in
            let supportedTypes: [UTType] = [UTType.pdf,UTType.zip, UTType.word]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            self.present(documentPicker, animated: true, completion: nil)
        }))
        
        
        attachSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(attachSheet, animated: true, completion: nil)
        
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        files = urls
        fileMsg.text = "A file has been attached"

    }
    

    @IBAction func submitButton(_ sender: Any) {
        
        //activityIndicator.startAnimating()
        
        if noteTitleTextbox.text == "" ||  autherTextbox.text == "" || descriptionTextbox.text == "" {
                    if noteTitleTextbox.text == ""{
                        noteTitleTextbox.attributedPlaceholder = NSAttributedString(string: "*Note Title",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                     if autherTextbox.text == ""{
                        autherTextbox.attributedPlaceholder = NSAttributedString(string: "*Author Name",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                     if descriptionTextbox.text == ""{
                        descriptionTextbox.attributedPlaceholder = NSAttributedString(string: "*Description",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                    error.text = "Please fill in any missing field"
                    
                }
                
                if noteTitleTextbox.text == "" ||  autherTextbox.text == "" || descriptionTextbox.text == "" {
                    return}
        
        guard let fs = files, fs.count > 0, let localFile = fs.last, noteTitleTextbox.text != "", autherTextbox.text != "" , descriptionTextbox.text != ""
        else {
            error.attributedText = NSAttributedString(string: "Please attach file", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            return
        }
        error.text = ""
        
        print("Selected File paths", files, localFile)
        let filename = localFile.lastPathComponent
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("uid = ", uid, filename)
        
        let storageRef = Storage.storage().reference()

        let notesRef = storageRef.child("Notes/\(uid)/\(filename)")
        
        let uploadTask = notesRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let e =  error {
                print (e)
                self.error.attributedText = NSAttributedString(string: "File couldn't be uploaded", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
                return
            }
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.error.attributedText = NSAttributedString(string: "File couldn't be uploaded", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
                return
            }
            // Metadata contains file metadata such as size, content-type.
            //let size = metadata.size
            // You can also access to download URL after upload.
            notesRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.createDocument(with : downloadURL)
            }
        }
        uploadTask.resume()
    }
    
    func createDocument(with noteURL : URL) {
        let url = noteURL.absoluteString
        let db = Firestore.firestore()
        let noteTitle = noteTitleTextbox.text!
        let autherName = autherTextbox.text!
        let description = descriptionTextbox.text!
        let price = priceTextbox.text ?? ""
        let data = ["noteTitle": noteTitle, "autherName": autherName, "briefDescription": description, "price": price, "url":url]
        //db.collection("Notes").document().setData(["noteTitle": noteTitle, "autherName": autherName, "briefDescription": description, "price": price, "url":url])
        
        let note = NoteFile(noteLable: noteTitle, autherName: autherName, desc: description, price: price, urlString: url)
        db.collection("Notes").document().setData(data) { error in
            if let e = error {
                print(e)
                self.delegate?.postNote(self, note: note, added: false)
                return
            }
            self.delegate?.postNote(self, note: note, added: true)
        }
        
        //self.activityIndicator.stopAnimating()
        
        error.attributedText = NSAttributedString(string: "Note submitted", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priceTextbox.delegate = self
        
        priceSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        stateChanged(switchState: priceSwitch)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceTextbox {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    

    
    @objc func stateChanged(switchState: UISwitch) {
        priceTextbox.isHidden = !switchState.isOn
    }
}

extension UTType {
    //Word documents are not an existing property on UTType
    static var word: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}

