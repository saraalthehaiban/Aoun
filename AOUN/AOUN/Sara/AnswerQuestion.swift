//
//  AnswerQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 26/10/2021.
//

import UIKit
import Firebase


protocol AnswerQuestionDelegate {
    func answer(_ vc : AnswerQuestion, added:Answer?, successfully:Bool)
}

class AnswerQuestion: UIViewController, UITextViewDelegate {
    @IBOutlet var descError: UILabel!
    var delegate: AnswerQuestionDelegate?
    var flag : DarwinBoolean = false
    var ID : String = ""
    var ans : String = ""
    @IBOutlet var desc: RPTTextView!
    var db = Firestore.firestore()
    @IBOutlet var body: UITextView!
    var bd: String = ""
    var answers: [String] = []
    var question : Question!
    var me : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        body.text = bd
        self.desc.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
        self.desc.layer.borderWidth = 1
        self.desc.layer.cornerRadius = 8;// runtime
        self.desc.placeHolder = "*Description"
        self.desc.placeHolderColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let user = appDelegate.thisUser {
            self.me = user
        }
    }
    
    func validatedData () -> [String:Any]? {
        self.descError.text = nil
        if let description = desc.text, description !=
            desc.placeHolder, description.count != 0 {
            var dataDictionary : [String:Any] = [:]
            dataDictionary["answer"] = desc.text
            dataDictionary["createDate"] = Timestamp(date: Date())
            dataDictionary["user"] = self.me.documentID
            dataDictionary["username"] = self.me.displayName
            return dataDictionary
        }else{
            desc.placeHolderColor = .red
            self.descError.text = "Please add in answer."
            return nil
        }
    }
    
    @IBAction func post(_ sender: Any) {
        guard let answersDictionary = self.validatedData() else {
            return
        }
        
        db.collection("Questions").document(ID).collection("answers").addDocument(data: answersDictionary) { error in
            if let error = error {
                print (error)
                self.delegate?.answer(self, added: Answer(dictionary: answersDictionary), successfully: false)
            }else {
                self.delegate?.answer(self, added: Answer(dictionary: answersDictionary), successfully: true)
                self.triggerNotification()
                CustomAlert.showAlert(
                    title: "Answer Posted",
                    message: "The member who asked the question will be notified",
                    inController: self,
                    with: UIImage(named: "Check"),
                    cancleTitle: "Ok") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func triggerNotification()  {
        guard let askingUserID = question.askingUserID else {
            return
        }
        
        //
        db.collection("users").whereField("uid", isEqualTo: askingUserID).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                guard let user = querySnapshot?.documents.first, let fcmToken = user["fcmToken"] as? String else {
                    return
                }
                PushNotificationSender.sendPushNotification(to: fcmToken, title: "Answer posted", body: "Ansswer posted to your question \(self.question.title)")
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == desc {
            
        }
        
        return true
        
        // navigationController?.popViewController(animated: true)
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
