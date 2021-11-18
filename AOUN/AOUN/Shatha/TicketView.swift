//
//  TicketView.swift
//  AOUN
//
//  Created by shatha on 10/04/1443 AH.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

class TicketView : UIView {
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        Bundle.main.loadNibNamed("TicketView", owner: self, options: nil)
//    }
    
    var ticket : Ticket!
    var workshop : Workshops!

    @IBOutlet weak var lblBookingID: UILabel!
    @IBOutlet weak var lblBookedSeat: UILabel!
    @IBOutlet weak var lblWorkShopTitle: UILabel!
    @IBOutlet weak var lblWorkShopDate: UILabel!

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPurchaseDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    

    
    func setUI() {
        let newdate = workshop.dateTime
        let tindex = newdate.index(newdate.startIndex, offsetBy: 17)
        let time = newdate[..<tindex]
        let newtime = time.suffix(5)
        let date = newdate.prefix(11)
        let buyDate = "\(ticket.time.dateValue())"
        let buydate = buyDate.prefix(11)
        lblBookingID.text = ticket.bookingID
        lblBookedSeat.text = "Booked Seat(s):\(ticket.seats)"
        lblWorkShopTitle.text = ticket.workshopTitle
        lblWorkShopDate.text = "Workshop Date:\(date) Time:\(newtime)"
        lblUserName.text = ticket.user
        lblPurchaseDate.text = "Purchase Date: \(buydate)"
        lblPrice.text = "Price: \(Int(Double(ticket.price) ?? 1 * 3.75)) SAR"
        lblBookingID.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)

    }
    
    public func getScreenShot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates:true)
        }
    }
}
