//
//  PostReview.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 13/11/2021.
//

import UIKit
import Cosmos
import Firebase

protocol PostReviewDelegate {
    func postReview(_ pr:PostReview, review:Review, posted:Bool)
}

class PostReview: UIViewController {
    @IBOutlet var starsConsmosView: CosmosView!
    @IBOutlet var reviewNoteTextView: RPTTextView!
    @IBOutlet var errorLable: UILabel!
    var rating : Double?
    var note : NoteFile!
    var delegate : PostReviewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        starsConsmosView.didFinishTouchingCosmos = { rating in
//            rating = rating
//        }
//        if let c = starsConsmosView.didFinishTouchingCosmos {
//            c(
//        }
        self.reviewNoteTextView.characotrLimit = K_DescriptionLimit
        self.reviewNoteTextView.placeHolderColor = #colorLiteral(red: 0.7685510516, green: 0.7686814666, blue: 0.7771411538, alpha: 1)
        self.reviewNoteTextView.placeHolder = "*Review"
        
        self.reviewNoteTextView.layer.borderWidth = 1.0; //check in runtime
        self.reviewNoteTextView.layer.cornerRadius = 8;// runtime
        self.reviewNoteTextView.layer.borderColor = #colorLiteral(red: 0.8439332843, green: 0.8391087651, blue: 0.8433424234, alpha: 1)

       
        starsConsmosView.didTouchCosmos = { (rating:Double)->() in
            self.rating = rating
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
    
    func isValid () -> Bool {
        var isValid = true
        if self.rating == nil {
            self.errorLable.text  = "Please add rating!"
            isValid = false
        }
    
        if self.reviewNoteTextView.text.count == 0 ||
            self.reviewNoteTextView.text == self.reviewNoteTextView.placeHolder {
            self.reviewNoteTextView.placeHolderColor = .red
            self.errorLable.text  = "Please add review"
            isValid = false
        }
        
        if rating == nil && self.reviewNoteTextView.text == self.reviewNoteTextView.placeHolder {
            self.errorLable.text  = "Enter all field"
            isValid = false
        }
        
        return isValid
    }
    
    @IBAction func postReview(_ sender: Any) {
        guard isValid() == true else {return}
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Notes").document(note.docID).collection("reviews").document()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let review = Review(
            nameOfUser: appDelegate.thisUser.fullName ?? "",
            review:  self.reviewNoteTextView.text!,
            point: self.rating ?? 0,
            user:  db.document("users/\(appDelegate.thisUser.docID!)"))
        
//        var data : [String :Any] = [:]
//        data["review"] = self.reviewNoteTextView.text!
//        data["point"] =  self.rating
//        data["nameOfUser"] = appDelegate.thisUser.fullName
//        //"users/\(user?.documentID)"
//        data["user"] = db.document("users/\(appDelegate.thisUser.docID!)")
//        let review = Review(dictionary: data)
        docRef.setData(review.dictionary) { error in
            if let e = error {
                print("Error", e.localizedDescription)
                self.delegate?.postReview(self, review:review, posted: false)
            } else {
                CustomAlert.showAlert(
                    title: "Review posted",
                    message: "You have reviewed the note",
                    inController: self,
                    with: UIImage(named: "Check"),
                    cancleTitle: "Ok") {
                    self.delegate?.postReview(self, review:review, posted: true)
                }
            }
        }
    }
}
    
