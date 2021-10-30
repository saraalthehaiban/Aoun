//
//  EditProfile.swift
//  AOUN
//
//  Created by shatha on 17/03/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase

protocol VCEditProfileDelegate {
    func editView (editVC: VCEditProfile, profile : User, updated:Bool)
}

class VCEditProfile : UIViewController, UITextFieldDelegate {
    var delegate : VCEditProfileDelegate?
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var user : User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        // Do any additional setup after loading the view.
        setUpElements()
        
        
    }
    
    
    func setUpElements() {
        errorLabel.alpha=0
        self.firstNameTextField.text = self.user.FirstName
        self.lastNameTextField.text = self.user.LastName
    }
    
    func validateFields() -> String? {
        // Check that all fields are filled in
        var error = " "
        let cleanedfirst = firstNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
                if Utilities.isValidName(testStr: cleanedfirst) == false {
                    error = "Invalid name format, please use alphabitic characters only and at least 3 characters"
                }
                
                let cleanedlast = lastNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
                if Utilities.isValidName(testStr: cleanedlast) == false {
                    error = "Invalid name format, please use alphabitic characters only and at least 3 characters"
                }
        if  firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "*First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            
            error = "Please fill in first name"
        }
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "*Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            error = "Please fill in last name"
        }
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    { error = "Please fill in all missing fields"
        }
        if error == " "
        {
            return nil }
        else{ return error}
        
    }
    //TODO: fix shatha's errors
    @IBAction func signUptapped(_ sender: Any) {
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
            //create cleaned ref
            let firstName = firstNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let lastName =  lastNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let db = Firestore.firestore()
            guard let userId = Auth.auth().currentUser?.uid else {
                //User is not logged in
                return
            }
            
            let updateData = ["LastName":lastName, "FirstName":firstName]
            db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                if let err = error {
                    //Display Error
                } else {
                    let user = querySnapshot?.documents.first
                    user?.reference.updateData(updateData, completion: { error in
                        if let error = error {
                            //show error messsgae
                        } else {
                            //Show susccess message and go out
//                            self.user.FirstName = firstName
//                            self.user.LastName = lastName
                            self.delegate?.editView(editVC: self, profile: self.user, updated: true)
                            let alert = UIAlertController.init(title: "Updated", message: "Your profile updated successfully", preferredStyle: .alert)
                            alert.view.tintColor = .black
                            var imageView = UIImageView(frame: CGRect(x: 125, y: 60, width: 20, height: 20))

                                    imageView.image = UIImage(named: "Check")

                            alert.view.addSubview(imageView)
                            let cancleA = UIAlertAction(title: "Ok", style: .cancel) { action in
                                self.dismiss(animated: true) {
                                    //inform main controller t update the information
                                }
                            }
                            alert.addAction(cancleA)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                }
            }
            
//            let dr = db.collection("users").document(userId)
//            dr.updateData(updateData) { error in
//                if let error = error {
//                    //show error messsgae
//                } else {
//                    //Show susccess message and go out
//                    let alert = UIAlertController.init(title: "Done!", message: "Profile updated successfully!", preferredStyle: .alert)
//                    let cancleA = UIAlertAction(title: "Ok", style: .cancel) { action in
//                        self.dismiss(animated: true) {
//                            //inform main controller t update the information
//                        }
//                    }
//                    alert.addAction(cancleA)
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
//    func textField1(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let minLength = 3
//        let currentString: NSString = (textField.text ?? "") as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length >= minLength
//    }
}
