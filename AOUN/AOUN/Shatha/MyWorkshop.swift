//
//  MyWorkshop.swift
//  AOUN
//
//  Created by shatha on 23/11/2021.
//


import UIKit

import Firebase


import Foundation

protocol MyWorkshopDelegate {
    func delAt(index : IndexPath)
}



class MyWorkshop: UIViewController {
    
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
   
    
    var index : IndexPath!
    var delegate: MyWorkshopDelegate?
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
    }
    

    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
   
    @IBAction func showParticipantButttonTouched(_ sender: Any) {
        self.performSegue(withIdentifier: "si_myWorkshopToTickets", sender: workshop)
    }
}

extension MyWorkshop {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ParticipantVC , let ws = sender as? Workshops {
            vc.workshop = ws
        }
    }
}


////MARK:- Ticket Stuff
//extension MyWorkshop {
//
//
//    func loadUser () {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            //User is not logged in
//            return
//        }
//        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                //Display Error
//                print(error)
//            } else {
//                guard let docRef = querySnapshot?.documents, let user = docRef.first?.data() else {return}
//                self.user = User(FirstName: user["FirstName"] as! String, LastName: user["LastName"] as! String, uid: userId)
//                self.user?.docID = docRef.first?.documentID
//
//            }
//        }
//    }
//
//    }
