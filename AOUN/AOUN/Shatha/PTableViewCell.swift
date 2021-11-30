//
//  PTableViewCell.swift
//  AOUN
//
//  Created by shatha on 28/11/2021.
//

import UIKit

class PTableViewCell: UITableViewCell {
    var ticket : Ticket! {
        didSet {
            self.setData(ticket: self.ticket)
        }
    }
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var seat: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData (ticket : Ticket) {
        self.id.text = ticket.bookingID
        self.seat.text = "\(ticket.seats)"
    }
    
}
