//
//  PostNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit

class PostNoteViewController: UIViewController {
    @IBOutlet weak var BG: UIImageView!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcomLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var postNotePageTitle: UILabel!
    @IBOutlet weak var formBG: UIImageView!
    @IBOutlet weak var noteTitleLable: UILabel!
    @IBOutlet weak var noteTitleTextbox: UITextField!
    @IBOutlet weak var aoutherLable: UILabel!
    @IBOutlet weak var aoutherTextbox: UITextField!
    @IBOutlet weak var publisherLable: UILabel!
    @IBOutlet weak var publisherTextbox: UITextField!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var descriptionTextbox: UITextField!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var priceTextbox: UITextField!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
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

}
