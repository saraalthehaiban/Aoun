//
//  AnswerQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 26/10/2021.
//

import UIKit
import Firebase

class AnswerQuestion: UIViewController, UITextViewDelegate {
    var ID : String = ""
    var ans : String = ""
    @IBOutlet var desc: UITextView!
    var db = Firestore.firestore()
    @IBOutlet var body: UILabel!
    var bd: String = ""
    var answers: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        body.text = bd
        desc.delegate = self
        self.desc.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
//        self.descriptionTextView.rpt
        self.desc.text = "*Description"
        self.desc.textColor = UIColor.lightGray
        self.desc.layer.borderWidth = 1.0; //check in runtime
        self.desc.layer.cornerRadius = 8;// runtime
        // Do any additional setup after loading the view.
    }
    

    @IBAction func post(_ sender: Any) {
        ans = desc.text
        answers.append(ans)
    db.collection("Questions").document(ID).updateData(["answers" : answers])
        print("here")
        print(ID)
        
    }
    
    
    @IBAction func canel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if desc.textColor == UIColor.lightGray {
            desc.text = nil
            desc.textColor = UIColor.black
        }
    }
    
    //[3] Placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if desc.text.isEmpty {
            desc.text = "*Description"
            desc.textColor = UIColor.lightGray
        }
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
