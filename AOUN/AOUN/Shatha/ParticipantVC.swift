//
//  ParticipantVC.swift
//  AOUN
//
//  Created by shatha on 28/11/2021.
//

import UIKit
import Firebase

class ParticipantVC: UIViewController {
    var workshop : Workshops!
    var tickets : [Ticket] = [] {
        didSet {
            self.participantTable.reloadData()
        }
    }
    var db = Firestore.firestore()

    @IBOutlet weak var participantTable: UITableView!
    @IBOutlet weak var workshopName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.participantTable.register(UINib(nibName: "PTableViewCell", bundle: .main), forCellReuseIdentifier: "ci_PTableViewCell")
        self.loadTickets(workShop: self.workshop)
        
        self.workshopName.text = self.workshop.Title
    }
    
    func loadTickets (workShop:Workshops) {
        guard let wsi = workshop.documentId else {return}
        let query : Query = db.collection("Tickets").whereField("workshop", isEqualTo: wsi)
        query.getDocuments ( completion:  {(snapShot, errror) in
            
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                let lable = UILabel()
                lable.textAlignment = .center
                lable.text = "No Tickets have been purchased yet"
                lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                lable.sizeToFit()
                
                self.participantTable.tableHeaderView = lable
                self.participantTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                return
            }

            var ts : [Ticket] = []
            for doc in ds.documents {
                let data = doc.data()
                if var t = Ticket(dictionary: data) {
                    t.documentID = doc.documentID
                    ts.append(t)
                }
            }
            DispatchQueue.main.async {
                self.tickets = ts
            }
        })
    }// end of loadWorkshops
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ParticipantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "ci_PTableViewCell") as! PTableViewCell
        c.ticket = tickets[indexPath.row]
        return c
    }
    
}
