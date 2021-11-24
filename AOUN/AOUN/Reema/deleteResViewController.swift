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
        if descL.text == "*Description" {
            descL.text = "No Description"
        }
    }//end viewDidLoad
    
    
        @IBAction func downloadButtonTouched(_ sender: Any) {
            guard let url = resource.url else {
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
                        let alertVC = UIAlertController(title: "Downloaded!", message: "File \"\(self.resource.name)\" dowloaded successfully.", preferredStyle: .alert)
                        var imageView = UIImageView(frame: CGRect(x: 125, y: 75, width: 20, height: 20))
                                imageView.image = UIImage(named: "Check")
                        alertVC.view.addSubview(imageView)
                        let action = UIAlertAction(title: "Ok", style: .cancel) { action in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertVC.addAction(action)
                        self.present(alertVC, animated: true, completion: nil)
                    }

    
    @IBAction func deleteRes(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action will delete your resource.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Delete", style: .destructive) { action in
          //  print(self.resource.documentId, "HERE!!!")
            self.delete(resource: self.resource)
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }//end delete
    
    
    func delete(resource:resFile)  {
        self.db.collection("Resources").document(resource.documentId!).delete { error in
            if error != nil {
                //Handle Error here
            } else {
                //Dismiss view controller and inform previosu view""
                self.dismiss(animated: true, completion: nil)
                self.delegate?.delAt(index: self.index)
            }
        }
    }
}//end class
