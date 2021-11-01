//
//  workshopDetailsVC.swift
//  AOUN
//
//  Created by shatha on 26/03/1443 AH.
//

import UIKit

class workshopDetailsVC: UIViewController {

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
    @IBAction func bookSeat(_ sender: UIButton) {
        
        
        //if payment succeed
        //check the seats and seatNum--
        // rewrite the value in database
    }
    var workshop: Workshops!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workshopTitle.text = workshop.title
        presenterName.text = workshop.presenter
        desc.text = workshop.description
        dateValue.text = workshop.dateTime
        seatsNum.text = workshop.seat
        price.text = workshop.price

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

}
