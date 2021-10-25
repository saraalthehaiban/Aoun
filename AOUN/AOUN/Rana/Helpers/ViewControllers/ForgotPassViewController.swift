//
//  ForgotPassViewController.swift
//  ForgotPassViewController
//
//  Created by Macbook pro on 30/09/2021.
//

import UIKit
import Firebase
class ForgotPassViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func ForgetPasswordTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "forgotPassSegue", sender: nil)
    
    }
    
}
