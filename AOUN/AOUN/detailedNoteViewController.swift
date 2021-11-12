//
//  detailedNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import UIKit

import Braintree
import BraintreeDropIn
import PayPalCheckout
import Firebase


enum DownloadAction : String {
    case download  = "Download"
    case pay = "Pay & Download"
}

//sb-ew5ol8313965@business.example.com

class detailedNoteViewController: UIViewController{
    let authorization = "sandbox_f252zhq7_hh4cpc39zq4rgjcg"
    var braintreeClient: BTAPIClient?
    
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var autherLable: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var note : NoteFile!
    var authID: String = ""
    var priceOfNote:Decimal = 0
    var hackCheck = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
//        let intPrice = note.price!
//
//        if note.price != nil {
//            if Int(intPrice)! >= 0{
//                price.text = "SAR \(note.price ?? "")"
//            }
//        }else{
//            price.text = "Free"
//        }
        
        price.text = "\(note.price ?? "")"
        if price.text != ""{
            price.text = "\(note.price ?? "") SAR"
        } else{
            price.text = "Free"
        }
        if note.priceDecimal != nil {
            downloadButton.setTitle("Pay & Download", for: .normal)
            priceOfNote = note.priceDecimal ?? 0
        }
        
        // Do any additional setup after loading the view.
        //self.configurePayPalCheckout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hackCheck == true {
            self.download(url: note.url!)
        }
    }
    
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func downloadButtonTouched(_ sender: Any) {
        guard let url = note.url else {
            //TODO: Show download url error message
            errorMsg.text = "Download field"
            return
        }
        
        
        
        if priceOfNote > 0 {
            //payment
            self.triggerPurchase(url: url)
        }else{
            download(url: url)
        }
    }
    
   
}


//MARK:- payment and purchase
extension detailedNoteViewController {
    func triggerPurchase(url:URL) {
        let title = "Purchase: \(note.noteLable) | SAR\(note.priceDecimal ?? 0) (USD\(note.usdString ?? ""))"
        let activityViewController = UIAlertController(title: title, message: "You will be re-directed to paypal to confirm payment", preferredStyle: .actionSheet)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default) { action in
            self.paymentAction(url:url)
        }
        activityViewController.addAction(purchaseAction)
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        activityViewController.addAction(cancleAction)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func paymentAction(url:URL){
        self.startCheckout(amount: "\(priceOfNote)") { message in
            self.updatePrice(price: self.note.priceDecimal ?? 0)
            self.download(url: url)
        } failure: { error in
            CustomAlert.showAlert(
                title: "Cenceled",
                message: "Your PayPal transaction was canceled.",
                inController: self,
                cancleTitle: "Ok") {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func startCheckout(amount:String, success: @escaping (String)->Void, failure: @escaping (Error) -> Void) {
        braintreeClient = BTAPIClient(authorization: authorization)
        if let btClient = braintreeClient {
            let payPalDriver = BTPayPalDriver(apiClient: btClient)
            let request = BTPayPalCheckoutRequest(amount: amount)
            request.currencyCode = "USD"
            payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                    print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                    let email = tokenizedPayPalAccount.email
                    success(email ?? "")
                } else if let error = error {
                    
                    print(error.localizedDescription)
                    failure(error)
                    self.errorMsg.text = error.localizedDescription
                } else {
                }
            }
        }
    }
    
    func updatePrice(price:Decimal) {
        guard let userId = self.note.userId else {return}
        
        let db = Firestore.firestore()
        //let updateData = ["earned":fcmToken]
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                let user = querySnapshot?.documents.first
                let earned : Double = ((user?.data()["earned"] as? Double)) ?? 0
                let newVal = Decimal.init(earned) + price
                let updateData = ["earned":newVal]
                user?.reference.updateData(updateData, completion: { error in
                    if let error = error {
                        print(error)
                    } else {
                    }
                })
            }
        }
    }
    
    
    func download (url:URL) {
        //activityIndicator.startAnimating()
        DownloadManager.download(url: url) { success, data in
            guard let d = data else{ return }
            
            //NEW Code -Balance-
//            //authID
//            var db = Firestore.firestore()
//            db.collection("users").getDocuments { querySnapshot, error in
//                if let e = error {
//                    print("There was an issue retreving data from fireStore. \(e)")
//                }else {
//                    if let snapshotDocuments = querySnapshot?.documents{
//                        for doc in snapshotDocuments {
//                            let data = doc.data()
//                            if data["uid"] as! String == self.authID{
//                                let bl = data["Balance"] as? Int.IntegerLiteralType
//                               let bl2 =  Int(bl!)
//                               // let final = Int(self.price.text!)! + Int(bl2)
//                             let docID = doc.documentID
//                            db.collection("users").document(docID).updateData(["Balance": final])}
//                        }
//                        }
//
//                    }
//                }
            
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
        
        let action = UIAlertAction(title: "Ok", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

//Paypal Payment

extension detailedNoteViewController {
    
}
