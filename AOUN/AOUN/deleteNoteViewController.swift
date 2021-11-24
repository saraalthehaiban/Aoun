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

class deleteNote: UIViewController {

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
        
        errorMsg.text = ""
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
    
        price.text = note.price!
        if price.text != ""{
            price.text = "\(note.price ?? "") SAR"
        } else{
            price.text = "Free"
            price.textColor = .systemGreen
        }
    }//end viewDidLoad
    
    
    @IBAction func downloadButtonTouched(_ sender: Any) {
        guard let url = note.url else {
                      //TODO: Show download url error message
                      errorMsg.text = "Download failed"
                      return
                  }
                  download(url:url)
             }


          func download (url:URL) {
                  //activityIndicator.startAnimating()
                  DownloadManager.download(url: url) { success, data in
                      guard let d = data else{ return }
                      self.showFileSaveActivity(data: d)
                  }
              }

    
              func showFileSaveActivity (data:Data) {
                  let vcActivity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                  vcActivity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                      if !completed {
                          // User canceled
                          return
                      }
                      // User completed activity
                      self.showDownloadSuccess()
                  }
                  self.present(vcActivity, animated: true, completion: nil)
              }

              
              func showDownloadSuccess () {
                  let alertVC = UIAlertController(title: "Downloaded!", message: "File \"\(self.note.noteLable)\" dowloaded successfully.", preferredStyle: .alert)
                  var imageView = UIImageView(frame: CGRect(x: 125, y: 75, width: 20, height: 20))
                          imageView.image = UIImage(named: "Check")
                  alertVC.view.addSubview(imageView)
                  let action = UIAlertAction(title: "Ok", style: .cancel) { action in
                      self.dismiss(animated: true, completion: nil)
                  }

                  alertVC.addAction(action)
                  self.present(alertVC, animated: true, completion: nil)
              }
    
    
    @IBAction func deleteNote(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your note.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.delete(note: self.note)
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
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
