//
//  AskQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit
import Firebase
import RPTTextView

protocol AskQuestionDelegate{
    func add()
}
class AskQuestion: UIViewController, UITextViewDelegate { //[1] Pleaceholder: UITextViewDelegate
    var delegate: AskQuestionDelegate?
    var db = Firestore.firestore()
    @IBOutlet var descError: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var titleText: UITextField!
    var ID : String = ""
    var ComName : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        self.descriptionTextView.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)
//        self.descriptionTextView.rpt
        self.descriptionTextView.text = "*Description"
        self.descriptionTextView.textColor = UIColor.lightGray
        self.descriptionTextView.layer.borderWidth = 1.0; //check in runtime
        self.descriptionTextView.layer.cornerRadius = 8;// runtime
    }
    
    func validatedData () -> [String:Any]? {
        self.descError.text = nil
        var message : String = ""
        var dataDictionary : [String:Any] = ["ID":ID, "Answers": [], "Community": ComName]
        if let title = titleText.text, title.count > 1 {
            dataDictionary["Title"] = title
        }else{
            message = "*Please enter title"//TODO: Check and update message
        }
        if let description = descriptionTextView.text, description != "*Description", description.count != 0 /*,description != descriptionTextView.placeHolder*/ {
            dataDictionary["Body"] = description
        }else{
            message += "\n*Please enter description"//TODO: Check and update message
        }
        if message.count > 0 {
            self.descError.text = message
            return nil
        }
        
        return dataDictionary
    }
    
    @IBAction func post(_ sender: Any) {
        //GET COM NAME
        //check errors
        guard let question = self.validatedData() else {
            return
        }
        
        db.collection("Questions").document().setData(question);
        delegate?.add()
        
 //       navigationController?.popViewController(animated: true)
 //      dismiss(animated: true, completion: nil)
        //Added successfully pop pup
        let vcAlert = UIAlertController(title: "Question Posted", message: "Question have been posted successfully.", preferredStyle: .alert)
        vcAlert.view.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        vcAlert.tit
        var imageView = UIImageView(frame: CGRect(x: 220, y: 10, width: 40, height: 40))
        imageView.image = UIImage(named: "Check")
        vcAlert.view.addSubview(imageView)
        vcAlert.setBackgroundColor(color:#colorLiteral(red: 0.5702208877, green: 0.7180579305, blue: 0.8433079123, alpha: 1))
        let okAction = UIAlertAction(title: "Ok", style: .default) { alertAction in
            self.dismiss(animated: true, completion: nil)
        }
        vcAlert.addAction(okAction)
        self.present(vcAlert, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == descriptionTextView {
            
        }
        
        return true
    }
    
    //[2] placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    //[3] Placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "*Description"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
     @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
     }


}

