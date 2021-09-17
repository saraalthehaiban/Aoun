//
//  ViewController.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/09/2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet var Name: UITextField!
    @IBOutlet var Info: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func submit(_ sender: Any) {
        let db = Firestore.firestore()
                let n = Name.text
                let d = Info.text
                db.collection("Request").document().setData(["Title": n, "Description":d, "Status":"Pending"])
    }
    
}

