//
//  resViewViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit

class resViewViewController: UIViewController {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var resourceL: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcome2.text = "Sara!"
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

}
