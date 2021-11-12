//
//  ChangePasswordVC.swift
//  AOUN
//
//  Created by shatha on 01/04/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var rePass: UITextField!
    @IBOutlet weak var errorMSG: UILabel!
    @IBAction func changePassword(_ sender: UIButton) {
        errorMSG.text = validatPassword()  //fix the logic
        let password = newPass.text
        var email = ""
        getEmail { [self] (uEmail) in
            email = uEmail
        }
        if (errorMSG.text == nil && password != nil){
            let user = Auth.auth().currentUser
            var credential: AuthCredential
            var credentials = EmailAuthProvider.credential(withEmail: email, password: password!)
            // Prompt the user to re-provide their sign-in credentials

            user?.reauthenticate(with: credentials) { error,arg  in
              if let error = error {
                // An error happened.
              } else {
                Auth.auth().currentUser?.updatePassword(to: password!) { (error) in              }
            }
        }
        }}
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    
    }
    
    func validatPassword() -> String? {
        
        if newPass.text?.trimmingCharacters(in:.whitespacesAndNewlines)=="" {
            //            passwordTextField.textColor = .red
            newPass.attributedPlaceholder = NSAttributedString(string: "*Password",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return "please fill missing fields"
        }
       
        
        
        if rePass.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        {
            rePass.attributedPlaceholder = NSAttributedString(string: "*Confirm Password",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            return "please fill in missing fields"
        }
        
        if(newPass.text != rePass.text)
        {
        return "password doesn't match"
             

        }
        let cleanedPassword = newPass.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false
        {
            return "Please make sure your password is at least 8 characters, contains special character and a number."
        }
        return nil 
    }
    
    func getEmail(completion: @escaping((String) -> ())) {
        let user = Auth.auth().currentUser
        if let user = user {
            let theEmail = user.email ?? ""
            completion(theEmail)
        }
        
    }//end of getEmail
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
