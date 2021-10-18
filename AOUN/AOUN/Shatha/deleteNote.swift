//
//  deleteNote.swift
//  AOUN
//
//  Created by shatha on 11/03/1443 AH.
//
import Firebase
import UIKit
protocol deleteNoteDelegate {
    func delAt(index : IndexPath)
}

class deleteNote: UIViewController {

    var TitleName = ""
    var descr = ""
    var authorname = ""
    var pr = ""
    var index : IndexPath!
    var delegate: deleteNoteDelegate?

    @IBOutlet weak var noteIMG: UIImageView!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var wave: UIImageView!

    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var authorName: UIImageView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBAction func deleteNote(_ sender: UIButton) {
    }
    @IBOutlet weak var pricePlace: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var errorMSG: UILabel!
    override func viewDidLoad() {
        noteTitle.text = TitleName
//        info.text = desc
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
