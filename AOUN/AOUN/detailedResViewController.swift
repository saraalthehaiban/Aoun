//
//  detailedResViewController.swift
//  AOUN
//
//  Created by Reema Turki on 21/02/1443 AH.
//

import UIKit

class detailedResViewController: UIViewController {

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var book: UIImageView!
    
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var authL: UILabel!
    @IBOutlet weak var pubL: UILabel!
    @IBOutlet weak var linkL: UILabel!

    
    
    var resV = ""
    var authV = ""
    var pubV = ""
    var linkV = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        resL.text = resV
        authL.text = authV
        pubL.text = pubV
        linkL.text = linkV
        //**********FILES***********

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
