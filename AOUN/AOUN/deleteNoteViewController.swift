//
//  deleteNoteViewController.swift
//  AOUN
//
//  Created by Reema Turki on 17/03/1443 AH.
//
//
//  deleteNote.swift
//  AOUN
//
//
import Firebase
import UIKit
protocol deleteNoteDelegate {
    func delAt(index : IndexPath)
}

class deleteNote: UIViewController {

    @IBOutlet weak var noteIMG: UIImageView!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var wave: UIImageView!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
  
    var delegate: deleteNoteDelegate?
    let db = Firestore.firestore()
    var note : NoteFile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
        price.text = note.price
    }
    
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func downloadButtonTouched(_ sender: Any) {
        guard let url = note.url else {
            //TODO: Show download url error message
            errorMsg.text = "Download field"
            return
        }
        //activityIndicator.startAnimating()
        DownloadManager.download(url: url) { success, data in
            //guard let documentData = data.dataRe
            //self.activityIndicator.stopAnimating()
            let vcActivity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            self.present(vcActivity, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteNote(_ sender: UIButton) {
//        let id = self.db.collection("Notes").document(documentID);  db.collection("Notes").document(id).delete() { err in
//
//                    if let err = err {
//                        print("Error removing document: \(err)")
//                    } else {
//                        print("Document successfully removed!")
//                    }
//               }
    }
    
}
