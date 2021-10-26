//
//  deleteResViewController.swift
//  AOUN
//
//  Created by Reema Turki on 15/03/1443 AH.
//

import UIKit
import Firebase
import FirebaseStorage

protocol deleteResDelegate {
    func delAt(index : IndexPath)
}

class deleteResViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var smallBackground: UIImageView!
    @IBOutlet weak var authTitle: UILabel!
    @IBOutlet weak var pubTitle: UILabel!
    @IBOutlet weak var descTitle: UILabel!
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var authL: UILabel!
    @IBOutlet weak var pubL: UILabel!
    @IBOutlet weak var descL: UILabel!
    @IBOutlet weak var errorMsg: UILabel!

    var index : IndexPath!
    var delegate: deleteResDelegate?
    let db = Firestore.firestore()
    var resource: resFile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMsg.text = ""
        resL.text = resource.name
        authL.text = resource.author
        pubL.text = resource.publisher
        descL.text = resource.desc
        if descL.text == "" {
            descL.text = "No Description"
        }
    }//end viewDidLoad
    
    
        @IBAction func downloadButtonTouched(_ sender: Any) {
            guard let url = resource.url else {
                errorMsg.text = "Download field"
                return
            }
            DownloadManager.download(url: url) { success, data in
                let vcActivity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                self.present(vcActivity, animated: true, completion: nil)
            }
        }//end downloadButtonTouched

    
    @IBAction func deleteRes(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your resource and is irreversible.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.delete(resource: self.resource)
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }//end delete
    
    func delete(resource:resFile)  {
        self.db.collection("Resources").document(resource.documentId!).delete { error in
            if error != nil {
                //Handle Error here
            } else {
                //Dismiss view controller and inform previosu view
                self.dismiss(animated: true, completion: nil)
                self.delegate?.delAt(index: self.index)
            }
        }
    }
}//end class
