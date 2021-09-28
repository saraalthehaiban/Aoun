//
//  CommunityDetailsViewController.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 27/09/2021.
//

import UIKit
import Firebase
class CommunityDetailsViewController: UIViewController {
  

    let db = Firestore.firestore()
    var TitleName = ""
    @IBOutlet var name: UILabel!
    @IBOutlet var info: UILabel!
    var desc = ""
    var doc = ""
    @IBAction func accept(_ sender: UIButton) {
        db.collection("Communities").document().setData(["Title" : TitleName, "Description" : desc, "questions": []])
        db.collection("Request").document(doc).delete()
    }
    @IBAction func reject(_ sender: UIButton) {
        db.collection("Request").document(doc).delete()
    }
    override func viewDidLoad() {
        name.text = TitleName
        info.text = desc
           
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
