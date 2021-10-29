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
    
    var priceOfNote:Decimal = 0
    var hackCheck = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
        price.text = "SAR \(note.price ?? "")"
        
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
    
    func triggerPurchase(url:URL) {
        let title = "Purchase: \(note.noteLable) | SAR\(note.priceDecimal ?? 0) (USD\(note.usdPrice ?? 0))"
        let activityViewController = UIAlertController(title: title, message: "You will be re-directed to paypal to confirm payment", preferredStyle: .actionSheet)
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default) { action in
            self.paymentAction(url:url)
        }
        activityViewController.addAction(purchaseAction)
        
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        activityViewController.addAction(cancleAction)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func paymentAction(url:URL){
        //        self.triggerPayPalCheckout()
        
        //            self.showDropIn(clientTokenOrTokenizationKey: authorization, url: url) //Metod 2
        
        self.startCheckout(amount: "\(priceOfNote)") { message in
            self.download(url: url)
        } failure: { error in
            //TODO: Show alert from sarah's code
        }
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
        let alertVC = UIAlertController(title: "Downloaded!", message: "File \"\(self.note.noteLable)\" dowloaded successfully.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
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
    
    func returnToDownload() {
        self.download(url: note.url!)
    }
    
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
                self.returnToDownload()
                print("Order successfully captured: \(response?.data)")
                //self.returnToDownload() //DID NOT WORK
            }
            //self.returnToDownload() //DID NOT WORK
        } onShippingChange: { shippingChange, shippingChangeAction in
            //
        } onCancel: {
            print("Order onCancel captur")
        } onError: { errorInfo in
            print("Order onError captur")
        }
        
        //self.download(url: note.url!)
        
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
    
    func startCheckout(amount:String, success: @escaping (String)->Void, failure: @escaping (Error) -> Void) {
        braintreeClient = BTAPIClient(authorization: authorization)
        if let btClient = braintreeClient {
            let payPalDriver = BTPayPalDriver(apiClient: btClient)
            let request = BTPayPalCheckoutRequest(amount: amount)
            request.currencyCode = "USD"
            
            /*let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "\(self.priceOfNote)")
             let purchaseUnit = PurchaseUnit(amount: amount)
             let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
             createOrder.create(order: order)*/
            
            payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                    print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                    
                    
                    let email = tokenizedPayPalAccount.email
                    let firstName = tokenizedPayPalAccount.firstName
                    let lastName = tokenizedPayPalAccount.lastName
                    let phone = tokenizedPayPalAccount.phone
                    
                    let billingAddress = tokenizedPayPalAccount.billingAddress
                    let shippingAddress = tokenizedPayPalAccount.shippingAddress
                    
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
}

//Paypal Payment

extension detailedNoteViewController {
    
}
