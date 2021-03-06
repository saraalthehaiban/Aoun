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

//merge again...
protocol PostNoteViewControllerDelegate  {
    func postNote (_ vc: PostNoteViewController, note:NoteFile?, added:Bool)
}

class PostNoteViewController: UIViewController, UIDocumentPickerDelegate, UITextFieldDelegate, UITextViewDelegate {
    var delegate : PostNoteViewControllerDelegate?
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var postNotePageTitle: UILabel!
    @IBOutlet weak var noteTitleTextbox: UITextField!
    @IBOutlet weak var autherTextbox: UITextField!
    @IBOutlet weak var descriptionTextbox: RPTTextView!
    @IBOutlet weak var priceTextbox: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var priceSwitch: UISwitch!
    @IBOutlet weak var fileMsg: UILabel!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var flag : DarwinBoolean = false
    
    
    var files : [URL]?
    
    
    @IBAction func importButton(_ sender: Any) {
        
        let attachSheet = UIAlertController(title: nil, message: "File attaching", preferredStyle: .actionSheet)
        
        //UIImagePickerController
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        priceTextbox.delegate = self
    }
    
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
            print("Error loading file", error)
        }
        files = urls
        //        let strUrl = "\(urls)"
        //
        //               let range = strUrl.lastIndex(of: "/")!
        //
        //               let name = strUrl[strUrl.index(after: range)...]
        //
        //               let newString = name.replacingOccurrences(of: "%20", with: " ")
        //
        //               fileMsg.text = "A file has been attached [\(newString)"
        fileMsg.text = "A file has been attached [\(urls.last?.lastPathComponent ?? "")]"
        
    }
    
    
    @IBAction func submitButton(_ sender: Any) {
        if descriptionTextbox.text.isEmpty{
            //              descriptionTextbox.text = "*Description"
            //            descriptionTextbox.textColor = UIColor.red
            
        }
        
        if noteTitleTextbox.text == "" ||  autherTextbox.text == "" || descriptionTextbox.text == "" {
            if noteTitleTextbox.text == ""{
                noteTitleTextbox.attributedPlaceholder = NSAttributedString(string: "*Note Title",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if autherTextbox.text == ""{
                autherTextbox.attributedPlaceholder = NSAttributedString(string: "*Author Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if descriptionTextbox.text == "" || descriptionTextbox.text == descriptionTextbox.placeHolder {
                descriptionTextbox.placeHolderColor = .red
            }
            if  priceSwitch.isOn {
                if priceTextbox.text == "" {
                    priceTextbox.attributedPlaceholder = NSAttributedString(string: "*Price",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                }
            }
            
        }
        if noteTitleTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             error.text = "Please fill in note title"
         }else if autherTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             error.text = "Please fill in author name"
         }else if descriptionTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description"{
             error.text = "Please fill in the description"
         }
        
        if noteTitleTextbox.text == "" &&  autherTextbox.text == "" && descriptionTextbox.text == "*Description"{
            error.text = "Please fill in all missing fields"
        }
        if noteTitleTextbox.text == "" ||  autherTextbox.text == "" || descriptionTextbox.text == "*Description" {
            return}
        
        if  priceSwitch.isOn && (priceTextbox.text == nil || priceTextbox.text?.count == 0) {
            error.text = "Please fill in the price"
            return
        }
        
        guard let fs = files, fs.count > 0, let localFile = fs.last, noteTitleTextbox.text != "", autherTextbox.text != "" , descriptionTextbox.text != ""
        else {
            error.attributedText = NSAttributedString(string: "Please attach file", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            return
        }
        let editedTitle = noteTitleTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedAuthor = autherTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedDesc =  descriptionTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if editedTitle!.count < 4{
            error.attributedText = NSAttributedString(string: "Note Title must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedAuthor!.count < 4{
            error.attributedText = NSAttributedString(string: "Aurhor Name must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedDesc!.count < 11{
            error.attributedText = NSAttributedString(string: "Description must be more than 10 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }
        error.text = ""
        
        print("Selected File paths", files, localFile)
        let filename = localFile.lastPathComponent
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("uid = ", uid, filename)
        
        let storageRef = Storage.storage().reference()
        let notesRef = storageRef.child("Notes/\(uid)/\(filename)")
        
        let ut = notesRef.putData(documentFileData, metadata: nil) { metadata, error in
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
        
    }
    
    func createDocument(with noteURL : URL) {
        let url = noteURL.absoluteString
        
        let db = Firestore.firestore()
        
        let noteTitle = noteTitleTextbox.text!
        
        let autherName = autherTextbox.text!
        
        let description = descriptionTextbox.text!
        
        let price = priceTextbox.text ?? ""
        let createDate = Timestamp(date: Date())
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let data : [String : Any] = ["noteTitle": noteTitle, "autherName": autherName, "briefDescription": description, "price": price, "url":url, "uid":userId, "createDate":createDate]
        db.collection("Notes").document().setData(data) { error in
            
            if let e = error {
                
                print(e)
                
                self.delegate?.postNote(self, note: nil, added: false)
                
                return
                
            } else {
                
                //Show susccess message and go out
                
                let alert = UIAlertController.init(title: "Posted", message: "Your note posted successfully.", preferredStyle: .alert)
                alert.view.tintColor = .black
                var imageView = UIImageView(frame: CGRect(x: 125, y: 60, width: 20, height: 20))
                imageView.image = UIImage(named: "Check")
                alert.view.addSubview(imageView)
                
                let cancleA = UIAlertAction(title: "Ok", style: .cancel) { action in
                    
                    self.dismiss(animated: true) {
                        
                        //inform main controller t update the information
//                        let note = NoteFile(id:doc.documentID, noteLable: noteTitle, autherName: autherName, desc: description, price: price, urlString: url, docID: "", createDate:createDate, user)
//                        note.userId = userId
                        self.delegate?.postNote(self, note: nil, added: true)
                        
                    }
                    
                }
                
                alert.addAction(cancleA)
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTitleTextbox.delegate = self
        autherTextbox.delegate = self
        
        descriptionTextbox.placeHolderColor = #colorLiteral(red: 0.7685510516, green: 0.7686815858, blue: 0.7814407945, alpha: 1)
        descriptionTextbox.placeHolder = "*Description"
        descriptionTextbox.layer.borderColor =  #colorLiteral(red: 0.7685510516, green: 0.7686815858, blue: 0.7814407945, alpha: 1)
        descriptionTextbox.layer.borderWidth =  1.0; //check in runtime
        descriptionTextbox.layer.cornerRadius = 8;// runtime
        
        
        priceSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        stateChanged(switchState: priceSwitch)
    }
    func textFieldLength(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 20
        
        let currentString: NSString = (textField.text ?? "") as NSString
        
        let newString: NSString =
            
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceTextbox {
            guard let text = textField.text else { return false }
            if text.count == 0 && string == "0" {
                return false
            }
            guard let textRange = Range(range, in:text) else  {
                return true
            }
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.count > 4 {return false}
            
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: updatedText)
            if allowedCharacters.isSuperset(of: characterSet) {
                let value = Decimal(string:updatedText)
                if value == 0 {
                    return false
                }
                return true
            }
            return false
        } else if textField == noteTitleTextbox {
            if let t = textField.text, t.count > 24 {return false}
        } else if textField == noteTitleTextbox {
            if let t = textField.text, t.count > 24 {return false}
        }
        return true
    }
    
    @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            priceTextbox.isHidden = false
            priceTextbox.text = ""
        }else{
            priceTextbox.isHidden = true
        }
    }
}

extension UTType {
    //Word documents are not an existing property on UTType
    static var word: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}

