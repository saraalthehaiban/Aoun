//
//  detailedNoteViewController.swift
//  AOUN
//
//  Created by Rasha on 28/09/2021.
//

import UIKit
import BraintreeDropIn

import PayPalCheckout


enum DownloadAction : String {
    case download  = "Download"
    case pay = "Pay & Download"
}

//sb-ew5ol8313965@business.example.com

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
    var hackCheck = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let paymentButton = PayPalButton()
//        paymentButton.frame = CGRect(x: 100, y: 240, width: 80, height: 44)
//        paymentButton.backgroundColor = .red
//        //self.view.insertSubview(paymentButton, at: 100)
//        self.view.addSubview(paymentButton)
        
        noteTitle.text = note.noteLable
        aoutherName.text = note.autherName
        desc.text = note.desc
        price.text = note.price
        
        if let p = note.price, p.count > 0, let price = Decimal(string: p), price > 0 {
            downloadButton.setTitle("Pay & Download", for: .normal)
            priceOfNote = price
        }
        
        // Do any additional setup after loading the view.
        
//        self.configurePayPalCheckout()
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
            
            //showDropIn(clientTokenOrTokenizationKey:authorization, url:url )
            triggerPayPalCheckout()
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


//MARK:- payment implementation
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
    
//    func configurePayPalCheckout() {
//        Checkout.setCreateOrderCallback { createOrderAction in
//            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "\(self.priceOfNote)")
//
//            let purchaseUnit = PurchaseUnit(amount: amount, softDescriptor: self.note.noteLable)
//            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
//
//            createOrderAction.create(order: order)
//        }
//
//        Checkout.setOnApproveCallback { approval in
//            approval.actions.capture { (response, error) in
//                print("Order successfully captured: \(response?.data)")
//            }
//        }
//        Checkout.setOnCancelCallback {
//            // User has cancelled the payment experience
//        }
//        Checkout.setOnErrorCallback { error in
//            // Handle the error generated by the SDK
//        }
//
//    }
    
    
    func triggerPayPalCheckout() {
        self.hackCheck = true
//        Checkout.addShippingAddress(givenName: "", familyName: "", address: "" as! Address)
        Checkout.start(presentingViewController: self) { createOrder in
            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "\(self.priceOfNote)")
            let purchaseUnit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])

            createOrder.create(order: order)
        } onApprove: { approval in
            approval.actions.capture { (response, error) in
                print("Order successfully captured: \(response?.data)")
            }
        } onShippingChange: { shippingChange, shippingChangeAction in
            //
        } onCancel: {
            print("Order onCancel captur")
        } onError: { errorInfo in
            print("Order onError captur")
        }
        
        self.download(url: note.url!)

        
//        Checkout.start(
//            createOrder: { createOrderAction in
//
//                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "\(self.priceOfNote)")
//                let purchaseUnit = PurchaseUnit(amount: amount)
//                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
//
//                createOrderAction.create(order: order)
//
//            }, onApprove: { approval in
//
//                approval.actions.capture { (response, error) in
//                    print("Order successfully captured: \(response?.data)")
//                }
//
//            }, onCancel: {
//
//                print("Order onCancel captur")
//                // Optionally use this closure to respond to the user canceling the paysheet
//
//            }, onError: { error in
//
//                print("Order onError captur")
//                // Optionally use this closure to respond to the user experiencing an error in
//                // the payment experience
//
//            }
//        )
    }
}

//Paypal Payment

extension detailedNoteViewController {
    
}
