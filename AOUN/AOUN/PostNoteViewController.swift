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

class PostNoteViewController: UIViewController, UIDocumentPickerDelegate, UITextFieldDelegate, UITextViewDelegate {
    var delegate : PostNoteViewControllerDelegate?
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var postNotePageTitle: UILabel!
    @IBOutlet weak var noteTitleTextbox: UITextField!
    @IBOutlet weak var autherTextbox: UITextField!
    @IBOutlet weak var descriptionTextbox: UITextView!
    @IBOutlet weak var priceTextbox: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var priceSwitch: UISwitch!
    @IBOutlet weak var fileMsg: UILabel!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var flag : DarwinBoolean = false

    
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
        let strUrl = "\(urls)"
        let range = strUrl.lastIndex(of: "/")!
        let name = strUrl[strUrl.index(after: range)...]
        let newString = name.replacingOccurrences(of: "%20", with: " ")
        fileMsg.text = "A file has been attached [\(newString)"

    }
    

    @IBAction func submitButton(_ sender: Any) {
        
        //activityIndicator.startAnimating()
        
        if noteTitleTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  autherTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || descriptionTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    if noteTitleTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                        noteTitleTextbox.attributedPlaceholder = NSAttributedString(string: "*Note Title",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
                     if autherTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                        autherTextbox.attributedPlaceholder = NSAttributedString(string: "*Author Name",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                    }
//                     if descriptionTextbox.text == ""{
//                        descriptionTextbox.attributedPlaceholder = NSAttributedString(string: "*Description",
//                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//                    }
                    error.text = "Please fill in any missing field"
                    
                }
                
                if noteTitleTextbox.text == "" ||  autherTextbox.text == "" || descriptionTextbox.text == "" {
                    return}
        
        let editedNote =  noteTitleTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedAuth =  autherTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editeddesc =  descriptionTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                if editedNote!.count < 4{
                    error.text = "Note name must be more than 3 characters."
                    return
                }else if editedAuth!.count < 4{
                    error.text = "Author name must be more than 3 characters."
                    return
                }else if editeddesc!.count < 4{
                    error.text = "Description must be more than 3 characters."
                    return
        }
        
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
        let data = ["noteTitle": noteTitle, "autherName": autherName, "briefDescription": description, "price": price, "url":url, "uid":Auth.auth().currentUser?.uid]
        let note = NoteFile(noteLable: noteTitle, autherName: autherName, desc: description, price: price, urlString: url)
        db.collection("Notes").document().setData(data) { error in
            if let e = error {
                print(e)
                self.delegate?.postNote(self, note: note, added: false)
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
                                            self.delegate?.postNote(self, note: note, added: true)
                                        }
                                    }
                                    alert.addAction(cancleA)
                                    self.present(alert, animated: true, completion: nil)
            }
        }
        
        //self.activityIndicator.stopAnimating()
        
//        error.attributedText = NSAttributedString(string: "Note submitted", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTitleTextbox.delegate = self
        autherTextbox.delegate = self
        descriptionTextbox.delegate = self
               self.descriptionTextbox.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
               self.descriptionTextbox.text = "*Description"
               self.descriptionTextbox.textColor = UIColor.lightGray
               self.descriptionTextbox.layer.borderWidth = 1.0; //check in runtime
               self.descriptionTextbox.layer.cornerRadius = 8;// runtime
        priceTextbox.delegate = self
        
        priceSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        stateChanged(switchState: priceSwitch)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 20
//        let currentString: NSString = (textField.text ?? "") as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }

    
    //[2] placeholder
        func textViewDidBeginEditing(_ textView: UITextView) {
            if descriptionTextbox.textColor == UIColor.lightGray ||  descriptionTextbox.textColor == UIColor.red{
                if descriptionTextbox.textColor == .red{
                    flag = true
                }
                
                descriptionTextbox.text = nil
                descriptionTextbox.textColor = UIColor.black
            }
        }

        //[3] Placeholder
        func textViewDidEndEditing(_ textView: UITextView) {
            if descriptionTextbox.text.isEmpty, descriptionTextbox.textColor != .red {
                descriptionTextbox.text = "*Description"
                descriptionTextbox.textColor = UIColor.lightGray
            }

            if flag == true {
                print("Here")
                descriptionTextbox.text = "*Description"
                descriptionTextbox.textColor = UIColor.red
                flag = false
            }
        }
    
    
    
    
    
    func textFieldPrice(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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

