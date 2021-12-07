//
//  viewWorkshopViewController.swift
//  AOUN
//
//  Created by Reema Turki on 28/03/1443 AH.
//

import UIKit
import Firebase
import FirebaseStorage


enum WorkshopType : Int {
    case all = 0
    case booked = 1
}
class viewWorkshopViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var post: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var workshopL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var workshopSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!

    let db = Firestore.firestore()
    private var workshops:[Workshops] = [] {didSet {updateActive()}}
    private var bookedWorkshops : [Workshops] = [] {didSet {updateActive()}}
    private var activeWorkshops : [Workshops] = [] {
        didSet {
            filtered = activeWorkshops
        }
    }
    var filtered:[Workshops] = [] {
        didSet {
            self.collection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post.layer.shadowColor = UIColor.black.cgColor
        post.layer.shadowOpacity = 0.25
        
        let nipCell = UINib(nibName: "workshopCellCollectionViewCell", bundle: nil)
        
        //
        collection.delegate = self
        collection.dataSource = self

        searchBar.delegate = self
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadWorkshops()
        loadBookedWorkshops()
    }

    @IBAction func wsSegmentValueChanged(_ sender: UISegmentedControl) {
        updateActive()
    }
    
    func updateActive() {
        guard let updateActive = WorkshopType(rawValue: self.workshopSegment.selectedSegmentIndex) else {return}
        self.activeWorkshops = (updateActive == .all) ? workshops : bookedWorkshops
        if activeWorkshops.count == 0 {
            self.set(message: "No records..")
        }
    }
    
    func loadWorkshops(){
        self.set(message: "Loading..")
        db.collection("Workshops").order(by: "dateTime", descending: true).getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }
            if let snapshotDocuments = querySnapshot?.documents{
                var ws : [Workshops] = []
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let wName = data["title"] as? String, let pName  = data["presenter"] as? String, let p = data["price"] as? String, let se = data["seat"] as? String, let desc = data["desc"] as? String, let datetime = data["dateTime"] as? Timestamp, let auth = data["uid"] as? String {
                        var newWorkshop = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                        newWorkshop.documentId = doc.documentID
                        ws.append(newWorkshop)
                    }
                }
                
                DispatchQueue.main.async {
                    self.workshops = ws
                }
            }
        }
    }//end loadWorkshops
    
    var purchasedTickets : [Ticket] = []
    func loadTicket (_ completion:@escaping (([Ticket]?)->Void)) {
        
        guard let appdelegate =  UIApplication.shared.delegate as? AppDelegate, let userId = appdelegate.thisUser.docID else {
            completion(nil)
            return
        }
        
        db.collection("Tickets").whereField("user", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }
            else if let snapshotDocuments = querySnapshot?.documents {
                var tickets :[Ticket] = []
                for document in snapshotDocuments {
                    if let ticket = Ticket(dictionary: document.data()) {
                        tickets.append(ticket)
                    }
                }
                completion(tickets)
            }
        }
    }
    
    func loadBookedWorkshops() {
        var counter = 0
        loadTicket { tickets in
            if let ts = tickets {
                var pw :  [Workshops] = []
                for t in ts {
                    self.db.collection("Workshops").document(t.workshop).getDocument { document, error in
                        counter += 1
                        guard let data = document?.data() else {return}
                        if let wName = data["title"] as? String,
                           let pName  = data["presenter"] as? String,
                           let p = data["price"] as? String,
                           let se = data["seat"] as? String,
                           let desc = data["desc"] as? String,
                           let datetime = data["dateTime"] as? Timestamp,
                           let auth = data["uid"] as? String {
                            var nw = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                            nw.documentId = document?.documentID
                            nw.purchasedDate = t.time
                            pw.append(nw)
                        }
                        
                        if tickets?.count == counter {
                            DispatchQueue.main.async {
                                self.bookedWorkshops = pw
                            }
                        }
                    }
                }
            }
        }
        
        
        /*
        db.collection("Workshops").order(by: "dateTime", descending: true).getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }
            else if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let wName = data["title"] as? String, let pName  = data["presenter"] as? String, let p = data["price"] as? String, let se = data["seat"] as? String, let desc = data["desc"] as? String, let datetime = data["dateTime"] as? Timestamp, let auth = data["uid"] as? String {
                        var newWorkshop = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                        newWorkshop.documentId = doc.documentID
                        self.workshops.append(newWorkshop)
                    }
                }
                
                DispatchQueue.main.async {
                    self.set(message:(self.workshops.count == 0) ? "No workshops yet." : nil)
                    self.collection.reloadData()
                }
            }
        }
         */
    }
    
    func set(message:String? = nil) {
        self.messageLabel.text = message
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchText: searchText)
    }
    
    func filter(searchText:String?) {
        if let s = searchText, s.count > 0 {
            filtered = activeWorkshops.filter { $0.Title.localizedCaseInsensitiveContains(s) }
            
        } else {
            filtered = activeWorkshops
        }
        
        set(message:(filtered.count == 0) ? "No results." : nil)

    }
}//end of class


extension viewWorkshopViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110)/2
        return CGSize(width: w, height: 160) //154
    }//end size
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filtered.count
    }//end count
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! workshopCellCollectionViewCell
        
        cell.name.text = filtered[indexPath.row].Title
        return cell
    }//end cell
    
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "si_viewWorkshopToDetails", sender: indexPath)
    }//end
    
}//extention

//MARK:- Add Work
extension viewWorkshopViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewWorkshopToPost", let vc = segue.destination as? postWorkshopViewController {
            vc.delegate = self
        } else if segue.identifier == "si_viewWorkshopToDetails", //change
            let vc = segue.destination as? WorkshopDetailsVC, let indexPath = sender as? IndexPath {
            vc.workshop = filtered[indexPath.item]
        }
    }//path for collectionView
}//extention

extension viewWorkshopViewController: postWorkshopViewControllerDelegate {
    func postWorkshop(_ vc: postWorkshopViewController, workshop: Workshops?, added: Bool){
        vc.dismiss(animated: true) {
            if added, let r = workshop {
                self.workshops.append(r)
                self.collection.reloadData()
            }
        }
    }
}//extention
