//
//  AskQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit
import Firebase

protocol AskQuestionDelegate{
    func add()
}
class AskQuestion: UIViewController {
    var delegate: AskQuestionDelegate?
    var db = Firestore.firestore()
    @IBOutlet var titleError: UILabel!
    @IBOutlet var descError: UILabel!
    @IBOutlet var Description: UITextView!
    @IBOutlet var titleText: UITextField!
    var ID : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Description.layer.borderColor = UIColor .gray.cgColor;
        self.Description.layer.borderWidth = 1.0; //check in runtime
        self.Description.layer.cornerRadius = 8;// runtime
        
        
        
    }
    
    @IBAction func post(_ sender: Any) {
        //check errors
        let n = titleText.text
        let d = Description.text
        let ans : [String] = []
        db.collection("Question").document().setData(["Title": n, "Body":d, "ID":ID, "Answers": ans]);
        delegate?.add()
        //Added successfully 

    }
    
    
     @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
     }


}

