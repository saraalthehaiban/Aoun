//
//  ViewController.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/09/2021.
//

import UIKit
import Firebase

let K_DescriptionLimit = 240
let K_TitleLimit = 24

class RequestCommunityController: UIViewController {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var descriptionTextView: RPTTextView!
    @IBOutlet var inputError: UILabel!
    
    var n : String = ""
    var d : String = ""
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        self.descriptionTextView.characotrLimit = K_DescriptionLimit
        self.descriptionTextView.placeHolderColor = .lightGray
        self.descriptionTextView.placeHolder = "*Description"

        self.descriptionTextView.layer.borderWidth = 1.0; //check in runtime
        self.descriptionTextView.layer.cornerRadius = 8;// runtime
        self.descriptionTextView.layer.borderColor = #colorLiteral(red: 0.9027513862, green: 0.8979359269, blue: 0.8978534341, alpha: 1)

    }
    
    func validatedData () -> [String:Any]? {
        self.inputError.text = nil
        var dataDictionary : [String:Any] = [:]
        if let title = nameTextField.text, title.count > 1 {
            dataDictionary["Title"] = title
        }else{
            inputError.textColor = UIColor.systemRed;
            inputError.text = "Please fill in title field";
            nameTextField.attributedPlaceholder = NSAttributedString(string: "*Title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        if let description = descriptionTextView.text, description != "*Description", description.count != 0  {
            dataDictionary["Description"] = description
        }else{
            descriptionTextView.placeHolderColor = .red
            inputError.text = "Please fill in description field";
        }
        
        if dataDictionary.count < 2 {
            if (dataDictionary.count == 0) {
                inputError.text = "Please fill in all required fields";
            }
            return  nil
        }

        return dataDictionary
    }
    
    @IBAction func submit(_ sender: Any) {
        guard let data = self.validatedData() else {
            return
        }
        
        inputError.text = "";
        n = nameTextField.text ?? ""
        d = descriptionTextView.text ?? ""
        
        db.collection("Request").document().setData(data) { error in
            if let e = error {
                print("Error!", e)
            }else {
                CustomAlert.showAlert(
                    title: "Request sent",
                    message: "Wait for the admin's approval.",
                    inController: self,
                    with: UIImage(named: "Check"),
                    cancleTitle: "Ok") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        };
    }
}

extension RequestCommunityController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        let numberOfChars = newText.count
        return numberOfChars < K_TitleLimit
    }
}
