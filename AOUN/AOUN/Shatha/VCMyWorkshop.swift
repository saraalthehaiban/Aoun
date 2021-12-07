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
        workshopTitle.text = workshop.Title
        presenterName.text = workshop.presenter
        desc.text = workshop.description
        let date = workshop.dateTime.dateValue()
        dateValue.text = date.dateString
        timeVal.text = date.timeString
        seatsNum.text = workshop.seat
        price.text = workshop.price + " SAR"
    }
   
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
