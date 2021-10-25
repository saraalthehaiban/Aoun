//
//  CommunityDetailsViewController.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 27/09/2021.
//

import UIKit
import Firebase

protocol CommunityDetailsViewControllerDelegate {
    func delAt(index : IndexPath)
}

class CommunityDetailsViewController: UIViewController {
    var delegate: CommunityDetailsViewControllerDelegate?
    let db = Firestore.firestore()
    var TitleName = ""
    var id = ""
    @IBOutlet var name: UILabel!
    @IBOutlet var info: UILabel!
    var desc = ""
    var doc = ""
    var index : IndexPath!
    var requests : [Request] = []
    @IBAction func accept(_ sender: UIButton) {
        db.collection("Communities").document().setData(["Title" : TitleName, "Description" : desc])
//       db.collection("Communities").getDocuments{
//       querySnapshot, error in
//                  if let e = error {
//                      print("There was an issue retreving data from fireStore. \(e)")
//                  }else {
//                      if let snapshotDocuments = querySnapshot?.documents{
//                          for doc in snapshotDocuments{
//                           let data =  doc.data()
//                            if data["Title"] as? String == self.TitleName{
//                                self.id = doc.documentID
//
//                            }
//                            break
//                          }
//                      }
//                  }
//       }
        
        db.collection("Request").document(doc).delete()
        delegate?.delAt(index: index)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func reject(_ sender: UIButton) {
        db.collection("Request").document(doc).delete()
        
        delegate?.delAt(index: index)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        
    }
    override func viewDidLoad() {
        name.text = TitleName
        info.text = desc
        
        super.viewDidLoad()
        //Looks for single or multiple taps.
        // let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        //view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
}



