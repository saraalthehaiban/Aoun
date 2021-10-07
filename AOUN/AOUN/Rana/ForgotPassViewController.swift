//
//  ForgotPassViewController.swift
//  ForgotPassViewController
//
//  Created by Macbook pro on 03/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPassViewController: UIViewController {
    @IBOutlet weak var emailtextfield: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
    
   
    
       
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func submit_tapped(_ sender: Any) {
    
        
       
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: emailtextfield.text!){(error)
            
        in
            self.errorLabel.alpha = ((error == nil) ? 0 : 1)
                                                                                
                  
              print(error)
             if error != nil
            {
                
            //coudn't sign in
        self.errorLabel.text = error!.localizedDescription
        self.errorLabel.alpha = 1
                 
                 if self.emailtextfield.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
                 {
                     self.emailtextfield.attributedPlaceholder = NSAttributedString(string: "Email",
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

                     
                     
                 }
                                                                                    
        }
            else
            {
                
                self.errorLabel.textColor = UIColor.blue
                self.errorLabel.text = "an email has been sent to you"
                self.errorLabel.alpha = 1
            }
            
        }
    }
    
    
}
