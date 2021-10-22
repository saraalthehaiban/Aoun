//
//  detailedNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import UIKit
import BraintreeDropIn
import StripeTerminal

enum DownloadAction : String {
    case download  = "Download"
    case pay = "Pay & Download"
}


class detailedNoteViewController: UIViewController{
    let authorization = "sandbox_f252zhq7_hh4cpc39zq4rgjcg"

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var noteTitleLable: UILabel!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var autherLable: UILabel!
    @IBOutlet weak var aoutherName: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var note : NoteFile!
    
    var priceOfNote:Decimal = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTitle.text = note.noteLable
        aoutherName.text = note.autherName
        desc.text = note.desc
        price.text = note.price
        
        if let p = note.price, p.count > 0, let price = Decimal(string: p), price > 0 {
            downloadButton.setTitle("Pay & Download", for: .normal)
            priceOfNote = price
        }
        
        // Do any additional setup after loading the view.
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
            
            showDropIn(clientTokenOrTokenizationKey:authorization, url:url )
        }else{
            download(url: url)
        }
    }
    
    func download (url:URL) {
        //activityIndicator.startAnimating()
        DownloadManager.download(url: url) { success, data in
            //guard let documentData = data.dataRe
            //self.activityIndicator.stopAnimating()
            let vcActivity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            self.present(vcActivity, animated: true, completion: nil)
        }
    }
}


//payment implementation
extension detailedNoteViewController : BTThreeDSecureRequestDelegate {
    
    func showDropIn(clientTokenOrTokenizationKey: String, url:URL) {
        
        let request = BTDropInRequest()

        let threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.threeDSecureRequestDelegate = self

        threeDSecureRequest.amount = 1.00
        threeDSecureRequest.email = "test@example.com"
        threeDSecureRequest.versionRequested = .version2

        let address = BTThreeDSecurePostalAddress()
        address.givenName = "Jill"
        address.surname = "Doe"
        address.phoneNumber = "5551234567"
        address.streetAddress = "555 Smith St"
        address.extendedAddress = "#2"
        address.locality = "Chicago"
        address.region = "IL"
        address.postalCode = "12345"
        address.countryCodeAlpha2 = "US"
        threeDSecureRequest.billingAddress = address

        // Optional additional information.
        // For best results, provide as many of these elements as possible.
        let additionalInformation = BTThreeDSecureAdditionalInformation()
        additionalInformation.shippingAddress = address
        threeDSecureRequest.additionalInformation = additionalInformation

        request.threeDSecureRequest = threeDSecureRequest
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCanceled == true) {
                print("CANCELED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentMethodType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                self.download(url: url)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    //Delegate
    func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult result: BTThreeDSecureResult, next: @escaping () -> Void) {
        
    }
    
    
}
