//
//  detailedNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import UIKit

class detailedNoteViewController: UIViewController {

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var autherLable: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
    
    var note : NoteFile!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
        price.text = note.price

        // Do any additional setup after loading the view.
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
}
