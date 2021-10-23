//
//  EditProfile.swift
//  AOUN
//
//  Created by shatha on 17/03/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase


class VCEditProfile : UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    
    func setUpElements() {
        errorLabel.alpha=0
    }
    
    func validateFields() -> String? {
        // Check that all fields are filled in
        if  firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
                lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "*First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "*Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return "please fill in missing fields"
        }
        return nil
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
            let dr = db.collection("users").document(userId)
            let updateData = ["LastName":lastName, "FirstName":firstName]
            
            //let ref = FIRD
            
            //let ref : DatabaseReference!
            
            
            dr.setData(updateData, merge: true) { error in
                if let error = error {
                    //show error messsgae
                } else {
                    //Show susccess message and go out
                    let alert = UIAlertController.init(title: "Done!", message: "Profile updated successfully!", preferredStyle: .alert)
                    let cancleA = UIAlertAction(title: "Ok", style: .cancel) { action in
                        self.dismiss(animated: true) {
                            //inform main controller t update the information
                        }
                    }
                    alert.addAction(cancleA)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}
