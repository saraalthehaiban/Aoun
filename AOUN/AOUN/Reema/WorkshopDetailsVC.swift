//
//  workshopDetailsVC.swift
//  AOUN
//
//  Created by shatha on 26/03/1443 AH.
//

import UIKit
import Braintree
import BraintreeDropIn
import PayPalCheckout
import Firebase


class WorkshopDetailsVC: UIViewController {
    let authorization = "sandbox_f252zhq7_hh4cpc39zq4rgjcg"
    var braintreeClient: BTAPIClient?

    @IBOutlet weak var workshopTitle: UILabel!
    @IBOutlet weak var presenterLabel: UILabel!
    @IBOutlet weak var presenterName: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var seatLable: UILabel!
    @IBOutlet weak var seatsNum: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var timeVal: UILabel!
    
    var workshop: Workshops!
    var authID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //TODO: Remove this code
//        workshop = Workshops(Title: "Test", presenter: "P_Test", price: "16.0", seat: "1", description: "Some Description", dateTime: Date(), documentId: "001", uid: "E0RYJx9Y09bmGgjsfl79Ky9SF4c2")
        var newdate = workshop.dateTime
        let tindex = newdate.index(newdate.startIndex, offsetBy: 17)
        let time = newdate[..<tindex]
        let newtime = time.suffix(5)
        let date = newdate.prefix(11)
        workshopTitle.text = workshop.Title
        presenterName.text = workshop.presenter
        desc.text = workshop.description
        dateValue.text = " \(date)"
        timeVal.text = "\(newtime)"
        seatsNum.text = workshop.seat
        price.text = workshop.price + " SAR"
        
        
            
      
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
    
    @IBAction func bookSeat(_ sender: UIButton) {
        triggerPurchase()
    }
}


//MARK:- payment implementation
extension WorkshopDetailsVC {
    func triggerPurchase() {
        let title = "Purchase: \(workshop.Title) | SAR\(workshop.priceDecimal ?? 0) (USD\(workshop.usdString ?? ""))"
        let activityViewController = UIAlertController(title: title, message: "You will be re-directed to paypal to confirm payment", preferredStyle: .actionSheet)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default) { action in
            self.paymentAction()
        }
        activityViewController.addAction(purchaseAction)
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        activityViewController.addAction(cancleAction)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func paymentAction(){
        self.startCheckout(amount: "\(workshop.priceDecimal ?? 0.0)") { message in
            self.updatePrice(price: self.workshop.priceDecimal ?? 0)
            self.confirmWorkshopSeat()
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
                } else {
                }
            }
        }
    }
    func updatePrice(price:Decimal) {
        guard let userId = self.workshop.documentId else {return}
        
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
    
    //TODO: Add code to increase seat or other stuff
    func confirmWorkshopSeat() {
        print("Seat Purchased!")
    }
}

