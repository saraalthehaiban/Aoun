//
//  SignoutViewController.swift
//  SignoutViewController
//
//  Created by Macbook pro on 04/10/2021.
//

import UIKit
import Firebase

class SignoutViewController: UIViewController {
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func signout_tapped(_ sender: Any) {
        let auth = Auth.auth()
        
        do
        {
            try auth.signOut()
            //TODO: Set RootView
            let appD = UIApplication.shared.delegate as! AppDelegate
            appD.setRoot()
        }
        catch let signoutError {
            self.errorLabel.alpha = ((signoutError == nil) ? 0 : 1)
            print(signoutError)
            if signoutError != nil {
                //coudn't sign in
                self.errorLabel.text = signoutError.localizedDescription
                self.errorLabel.alpha = 1
            }
        }
    }
}
