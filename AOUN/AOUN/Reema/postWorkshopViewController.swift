//
//  postWorkshopViewController.swift
//  AOUN
//
//  Created by Reema Turki on 26/03/1443 AH.
//

import UIKit
import FirebaseStorage
import Firebase
import UniformTypeIdentifiers

protocol postWorkshopViewControllerDelegate{
    func postWorkshop(_ vc: postWorkshopViewController,/* resource: resFile?,*/ added: Bool)
}

class postWorkshopViewController: UIViewController {
    
    var delegate: postWorkshopViewControllerDelegate?
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var presenter: UITextField!
    @IBOutlet weak var priceTextbox: UITextField!
    @IBOutlet weak var seat: UITextField!
    @IBOutlet weak var descV: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var msg: UILabel!
        
    
    
    @IBAction func submit(_ sender: UIButton) {
        
        if title.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || priceTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || seat.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || descV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description" /* || date*/ {
                     if title.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                        title.attributedPlaceholder = NSAttributedString(string: "*Title",

                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                     }
                      if presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                        presenter.attributedPlaceholder = NSAttributedString(string: "*Presenter Name",

                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                     }
            if priceTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                priceTextbox.attributedPlaceholder = NSAttributedString(string: "*Price",

                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
           }
            if seat.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                seat.attributedPlaceholder = NSAttributedString(string: "*Number of Seats",

                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
           }
            if descV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description"{
                descV.attributedPlaceholder = NSAttributedString(string: "*Description",

                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
           }
                 }
        
         if title.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             msg.attributedText = NSAttributedString(string: "Please fill in the Title.",

                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

         }else if presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
             msg.attributedText = NSAttributedString(string: "Please fill in Presenter Name.",

                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

         }else if priceTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            msg.attributedText = NSAttributedString(string: "Please fill in the price.",

                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

        }else if seat.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            msg.attributedText = NSAttributedString(string: "Please fill in Number of Seats.",

                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

        }else if descV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description"{
            msg.attributedText = NSAttributedString(string: "Please fill in the Description.",

                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

        }
        
        if title.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&  presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && priceTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && seat.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && descV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description" /* && date*/ {
            msg.attributedText = NSAttributedString(string: "Please fill in all missing fields.",

                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if title.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||  presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || priceTextbox.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || seat.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || descV.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "*Description" /* || date*/ {
            return}
        
        let editedTitle = title.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedPresenter = presenter.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let editedDesc =  descV.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if editedTitle!.count < 4{
            msg.attributedText = NSAttributedString(string: "Title must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedPresenter!.count < 4{
            msg.attributedText = NSAttributedString(string: "Presenter Name must be more than 3 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }else if editedPresenter!.count < 11{
            msg.attributedText = NSAttributedString(string: "Description must be more than 10 characters.",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }
        
//        guard let fs = files, fs.count > 0, let localFile = fs.last, resourceV.text != "",  authorV.text != "", publisherV.text != ""
//        else {
//            msg.attributedText = NSAttributedString(string: "Please attach file",
//                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//            return
//        }
        
        msg.text = ""
        
        
//        print("Selected file paths", files, localFile)
//        let filename = localFile.lastPathComponent
        
//        let uid = Auth.auth().currentUser?.uid ?? ""
//        print("uid = ", uid, filename)
//
//        let storageWorkshop = Storage.storage().reference()
        //let resRef = storageRef.child("Resources/\(uid)/\(filename)")
//        let workshopRef = storageRef.child("Workshop/\(uid)")
//
//        let ut = resRef.putData(documentFileData, metadata: nil) { metaData, error in
//            if let e =  error {
//                print (e)
//                self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
//                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//                return
//            }
//            guard let metadata = metaData else {
//                self.msg.attributedText = NSAttributedString(string: "File couldn't be uploaded.",
//                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
//                return
//            }
//            resRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    //an error occurred!
//                    return
//                }
//                self.createDocument(with : downloadURL)
//            }
//        }
        self.createDocument()
        ut.resume()
    } //end func submit
    
    
    func createDocument() {
        let db = Firestore.firestore()
        let title = resourceV.text!
        let presenter = authorV.text!
        let desc = descV.text
        
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
   
    
    // how?
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceTextbox  || textField == seat{
            if let t = textField.text, t.count > 4 {return false}
            
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
//        else if textField == noteTitleTextbox {
//            if let t = textField.text, t.count > 24 {return false}
//        } else if textField == noteTitleTextbox {
//            if let t = textField.text, t.count > 24 {return false}
//        }
        return true
    }
    
    func textView
    (_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 191    // 190 Limit Value
    }
    
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
                if descriptionTextbox.textColor == #colorLiteral(red: 0.7685510516, green: 0.7686815858, blue: 0.7814407945, alpha: 1) || descriptionTextbox.textColor == UIColor.red{
                    descriptionTextbox.text = nil
                    descriptionTextbox.textColor = UIColor.black
                }
            }
    
    //[3] Placeholder
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if descV.text.isEmpty {
//            descV.text = "Description"
//            descV.textColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
//        }
//    }
    
} //end func resPostViewController
