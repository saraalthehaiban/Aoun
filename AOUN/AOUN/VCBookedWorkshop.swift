//
//  PurchasedWorkshop.swift
//  AOUN
//
//  Created by Reema Turki on 03/05/1443 AH.
//

import UIKit


class BookedWorkshop : MyWorkshop {
    var ticket : Ticket!
    
    @IBAction func downloadButtonTouched(_ sender: Any) {
        downloadTicketDetail(ticket: ticket)
    }
    
    func downloadTicketDetail (ticket:Ticket) {
        //let ticketView = TicketView.fromNib() as! TicketView
        guard let ticketView = UINib.init(nibName: "TicketView", bundle: .main).instantiate(withOwner: self, options: nil)[0] as? TicketView else {return}
        ticketView.ticket = ticket
        ticketView.workshop = self.workshop
        ticketView.setUI()
        if let image = ticketView.getScreenShot() {
            self.showFileShareActivity(image: image)
        }
    }
    
    func showFileShareActivity (image:UIImage) {
        let vcActivity = UIActivityViewController(activityItems: [image, "Thank you for booking the seat"], applicationActivities: nil)
        vcActivity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(vcActivity, animated: true, completion: nil)
    }
}
