//
//  UserHomeViewController.swift
//  AOUN
//
//  Created by shatha on 11/02/1443 AH.
//

import UIKit

class UserHomeViewController: UIViewController {

    @IBOutlet weak var user: UIImageView!
    
    @IBOutlet weak var HelloUser: UILabel!
    @IBOutlet weak var DashboardTitle: UILabel!
    @IBAction func notesButton(_ sender: UIButton) {
    }
    @IBOutlet weak var notesLabel: UILabel!
    @IBAction func workshopsButton(_ sender: UIButton) {
    }
    @IBOutlet weak var workshopsLabel: UILabel!
    @IBAction func resourcesButton(_ sender: UIButton) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let vc = appDelegate.viewController(storyBoardname: "Resources", viewControllerId: "si_resViewViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var resourcesLabel: UILabel!
    @IBAction func communitiesButton(_ sender: UIButton) {
    }
    @IBOutlet weak var CommunitiesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func profileActionTouched(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate
            as? AppDelegate {
            let vc = appDelegate.viewController(storyBoardname: "Profile", viewControllerId: "si_SignoutViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
}
