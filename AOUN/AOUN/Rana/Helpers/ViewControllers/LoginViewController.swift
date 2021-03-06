//
//  LoginViewController.swift
//  LoginViewController
//
//  Created by Macbook pro on 19/09/2021.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginbutton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
    
    
    @IBAction func logintapped(_ sender: Any) {
        let error = validateFields()
        if error != nil
        {
            
            showError(error!)
            
        }
        else
        {
            
            //validate
            
            
            
            // defining
            
            let email = emailTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            
            let password = passwordTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            
            
            //sign in
            Auth.auth().signIn(withEmail: email, password: password)
            {(result, error) in
                
                self.errorLabel.alpha = ((error == nil) ? 0 : 1)
                
                print(result)
                print(error)
                if error != nil
                {
                    //coudn't sign in
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                    
                    
                }
                else{
                    let  homeViewController = self.storyboard?.instantiateViewController(identifier:Constants.Storyboard.homeViewController) as?HomeViewController
                    
                    
                    
                    
                    self.view.window?.rootViewController = homeViewController
                    
                    self.view.window?.makeKeyAndVisible()
                    
                }
                
                
            }
        }
        
        
        
    }
    
    
    func validateFields() -> String?
    {
        //check all fields are filled
        if emailTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
            ||  passwordTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        {
            
            return "please fill in all fields"
        }
        
        //check if the password is secure
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities
            .isPasswordValid(cleanedPassword) == false
        {
            return "Incorrect email or password"
        }
        
        //email validation
        
        return nil
    }
    
    @IBAction func ForgetPasswordTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "forgotPassSegue", sender: nil)
    }
    
}
