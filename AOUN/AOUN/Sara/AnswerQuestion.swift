//
//  AnswerQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 26/10/2021.
//

import UIKit
import Firebase


protocol AnswerQuestionDelegate {
    func update(ans : String)
}

class AnswerQuestion: UIViewController, UITextViewDelegate {
    @IBOutlet var descError: UILabel!
    var delegate: AnswerQuestionDelegate?
    var flag : DarwinBoolean = false
    var ID : String = ""
    var ans : String = ""
    @IBOutlet var desc: RPTTextView!
    var db = Firestore.firestore()
    @IBOutlet var body: UILabel!
    var bd: String = ""
    var answers: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        body.text = bd
        self.desc.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
        self.desc.layer.borderWidth = 1
        self.desc.placeHolder = "*Description"
        self.desc.layer.cornerRadius = 8;// runtime
    }
    
    func validatedData () -> [String:Any]? {
        self.descError.text = nil
        var message : String = ""
        ans = desc.text
        answers.append(ans)
        var dataDictionary : [String:Any] = ["answers" : answers]
        
        if let description = desc.text, description != "*Description", description.count != 0 /*,description != descriptionTextView.placeHolder*/ {
            dataDictionary["answers"] = answers
        }else{
            desc.placeHolderColor = .red
            message += "Please fill in description"//TODO: Check and update message
        }
        if message.count > 0 {
            self.descError.text = message
            return nil
        }else if message.count > 26{
            message = "Please enter all required fields"
        }
        
        return dataDictionary
    }
    
    @IBAction func post(_ sender: Any) {
        guard let answersDic = self.validatedData() else {
            return
        }
        
        db.collection("Questions").document(ID).updateData(answersDic)
        delegate?.update(ans: ans)
        //imageView.image =
        CustomAlert.showAlert(
            title: "Answer Posted",
            message: "The member who asked the question will be notified",
            inController: self,
            with: UIImage(named: "Check"),
            cancleTitle: "Ok") {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == desc {
            
        }
        
        return true
        
        /// navigationController?.popViewController(animated: true)
        //  dismiss(animated: true, completion: nil)
        
    }
    
    
    
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if desc.textColor == UIColor.lightGray ||  desc.textColor == UIColor.red{
            if desc.textColor == .red{
                //  print("HERE!")
                flag = true
            }
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
        if flag == true {
            desc.text = "*Description"
            desc.textColor = UIColor.red
            flag = false
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
