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


let K_MaxAllowedTicket = 3

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
    @IBOutlet weak var purchaseInformationLable: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var bookSupportTextField: UITextField!
    
    @IBOutlet var purchaseTicketView: PurchaseTicketView!
    var workshop: Workshops!
    var authID: String = ""
    let db = Firestore.firestore()
    var tickets : [Ticket] = []
    var myTickets : [Ticket] = []
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newdate = workshop.dateTime
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
        purchaseTicketView.delegate = self
        
        // self.bookSupportTextField.inputView = purchaseTicketView
        // Do any additional setup after loading the view.
        
        //load
        loadUser()
        self.setPriceView()
    }
    
    func setPriceView() {
        var frame = self.view.frame
        frame.origin.x = 80
        frame.origin.y = (self.view.frame.size.height / 2) - (self.purchaseTicketView.frame.size.height / 2)
        frame.size.width = self.view.bounds.size.width - 160
        frame.size.height = 188
        self.purchaseTicketView.layer.cornerRadius = 16
        self.purchaseTicketView.layer.masksToBounds = true
        self.purchaseTicketView.layer.shadowColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        self.purchaseTicketView.layer.shadowRadius = 2
        self.purchaseTicketView.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.purchaseTicketView.frame = frame
        self.purchaseTicketView.isHidden = true
        self.view.addSubview(self.purchaseTicketView)
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
        
        self.purchaseTicketView.isHidden = false
    }
}


//MARK:- Ticket Stuff
extension WorkshopDetailsVC {
    func loadTickets () {
        self.purchaseInformationLable.text = ""
//        guard let userId = Auth.auth().currentUser?.uid else {
//            //User is not logged in
//            return
//        }
//        let workshopRef = db.collection("Workshops").document("\(self.workshop.documentId!)")
        
        /*let userRef = db.collection("users").document("\(userId)")
        whereField("user", isEqualTo:userRef)*/
        
        db.collection("Tickets").whereField("workshop", isEqualTo: self.workshop.documentId!).getDocuments { querySnapshot, error in
            if let e = error {
                //TODO: Error Handlings
                print (e)
            } else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        if let t = Ticket(dictionary: doc.data()) {
                            self.tickets.append(t)
                        }
                    }
                    self.checkAvailability(tickets: self.tickets)
                }
            }
        }
    }
    
//    func updateMyTickets () {
//        self.myTickets =
//    }
    
    func loadUser () {
        guard let userId = Auth.auth().currentUser?.uid else {
            //User is not logged in
            return
        }
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                guard let docRef = querySnapshot?.documents, let user = docRef.first?.data() else {return}
                self.user = User(FirstName: user["FirstName"] as! String, LastName: user["LastName"] as! String, uid: userId)
                self.user?.documentID = docRef.first?.documentID
                self.loadTickets()
            }
        }
    }
    
    //Update availability messsage
    func checkAvailability (tickets : [Ticket]) {
        if tickets.count >= self.workshop.numberOfAvailableSeats {
            bookButton.setTitle("Sold Out", for: .normal)
            bookButton.isEnabled = false
            bookButton.setTitleColor(.red, for: .normal)
            bookButton.layer.cornerRadius = 8
            bookButton.layer.masksToBounds = true
        }
        
        self.myTickets = self.tickets.filter { (ticket:Ticket) -> Bool in
            return ticket.user == user?.documentID
        }
        
        let m = "You have already purchased \(self.myTickets.count) seats for this workshop."
        self.updateAvailabilityMsessage(message: m)
        if self.myTickets.count == K_MaxAllowedTicket {
            bookButton.setTitle("Reached Limit", for: .normal)
            bookButton.isEnabled = false
            bookButton.setTitleColor(.red, for: .normal)
        }
        
        self.purchaseTicketView.reloadData()
    }
    
    func updateAvailabilityMsessage (message:String?) {
        self.purchaseInformationLable.text = message
    }
    
    func triggerPurchase(forTickets ticketCount:Int, andCost cost : Decimal) {
        let finalCost = Decimal(ticketCount) * cost
        
        let title = "Purchase: \(workshop.Title) | SAR\(finalCost) (USD\(PriceUtils.usdString(fromSAR:finalCost))"
        let activityViewController = UIAlertController(title: title, message: "You will be re-directed to paypal to confirm payment", preferredStyle: .actionSheet)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default) { action in
            self.paymentAction(amount: PriceUtils.usd(fromSAR: finalCost),tickets: ticketCount)
        }
        activityViewController.addAction(purchaseAction)
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        activityViewController.addAction(cancleAction)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func paymentAction(amount:Decimal, tickets:Int){
        self.startCheckout(amount: "\(amount)") { message in
            self.updatePurchase(finalAmount: amount, tickets: tickets)

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
    
    func updatePurchase(finalAmount:Decimal, tickets:Int) {
        //TODO: Change full name call after merge
        guard let user = self.user else {return}
        
        let ticket = Ticket(buyerName: self.user?.FirstName ?? "", price: "\(finalAmount)", time: Timestamp(date: Date()), user: user.documentID ?? "", workshop: self.workshop.documentId ?? "", workshopTitle: self.workshop.Title, bookingID: bookingID(workshop: self.workshop), seats: tickets)
        
        self.db.collection("Tickets").document().setData(ticket.dictionary) { error in
            if let e = error {
                //TODO: Handle Error
                print ("Ticket Booking Error: ", e)
            } else {
                //
                CustomAlert.showAlert(
                    title: "Booked",
                    message: "Ticket Booked Successfully.",
                    inController: self,
                    cancleTitle: "Email") {
                    self.emailTicketDetail(ticket: ticket)
                }
            }
        }
    }
    
    func emailTicketDetail (ticket:Ticket) {
        //let ticketView = TicketView.fromNib() as! TicketView
        guard let ticketView = UINib.init(nibName: "TicketView", bundle: .main).instantiate(withOwner: self, options: nil)[0] as? TicketView else {return}
        ticketView.ticket = ticket
        ticketView.workshop = self.workshop
        ticketView.setUI()
        let image = ticketView.getScreenShot()
        self.showFileShareActivity(image: image)
    }
    
    func showFileShareActivity (image:UIImage) {
        let vcActivity = UIActivityViewController(activityItems: [image, "Thank you for booking the seat"], applicationActivities: nil)
        vcActivity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }
        }
        self.present(vcActivity, animated: true, completion: nil)
    }
    
    func bookingID (workshop:Workshops) -> String {
        let titleWords = workshop.Title.components(separatedBy: " ")
        var namAbvr = ""
        for tw in titleWords {
            namAbvr = namAbvr + String(Array(tw)[0])
        }
        
        let bookingId = namAbvr.uppercased()+String(format: "%03d", self.tickets.count + 1)
        return bookingId
    }
}

extension WorkshopDetailsVC : PurchaseTicketViewDelegate {
    func purchase(_ view:PurchaseTicketView, buyTickets:Int, forCost:Decimal) {
        self.triggerPurchase(forTickets: buyTickets, andCost: forCost)
        view.isHidden = true
    }
    
    func purchase(_ view:PurchaseTicketView, cancledByUser:Bool, message:String) {
        //TODO: Present Mesage Here
        view.isHidden = true
    }
    func allowedTickets(_ View:PurchaseTicketView) -> Int {
        return K_MaxAllowedTicket - self.tickets.count
    }
    func ticketPrice(_ View:PurchaseTicketView) -> Decimal {
        return self.workshop.priceDecimal ?? 0.0
    }
}
