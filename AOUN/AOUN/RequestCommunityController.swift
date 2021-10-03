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
    @IBOutlet var inputError: UILabel!
    var n : String = ""
    var d : String = ""
    var db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func submit(_ sender: Any) {
        inputError.text = "";
        n = Name.text ?? ""
        d = Info.text ?? ""
        if (n.isEmpty) && (d.isEmpty) {
            inputError.textColor = UIColor.systemRed;
            inputError.text = "Please provide the required fields";
            Name.attributedPlaceholder = NSAttributedString(string: "Title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            Info.attributedPlaceholder = NSAttributedString(string: "Description",attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])

        }
        else{
        if (n.isEmpty) {
            inputError.text = "Please provide the title";
            inputError.textColor = UIColor.systemRed;
            Name.attributedPlaceholder = NSAttributedString(string: "Title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        } else {
            if (d.isEmpty) {
                inputError.textColor = UIColor.systemRed;
                inputError.text = "Please provide the description";
                Info.attributedPlaceholder = NSAttributedString(string: "Description",attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            } else {
                db.collection("Request").document().setData(["Title": n, "Description":d]);
                inputError.textColor = UIColor.systemGreen;
                inputError.text =  "Request sent successfuly";
               // dismiss(animated: true, completion: nil)
                
            }
    }
    
        }
        
    }

}
