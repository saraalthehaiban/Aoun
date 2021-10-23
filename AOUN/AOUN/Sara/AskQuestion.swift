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
class AskQuestion: UIViewController, UITextViewDelegate { //[1] Pleaceholder: UITextViewDelegate
    var delegate: AskQuestionDelegate?
    var db = Firestore.firestore()
    @IBOutlet var titleError: UILabel!
    @IBOutlet var descError: UILabel!
    @IBOutlet var Description: UITextView!
    @IBOutlet var titleText: UITextField!
    var ID : String = ""
    var ComName : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        Description.delegate = self
        self.Description.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
        self.Description.text = "Description*"
        self.Description.textColor = UIColor.lightGray
        self.Description.layer.borderWidth = 1.0; //check in runtime
        self.Description.layer.cornerRadius = 8;// runtime
    }
    
    @IBAction func post(_ sender: Any) {
        //GET COM NAME
        //check errors
        let n = titleText.text
        let d = Description.text
        let ans : [String] = []
        db.collection("Questions").document().setData(["Title": n, "Body":d, "ID":ID, "Answers": ans, "Community": ComName]);
        delegate?.add()
        
 //       navigationController?.popViewController(animated: true)
 //      dismiss(animated: true, completion: nil)
        //Added successfully 

    }
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if Description.textColor == UIColor.lightGray {
            Description.text = nil
            Description.textColor = UIColor.black
        }
    }
    //[3] Placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if Description.text.isEmpty {
            Description.text = "Description*"
            Description.textColor = UIColor.lightGray
        }
    }
     @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
     }


}

