//
//  detailedResViewController.swift
//  AOUN
//
//  Created by Reema Turki on 21/02/1443 AH.
//

import UIKit

class detailedResViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var smallBackground: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var resTitle: UILabel!
    @IBOutlet weak var authTitle: UILabel!
    @IBOutlet weak var pubTitle: UILabel!
    @IBOutlet weak var descTitle: UILabel!
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var authL: UILabel!
    @IBOutlet weak var pubL: UILabel!
    @IBOutlet weak var descL: UILabel!
    
    var resource: resFile!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        resL.text = resource.name
        authL.text = resource.author
        pubL.text = resource.publisher
        descL.text = resource.desc
     
        if descL.text == "" {
            descL.text = "No Description"
        }
        //**********FILES***********
    }
    

   // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        @IBAction func downloadButtonTouched(_ sender: Any) {
            guard let url = resource.url else {
                //TODO: Show download url error message
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

}
