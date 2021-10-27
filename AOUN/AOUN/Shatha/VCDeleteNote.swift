//
//  deleteNote.swift
//  AOUN
//
//
import Firebase
import UIKit
import FirebaseStorage
protocol deleteNoteDelegate {
    func delAt(index : IndexPath)
}

class VCDeleteNote: UIViewController {

    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var price: UILabel!
    var index : IndexPath!
        var delegate: deleteNoteDelegate?
        let db = Firestore.firestore()
        var note : NoteFile!

        override func viewDidLoad() {
            super.viewDidLoad()
            
           
            noteTitle.text = note.noteLable
            authorName.text = note.autherName
            desc.text = note.desc
           
            price.text = note.price!
        }//end viewDidLoad
        
        
       
        
        
       
    @IBAction func deleteNote(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your note and is irreversible.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.delete(note: self.note)
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }
    
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
//
////    var TitleName = ""
////    var descr = ""
////    var authorname = ""
////    var pr = ""
//    var index : IndexPath!
//    var delegate: deleteNoteDelegate?
//    let db = Firestore.firestore()
//    @IBOutlet weak var noteIMG: UIImageView!
//    @IBOutlet weak var noteTitle: UILabel!
//    @IBOutlet weak var wave: UIImageView!
//
//    @IBOutlet weak var AuthorLabel: UILabel!
//    @IBOutlet weak var authorName: UILabel!
//    @IBOutlet weak var desc: UILabel!
//    @IBOutlet weak var descLabel: UILabel!
//
//    var note : NoteFile!
//
//    @IBAction func deleteNote(_ sender: UIButton) {
//        //db.collection("Notes").whereField("", in: <#T##[Any]#>)
//
//        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your note and is irreversible.", preferredStyle: .alert)
//        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
//            self.delete(note: self.note)
//        }
//        alert.addAction(da)
//
//        let ca = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
//        alert.addAction(ca)
//
//        self.present(alert, animated: true, completion: nil)
//
//
//
//    }
//
//    @IBOutlet weak var price: UILabel!
//    @IBOutlet weak var errorMSG: UILabel!
//
//    override func viewDidLoad() {
//
////        info.text = desc
//        super.viewDidLoad()
//        noteTitle.text = note.noteLable
//                authorName.text = note.autherName
//                desc.text = note.desc
//                price.text = note.price!
//
//    }
//
//
//
//    func delete(note:NoteFile)  {
//        self.db.collection("Notes").document(note.documentId!).delete { error in
//            if error != nil {
//                //Handle Error here
//            } else {
//                //Dismiss view controller and inform previosu view
//                self.dismiss(animated: true, completion: nil)
//                self.delegate?.delAt(index: self.index)
//            }
//        }
//    }
//
//}
