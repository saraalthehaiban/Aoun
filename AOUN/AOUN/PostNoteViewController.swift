//
//  PostNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit
import UniformTypeIdentifiers
import Firebase

class PostNoteViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet weak var BG: UIImageView!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcomLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var postNotePageTitle: UILabel!
    @IBOutlet weak var formBG: UIImageView!
    @IBOutlet weak var noteTitleLable: UILabel!
    @IBOutlet weak var noteTitleTextbox: UITextField!
    @IBOutlet weak var autherLable: UILabel!
    @IBOutlet weak var autherTextbox: UITextField!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var descriptionTextbox: UITextField!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var priceTextbox: UITextField!
    
    
    
    @IBAction func importButton(_ sender: Any) {
        
        let attachSheet = UIAlertController(title: nil, message: "File attaching", preferredStyle: .actionSheet)
                
                
                attachSheet.addAction(UIAlertAction(title: "File", style: .default,handler: { (action) in
                    let supportedTypes: [UTType] = [UTType.pdf,UTType.zip, UTType.word]
                    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
                    documentPicker.delegate = self
                    documentPicker.allowsMultipleSelection = false
                    documentPicker.shouldShowFileExtensions = true
                    self.present(documentPicker, animated: true, completion: nil)
                }))
                
                
                attachSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(attachSheet, animated: true, completion: nil)
        
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var selectedFileData = [String:String]()
            let file = urls[0]
            do{
                let fileData = try Data.init(contentsOf: file.absoluteURL)
               
                selectedFileData["filename"] = file.lastPathComponent
                selectedFileData["data"] = fileData.base64EncodedString(options: .lineLength64Characters)
                
            }catch{
                print("contents could not be loaded")
            }
        }
    
       
    
    @IBAction func submitButton(_ sender: Any) {
        
        
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}

extension UTType {
    //Word documents are not an existing property on UTType
    static var word: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}
