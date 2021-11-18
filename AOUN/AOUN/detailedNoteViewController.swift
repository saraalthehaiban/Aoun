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
import Cosmos

enum DownloadAction : String {
    case download  = "Download"
    case pay = "Pay & Download"
}

//sb-ew5ol8313965@business.example.com

class detailedNoteViewController: UIViewController{
    let authorization = "sandbox_f252zhq7_hh4cpc39zq4rgjcg"
    var braintreeClient: BTAPIClient?
    var user:QueryDocumentSnapshot?

    
   // @IBOutlet var buttonLabel: UILabel!
    @IBOutlet var addReview: UIButton!
    @IBOutlet var noRevs: UILabel!
    @IBOutlet var reviews: UITableView!
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
    
    var docID: String = ""
    var note : NoteFile!
    var authID: String = ""
    var priceOfNote:Decimal = 0
    var hackCheck = false
    var db  = Firestore.firestore()
    var Reviews: [Review] = []
    var revID: String = ""
    var colRef: CollectionReference!
    var docRef: DocumentReference!
    var rating: CosmosView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //start table set up
        reviews.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "RevCell")
        reviews.delegate = self
        reviews.dataSource = self
        loadReviews()
        //end table set up
        noteTitle.text = note.noteLable
        authorName.text = note.autherName
        desc.text = note.desc
        price.text = "\(note.price ?? "")"
        if price.text != ""{
            price.text = "\(note.price ?? "") SAR"
        } else{
            price.text = "Free"
            price.textColor = .systemGreen
        }
        
        
        addReview.layer.shadowColor = UIColor.black.cgColor
        addReview.layer.shadowOpacity = 0.25
        if note.priceDecimal != nil {
            downloadButton.setTitle("Pay & Download", for: .normal)
            priceOfNote = note.priceDecimal ?? 0
        }
        self.loadUserReference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hackCheck == true {
            self.download(url: note.url!)
        }
    }
    
    @IBAction func downloadButtonTouched(_ sender: Any) {
        guard let url = note.url else {
            //TODO: Show download url error message
            errorMsg.text = "Download failed"
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
            
            //downladed URL
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
        //db.collection("Notes").document("asdj adasjhl").collection("reviews").document("id")
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
    
    func updateReviewButton() {
        self.purchased(note: self.note) { condition in
            self.addReview.isHidden = !condition
          //  self.buttonLabel.isHidden = !condition
        }
    }
    
    func  purchased(note:NoteFile, _ complition: @escaping (Bool)->Void) {
        guard let reference = self.user?["purchasedNotes"] as? [DocumentReference] else {
            complition(false)
            return
        }
        
        for dr in reference {
            if dr.documentID == note.id {
                complition(true)
                return;
            }
        }
        complition(false)
    }
    
    func loadUserReference()  {
        guard let userId = Auth.auth().currentUser?.uid else {
            //User is not logged in
            return
        }
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                self.user = querySnapshot?.documents.first
                self.updateReviewButton()
            }
        }
    }
    
    func updateNoteDownload (note:NoteFile) {
        var purchasedNotes : [DocumentReference] = []
        if  let pn = self.user?["purchasedNotes"] as? [DocumentReference] {
            purchasedNotes = pn
        }
        purchasedNotes.append(db.document("Notes/\(note.id)"))
        let updateData = ["purchasedNotes":purchasedNotes]
        self.user?.reference.updateData(updateData, completion: { error in
            if let error = error {
                print(error)
            } else {
            }
        })
    }
    
    
    
    func download (url:URL) {
        //activityIndicator.startAnimating()
        DownloadManager.download(url: url) { success, data in
            guard let d = data else{ return }
            self.updateNoteDownload(note: self.note)
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
            //self.dismiss(animated: true, completion: nil)
            self.loadUserReference()
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    func set(message:String?) {
        self.noRevs.text  = message
    }
    
    //MARK:- loadReviews and check for user history - Sara
    func loadReviews(){
        self.set(message: "Loading..")
        Reviews = []
        colRef = Firestore.firestore().collection("Notes").document(docID).collection("reviews")
        colRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.set(message: error.localizedDescription)
            } else {
                guard let docuents = querySnapshot?.documents else {
                    return
                }
                for document in docuents {
                    let data = document.data()
                    let user = data["user"] as! DocumentReference
                    let review = data["review"] as! String
                    let point = data["point"] as! Double
                    let nameOfUser = data["nameOfUser"] as! String
                    let newRev = Review(nameOfUser: nameOfUser, review: review, point: point, user: user)
                    self.Reviews.append(newRev)
                    
//                    user?.getDocument(completion: { userQuery, error in
//                        if let e = error {
//                            print("There was an issue retreving data from fireStore. \(e)")
//                            self.set(message: error?.localizedDescription)
//                        }else {
//                            if let dataN = userQuery?.data() {
//                                var fName = dataN["FirstName"] as? String
//                                let lName = document.data()["LastName"] as? String
//                                fName?.append(lName ?? "")
//                                let newRev = Review(user: fName!, body: body!, rating: stars)
//                                self.Reviews.append(newRev)
//                                DispatchQueue.main.async {
//                                    self.reviews.insertRows(at: [IndexPath(row: self.Reviews.count-1, section: 1)], with: .left)
//                                }
//                            }
//                        }
//                    })
                   
                    
//                    Firestore.firestore().collection("users").getDocuments(){
//                        querySnapshot, error in
//                        if let e = error {
//                            print("There was an issue retreving data from fireStore. \(e)")
//                            self.set(message: error?.localizedDescription)
//                        }else {
//                            if let snapshotDocuments = querySnapshot?.documents{
//                                for doc in snapshotDocuments{
//                                    if doc.documentID == user {
//                                        let dataN = doc.data()
//                                        var fName = dataN["FirstName"] as? String
//                                        let lName = document.data()["LastName"] as? String
//                                        fName?.append(lName ?? "")
//                                        let newRev = Review(user: fName!, body: body!, rating: stars)
//                                        self.Reviews.append(newRev)
//                                    }
//                                }
//                            }
//                        }
//                    }
                }
                
                DispatchQueue.main.async {
                    self.reviews.reloadData()
                }
                self.set(message: (self.Reviews.count == 0) ? "No reviews have been written yet" : nil)
            }
        }
    }
    
    @IBAction func addReview(_ sender: Any) {
        self.performSegue(withIdentifier: "si_reviewToAddReview", sender: note)
    }
    
    @IBAction func autherNameClicked(_ sender: Any) {
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: self.authID).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                if let userData = querySnapshot?.documents.last {
                    let firstname = userData["FirstName"] as? String ?? ""
                    let lastName = userData["LastName"] as? String ?? ""
                    let fullName = firstname + ((lastName.count > 0) ? " \(lastName)" : "")
                    let user = User(FirstName: firstname, LastName: lastName, uid: self.authID)
                    DispatchQueue.main.async {
                        OtherUserProfile.present(with: user, on: self)
                    }
                }
            }
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
        Checkout.start(presentingViewController: self) { createOrder in
            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "\(self.priceOfNote)")
            let purchaseUnit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
            
            createOrder.create(order: order)
        } onApprove: { approval in
            approval.actions.capture { (response, error) in
                self.returnToDownload()
                print("Order successfully captured: \(response?.data)")
            }
        } onShippingChange: { shippingChange, shippingChangeAction in
        } onCancel: {
            print("Order onCancel captur")
        } onError: { errorInfo in
            print("Order onError captur")
        }
    }
    
//    func startCheckout(amount:String, success: @escaping (String)->Void, failure: @escaping (Error) -> Void) {
//        braintreeClient = BTAPIClient(authorization: authorization)
//        if let btClient = braintreeClient {
//            let payPalDriver = BTPayPalDriver(apiClient: btClient)
//            let request = BTPayPalCheckoutRequest(amount: amount)
//            request.currencyCode = "USD"
//
//
//            payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
//                if let tokenizedPayPalAccount = tokenizedPayPalAccount {
//                    print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
//
//
//                    let email = tokenizedPayPalAccount.email
//                    let firstName = tokenizedPayPalAccount.firstName
//                    let lastName = tokenizedPayPalAccount.lastName
//                    let phone = tokenizedPayPalAccount.phone
//
//                    let billingAddress = tokenizedPayPalAccount.billingAddress
//                    let shippingAddress = tokenizedPayPalAccount.shippingAddress
//
//                    success(email ?? "")
//                } else if let error = error {
//
//                    print(error.localizedDescription)
//                    failure(error)
//                    self.errorMsg.text = error.localizedDescription
//                } else {
//
//
//                }
//            }
//        }
//    }
}

//MARK:- Reviews by Sara



extension detailedNoteViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviews.dequeueReusableCell(withIdentifier: "RevCell", for: indexPath) as! ReviewCell
        cell.user.text = Reviews[indexPath.row].nameOfUser
        cell.body.text = Reviews[indexPath.row].review
        cell.stars.rating = Reviews[indexPath.row].point
        return cell
    }
}


extension detailedNoteViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PostReview {
            vc.note = note
            vc.delegate = self
        }
    }
}


extension detailedNoteViewController : PostReviewDelegate {
    func postReview(_ pr:PostReview, review:Review, posted:Bool) {
        if posted {
            self.Reviews.insert(review, at: 0)
            self.reviews.reloadData()
            pr.dismiss(animated: true, completion: nil)
        } else{
            //Show error? IDK if it will ever show...
        }
        
    }
}
