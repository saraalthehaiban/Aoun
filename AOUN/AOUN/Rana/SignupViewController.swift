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
    
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if  firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
                lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" &&
                emailTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)=="" &&
                passwordTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        
        
        
        {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "*First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "*Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            emailTextField.attributedPlaceholder = NSAttributedString(string: "*Email",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "*Password",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            return "please fill in missing fields"
        }
        
        
        
        if firstNameTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        {
            firstNameTextField.attributedPlaceholder = NSAttributedString(string: "*First Name",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            return "please fill in missing fields"
        }
        
        if lastNameTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)==""
        {
            lastNameTextField.attributedPlaceholder = NSAttributedString(string: "*Last Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            
            return "please fill in missing fields"
        }
        
        
        
        if emailTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)=="" {
            //.textColor = .red
            emailTextField.attributedPlaceholder = NSAttributedString(string: "*Email",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            //            emailTextField.borderColor = .red
            //            emailTextField.borderWidth = 0.5
            //            emailTextField.cornerRadius = 8
            return "Please fill in missing fields"
            
        }
        if passwordTextField.text?.trimmingCharacters(in:.whitespacesAndNewlines)=="" {
            //            passwordTextField.textColor = .red
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "*Password",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return "please fill missing fields"
        }
        
        
        
        //check if the password is secure
        
        let cleanedfirst = firstNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
                if Utilities.isValidName(testStr: cleanedfirst) == false {
                    return "Invalid name format, please use alphabitic characters only"
                }
                
                let cleanedlast = lastNameTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
                if Utilities.isValidName(testStr: cleanedlast) == false {
                    return "Invalid name format, please use alphabitic characters only"
                }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanedEmail) == false {
            return "Invalid email format, please follow xxx@domain.com"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false
        {
            return "Please make sure your password is at least 8 characters, contains special character and a number."
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
            //create user
            Auth.auth().createUser(withEmail: email, password: password) {( result, err) in
                
                if  err != nil
                
                {
                    
                    
                    //there was an error
                    self.showError("User already exists")
                }
                else
                {
                    let db = Firestore.firestore()
                                        db.collection("users").addDocument(data: ["FirstName": firstName, "LastName": lastName, "uid": result!.user.uid]){(error)
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
    
    
    
    func transitionToHome() {
//        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
//
//        view.window?.rootViewController = homeViewController
//        view.window?.makeKeyAndVisible()
        let appD = UIApplication.shared.delegate as! AppDelegate
        appD.setRoot()
//
    }
    
}
