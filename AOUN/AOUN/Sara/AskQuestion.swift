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
    func after(sendBack : String)
}
class AskQuestion: UIViewController, UITextViewDelegate { //[1] Pleaceholder: UITextViewDelegate
    var delegate: AskQuestionDelegate?
    var db = Firestore.firestore()
    var flag : DarwinBoolean = false
    var present = false
    var userID: String = ""
    @IBOutlet var descError: UILabel!
    @IBOutlet var descriptionTextView: RPTTextView!
    @IBOutlet var titleText: UITextField!
    var sendBack : String = ""
    var ID : String = ""
    var ComName : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionTextView.placeHolder = "*Please enter question description"
        self.descriptionTextView.placeHolderColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
        self.descriptionTextView.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
        self.descriptionTextView.layer.borderWidth = 1.0; //check in runtime
        self.descriptionTextView.layer.cornerRadius = 8;// runtime
    }
    
    func validatedData () -> [String:Any]? {
        self.descError.text = nil
        var dataDictionary : [String:Any] = ["ID":ID, "answers": [], "Community": ComName, "User": Auth.auth().currentUser?.uid]
        
        if let title = titleText.text, title.count > 1 {
            dataDictionary["Title"] = title
        }else{
            titleText.attributedPlaceholder = NSAttributedString(string: "*Title",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            self.descError.text = "Please fill in the title"//TODO: Check and update message
        }
        
        if let description = descriptionTextView.text, description != descriptionTextView.placeHolder, description.count != 0 {
            dataDictionary["Body"] = description
        }else{
            descriptionTextView.placeHolderColor = .red
            self.descError.text = "Please fill in description"//TODO: Check and update message
        }
        
        if dataDictionary.count < 6 {
            if dataDictionary.count < 5 {
                self.descError.text = "Please fill in all required fields"
            }
            return nil
        }
        
        return dataDictionary
    }
    
    func addData(question:[String:Any]) {
        db.collection("Questions").document().setData(question) { error in
            if let e = error {
                print (e)
            }else {
                CustomAlert.showAlert(
                    title: "Question Posted",
                    message: "You will be notified when somebody answers",
                    inController: self,
                    with: UIImage(named: "Check"),
                    cancleTitle: "Ok") {
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
    }
    //                    self.delegate?.add()
 //   self.delegate?.after(sendBack: self.sendBack)
    
    @IBAction func post(_ sender: Any) {
        //GET COM NAME
        //check errors
        descError.text = ""
        guard let question = self.validatedData() else {
            return
        }
        
        db.collection("Questions").whereField("ID", isEqualTo: ID).whereField("Title", isEqualTo: question["Title"]!).getDocuments { querySnapshot, error in
            guard let questions = querySnapshot?.documents else {
                print (error ?? "")
                return
            }
            if questions.count > 0 {
                self.descError.text = "This question has already been asked"
            } else {
                self.addData(question: question)
                self.delegate?.add()
                self.delegate?.after(sendBack: self.sendBack)
            }
        }
        
        /*db.collection("Questions").getDocuments{
            querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data =  doc.data()
                        if data["Title"] as? String == self.titleText.text  {
                            self.present = true // here!
                            break
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        
        
        if !present{
            db.collection("Questions").document().setData(question)
            db.collection("Questions").getDocuments{
                querySnapshot, error in
                if let e = error {
                    print("There was an issue retreving data from fireStore. \(e)")
                }else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data =  doc.data()
                            if data["Title"] as? String == self.titleText.text && data["Body"] as? String == self.descriptionTextView.text {
                                self.sendBack = doc.documentID
                                self.delegate?.after(sendBack: self.sendBack)
                                break
                                
                            }
                        }
                    } //hard coded, get from transition var = ID
                }
            }
            

            
            //       navigationController?.popViewController(animated: true)
            //      dismiss(animated: true, completion: nil)
            //Added successfully pop pup
            let vcAlert = UIAlertController(title: "Question Posted", message: "You will be notified when somebody answers", preferredStyle: .alert)
            vcAlert.view.tintColor = .black //OK
            //        vcAlert.tit
            var imageView = UIImageView(frame: CGRect(x: 125, y: 77, width: 20, height: 20))
            imageView.image = UIImage(named: "Check")
            vcAlert.view.addSubview(imageView)
            // vcAlert.setBackgroundColor(color:#colorLiteral(red: 0.5702208877, green: 0.7180579305, blue: 0.8433079123, alpha: 1))
            let okAction = UIAlertAction(title: "Ok", style: .default) { alertAction in
                self.dismiss(animated: true, completion: nil)
            }
            vcAlert.addAction(okAction)
            self.present(vcAlert, animated: true, completion: nil)
        } else {
            descError.text = "This question has already been asked"
        }*/

    }
}

