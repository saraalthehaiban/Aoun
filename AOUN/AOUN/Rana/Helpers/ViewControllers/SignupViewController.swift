//
//  SignupViewController.swift
//  SignupViewController
//
//  Created by Macbook pro on 19/09/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {

    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    
    func setUpElements()
    {
        errorLabel.alpha=0
        
       
        
    }
    

    func validateFields() -> String?
    {
        //check all fields are filled
        if
            firstNameTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines) == ""
                ||
                
                lastNameTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
                ||
                emailTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
                ||  passwordTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        {
            
            return "Please fill in all fields"
        }
        
        //check if the password is secure
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities
            .isPasswordValid(cleanedPassword) == false
        {
            return "Please make sure your passsword is at least 8 characters, contains special character and a number."
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanedEmail) == false {
            return "Wrong email format"
        }
        
        //email validation
        
        return nil
    }
    @IBAction func signUptapped(_ sender: Any) {
       let error = validateFields()
        if error != nil
        {
            
            showError(error!)
            
        }
        else
        {
            //create cleaned ref
            
            let firstName = firstNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let lastName =  lastNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) {( result, err) in
                
                if  err != nil
                
                {
                    
                //there was an error
                    self.showError("Error creating user")
                }
                else
                {
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["FirstName": firstName, "LastName": lastName, "Email": email, "password": password, "uid": result!.user.uid]){(error)
                        in
                        if error != nil{
                            
                            self.showError("Try again please, error saving user's data")
                        }
                        
                        
                        
                    }
                    
                    //created
                    // to home screen
                    
                    
                    self.transitionToHome()
                    
                }
                
            }
        }
        
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
        
    }
        
  func transitionToHome()
    
    {
        let  homeViewController = storyboard?.instantiateViewController(identifier:Constants.Storyboard.homeViewController) as?HomeViewController
        
        
        
                                                                        
        view.window?.rootViewController = homeViewController
        
        view.window?.makeKeyAndVisible()
    }
    
}
