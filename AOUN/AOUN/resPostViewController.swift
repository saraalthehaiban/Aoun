//
//  resPostViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit
import Firebase
import UniformTypeIdentifiers

class resPostViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet weak var smallBackground: UIImageView!

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rIcon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    
    @IBOutlet weak var postL: UILabel!
    
    @IBOutlet weak var resourceL: UILabel!
    @IBOutlet weak var autherL: UILabel!
    @IBOutlet weak var publisherL: UILabel!
    @IBOutlet weak var resourceV: UITextField!
    @IBOutlet weak var autherV: UITextField!
    @IBOutlet weak var publisherV: UITextField!
    
    
    @IBOutlet weak var linkL: UILabel!
    @IBOutlet weak var linkV: UITextField!

    
    @IBAction func attach(_ sender: Any) {
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
    } //end func attach
    
    
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
         } //end func documentPicker
    
    
    @IBAction func submit(_ sender: UIButton) {
            
    } //end func submit
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcome2.text = "Sara!"
       
        // Do any additional setup after loading the view.
    } //end func viewDidLoad
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
} //end func resPostViewController


extension UTType {
    //Word documents are not an existing property on UTType
    static var word: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
}
