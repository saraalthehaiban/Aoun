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
        var password = newPass.text  //fix the logic
//
//        Auth.auth().currentUser?.updatePassword(to: password) { error in
//          // ...
//        }
//        Auth.auth().currentUser?.updatePassword(to: password) { error in
//          // ...
//        }
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        let credential: AuthCredential
        // Prompt the user to re-provide their sign-in credentials

//        user?.reauthenticate(with: credential) { error,arg  in
//            if error != nil {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }
//        // Do any additional setup after loading the view.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
