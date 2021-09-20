//
//  ViewController.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/09/2021.
//

import UIKit
import Firebase

class RequestCommunityController: UIViewController {

    @IBOutlet var Name: UITextField!
    @IBOutlet var Info: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func submit(_ sender: Any) {
        let db = Firestore.firestore()
                let n = Name.text
                let d = Info.text
                db.collection("Request").document().setData(["Title": n, "Description":d, "Status":"Pending"])
    }
    
}

