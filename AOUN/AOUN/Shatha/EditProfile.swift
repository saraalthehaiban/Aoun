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

class VCEditProfile : UIViewController {
    var delegate : VCEditProfileDelegate?
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var user : User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if  firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "*First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            
            error = "please fill in first name"
        }
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "*Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            error = "please fill in last name"
        }
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    { error = "please fill in all missing fields"
        }
        if error == " "
        {
            return nil }
        else{ return error}
        
    }
    
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
}
