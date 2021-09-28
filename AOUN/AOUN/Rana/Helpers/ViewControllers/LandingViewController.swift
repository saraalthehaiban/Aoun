//
//  LandingViewController.swift
//  LandingViewController
//
//  Created by Macbook pro on 19/09/2021.
//

import UIKit

class LandingViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }
    
    func setUpElement()
    {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)

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
