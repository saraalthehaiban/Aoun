//
//  deleteNote.swift
//  AOUN
//
//  Created by Reema Turki on 15/03/1443 AH.
//

import Firebase
import FirebaseStorage
import UIKit

protocol deleteNoteDelegate {
    func delAt(index : IndexPath)
}

class VCDeleteNote: UIViewController {

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
   
    var index : IndexPath!
    var delegate: deleteNoteDelegate?
    let db = Firestore.firestore()
    var note : NoteFile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
        if desc.text == "" {
            desc.text = "No Description"
        }
        price.text = note.price
    }//end viewDidLoad
    
    
    @IBAction func downloadButtonTouched(_ sender: Any) {
        guard let url = note.url else {
            errorMsg.text = "Download field"
            return
        }
        DownloadManager.download(url: url) { success, data in
            let vcActivity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            self.present(vcActivity, animated: true, completion: nil)
        }
    }//end downloadButtonTouched
    
    
    @IBAction func deleteNote(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your note and is irreversible.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.delete(note: self.note)
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }//end delete
    
    func delete(note:NoteFile)  {
        self.db.collection("Notes").document(note.documentId!).delete { error in
            if error != nil {
                //Handle Error here
            } else {
                //Dismiss view controller and inform previosu view
                self.dismiss(animated: true, completion: nil)
                self.delegate?.delAt(index: self.index)
            }
        }
    }
}
