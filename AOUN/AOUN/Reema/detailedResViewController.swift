//
//  detailedResViewController.swift
//  AOUN
//
//  Created by Reema Turki on 21/02/1443 AH.
//

import UIKit
import Firebase
import FirebaseStorage

class detailedResViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var smallBackground: UIImageView!
   // @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var authTitle: UILabel!
    @IBOutlet weak var pubTitle: UILabel!
    @IBOutlet weak var descTitle: UILabel!
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var authL: UILabel!
    @IBOutlet weak var pubL: UILabel!
    @IBOutlet weak var descL: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
  
    var resource: resFile!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        resL.text = resource.name
        authL.text = resource.author
        pubL.text = resource.publisher
        descL.text = resource.desc
     
        if descL.text == "Description" {
            descL.text = "No Description"
        }
    }
    

   // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
}
