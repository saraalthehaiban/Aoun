//
//  PurchasedTicketView.swift
//  AOUN
//
//  Created by shatha on 10/04/1443 AH.
//

import UIKit

//MARK:- Purchase View
protocol PurchaseTicketViewDelegate {
    func purchase(_ view:PurchaseTicketView, buyTickets:Int, forCost:Decimal)
    func purchase(_ view:PurchaseTicketView, cancledByUser:Bool, message:String)
    func allowedTickets(_ View:PurchaseTicketView) -> Int
    func ticketPrice(_ View:PurchaseTicketView) -> Decimal
}

class PurchaseTicketView : UIView {
    @IBOutlet weak var bookTicketTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var purchaseInfoLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var costCalculationLabel: UILabel!
    var delegate : PurchaseTicketViewDelegate! {
        didSet {
            self.reloadData()
        }
    }
    
    private var allowedTickets : Int = 0
    private var ticketsPrice : Decimal = 0
    private var purchaseTickets : Int = 0 {
        didSet {
            self.buyButton.isEnabled = (self.cumulativeCost > 0)
            self.costCalculationLabel.text = "\(purchaseTickets) x SAR\(ticketsPrice) = SAR\(cumulativeCost)"
        }
    }
    
    public func reloadData () {
        self.initializedDetails()
    }
   
    private var cumulativeCost : Decimal {
        get {
            return Decimal(purchaseTickets)*ticketsPrice
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func initializedDetails() {
        allowedTickets = self.delegate.allowedTickets(self)
        buyButton.isEnabled = (allowedTickets > 0)
        let purchased = K_MaxAllowedTicket - allowedTickets
        let message = (allowedTickets < 3) ? "You have already purchased\(purchased) you can now by \(allowedTickets) mpre." :  nil
        self.purchaseInfoLabel.text = message
        
        self.ticketsPrice = delegate.ticketPrice(self)
        self.purchaseTickets = 1
        //let m = "Buy Workshop Ticket (SAR\(self.ticketsPrice)"
        //self.
        
        //picker config
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.reloadAllComponents()
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.delegate.purchase(self, cancledByUser: true, message: "Canceled")
    }
    
    @IBAction func buyButtonTouched(_ sender: Any) {
        self.delegate.purchase(self, buyTickets: purchaseTickets, forCost: cumulativeCost)
    }
}

extension PurchaseTicketView :UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allowedTickets
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.purchaseTickets = row+1
    }
}



//MARK:-


