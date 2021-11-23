//
//  ViewViewController.swift
//  AOUN
//
//  Created by shatha on 10/03/1443 AH.
//

import UIKit
import Firebase

class ProfileDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, deleteNoteDelegate, deleteResDelegate, MyWorkshopDelegate{
    @IBOutlet weak var hc_noteTable: NSLayoutConstraint!
    @IBOutlet weak var hc_resourceTable: NSLayoutConstraint!
    @IBOutlet weak var hc_workshopTable: NSLayoutConstraint!
    
    @IBOutlet weak var noteToggleButton: UIButton!
    @IBOutlet weak var resourceToggleButton: UIButton!
    @IBOutlet weak var workshopToggleButton: UIButton!
    
    var K_TableHeights :  CGFloat = 0.0
    var user : User!
    @IBAction func changepass(_ sender: UIButton) {
    }
    @IBOutlet weak var waves: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var myNotes: UILabel!
    @IBOutlet weak var myRes: UILabel!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var resTable: UITableView!
    @IBOutlet weak var email: UILabel?
    
    @IBOutlet weak var workshopTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        callBalance()
        
        initialize()
    }
    
    func initialize () {
        self.K_TableHeights = (UIScreen.main.bounds.size.height - 532   ) / 2
        notesTable.register(UINib(nibName:"notesTableViewCell", bundle: nil), forCellReuseIdentifier: "notesTableViewCell")
        notesTable.delegate = self
        notesTable.dataSource = self
        
        notesTable.isHidden = true
        resTable.register(UINib(nibName:"ResTableViewCell", bundle: nil), forCellReuseIdentifier: "ResTableViewCell")
        resTable.delegate = self
        resTable.dataSource = self
        resTable.isHidden = true
        
        workshopTable.register(UINib(nibName:"WorkshopTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkshopTableViewCell")
        workshopTable.delegate = self
        workshopTable.dataSource = self
        workshopTable.isHidden = true
        
        getEmail { [self] (uEmail) in
            self.email?.text = uEmail
        }
        getName { [self] (name) in
            self.fullName.text = name
        }

        collapsAllTable(nil)
    }
    
    
    //TODO: This functions have no use as of now
    func delAt(index : IndexPath) {

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === notesTable {
            return notes.count
        }
        else if tableView === resTable {
            return resources.count
        } else if tableView === workshopTable {
            return workshop.count
        }else {
            fatalError("Invalid table")
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView === notesTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notesTableViewCell", for: indexPath) as! notesTableViewCell
            cell.contentView.isUserInteractionEnabled = false
            cell.noteTitle.text = notes[indexPath.row].noteLable
            return cell
        } else if tableView === resTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResTableViewCell", for: indexPath) as! ResTableViewCell
            cell.contentView.isUserInteractionEnabled = false
            cell.resTitle.text = resources[indexPath.row].name
            return cell
        } else if tableView === workshopTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkshopTableViewCell", for: indexPath) as! WorkshopTableViewCell
            cell.contentView.isUserInteractionEnabled = false
            cell.workshopName.text = workshop[indexPath.row].Title
            return cell
        }else {
            fatalError("Invalid table")
        }
        
    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This action will sign you out.", preferredStyle: .alert)
        let da = UIAlertAction(title: "Sign out", style: .destructive) { action in
            let auth = Auth.auth()
            
            do
            {
                try auth.signOut()
                //TODO: Set RootView
                let appD = UIApplication.shared.delegate as! AppDelegate
                appD.setRoot()
            }
            catch let signoutError {
                
                print(signoutError)
                
            }
        }
        alert.addAction(da)
        
        let ca = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }
    
   
    
    @IBAction func editButton(_ sender: UIButton) {
        performSegue(withIdentifier: "si_profileToEdit", sender: self.user)
        
    }
    
    func collapsAllTable (_ sender:UIButton?) {
        let state = sender?.isSelected
        noteToggleButton.isSelected = false
        resourceToggleButton.isSelected = false
        workshopToggleButton.isSelected = false
        sender?.isSelected = state ?? false
        self.hc_noteTable.constant = 0
        self.hc_resourceTable.constant = 0
        self.hc_workshopTable.constant = 0
    }
    
    @IBAction func openNote(_ sender: UIButton) {
        collapsAllTable(sender)
        notesTable.isHidden = false
        sender.isSelected = !sender.isSelected
        self.hc_noteTable.constant = (sender.isSelected) ? K_TableHeights : 0
    }
    
    @IBAction func openRes(_ sender: UIButton) {
        collapsAllTable(sender)
        resTable.isHidden = false
        sender.isSelected = !sender.isSelected
        self.hc_resourceTable.constant = (sender.isSelected) ? K_TableHeights : 0
    }
    
    @IBAction func openWorkshop(_ sender: UIButton) {
        collapsAllTable(sender)
        resTable.isHidden = false
        sender.isSelected = !sender.isSelected
        self.hc_workshopTable.constant = (sender.isSelected) ? K_TableHeights : 0
    }
    
    let db = Firestore.firestore()
    @IBOutlet var balanceLable: UILabel!
    
    func callBalance (){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                let user = querySnapshot?.documents.first
                let earned : Double = ((user?.data()["earned"] as? Double)) ?? 0
                self.balanceLable.text = String(earned) + " SAR"
                
                
            }
        }
        
    }
    
    
    var notes: [NoteFile] = []
    var resources:[resFile] = []
    var workshop:[Workshops] = []
    var empty =  "No notes"
    
    
    fileprivate var selectedRow: Int?
    
    
    func loadNotes (user:User){
        notes = []
        let query : Query = db.collection("Notes").whereField("uid", isEqualTo: user.uid)
        query.getDocuments ( completion:  {(snapShot, errror) in
            self.notesTable.tableHeaderView = nil
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                let lable = UILabel()
                lable.textAlignment = .center
                lable.text = "You haven’t posted any notes yet"
                lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                lable.sizeToFit()
                
                self.notesTable.tableHeaderView = lable
                self.notesTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                return
            }
            
            for doc in ds.documents {
                let data = doc.data()
                if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String, let createDate = data["createDate"] as? Timestamp {
                    var newNote = NoteFile(id:doc.documentID, noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName, docID: "", createDate:createDate)
                    newNote.documentId = doc.documentID
                    self.notes.append(newNote)
                }
            }
            DispatchQueue.main.async {
                self.notesTable.reloadData()
            }
        })
        
    }// end of load note
    
    func loadResources(user:User){
        resources = []
        let query : Query = db.collection("Resources").whereField("uid", isEqualTo: user.uid)
        query.getDocuments ( completion:  {(snapShot, errror) in
                                
                                guard let ds = snapShot, !ds.isEmpty else {
                                    //TODO: Add error handeling here
                                    let lable = UILabel()
                                    lable.textAlignment = .center
                                    lable.text = "You haven’t posted any resources yet"
                                    lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                                    lable.sizeToFit()
                                    
                                    self.resTable.tableHeaderView = lable
                                    self.resTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                                    return
                                }
                                
                                for doc in ds.documents {
                                    
                                    let data = doc.data()
                                    if let rName = data["ResName"] as? String, let aName  = data["authorName"] as? String, let pName = data["pubName"] as? String, let desc = data["desc"] as? String, let urlName = data["url"] as? String , let createDate = data["createDate"] as? Timestamp {
                                        var newRes = resFile(name: rName, author: aName, publisher: pName, desc: desc, urlString: urlName, createDate:createDate)
                                        newRes.documentId = doc.documentID
                                        self.resources.append(newRes)
                                        
                                        DispatchQueue.main.async {
                                            self.resTable.reloadData()
                                        }
                                    }
                                } })
        
    }// end of loadResources
    
    func loadWorkshops(user:User){
        workshop = []
        let query : Query = db.collection("Workshops").whereField("uid", isEqualTo: user.uid)
        query.getDocuments ( completion:  {(snapShot, errror) in
                                
                                guard let ds = snapShot, !ds.isEmpty else {
                                    //TODO: Add error handeling here
                                    let lable = UILabel()
                                    lable.textAlignment = .center
                                    lable.text = "You haven’t posted any workshops yet"
                                    lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                                    lable.sizeToFit()
                                    
                                    self.workshopTable.tableHeaderView = lable
                                    self.workshopTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                                    return
                                }
                                
                                for doc in ds.documents {
                                    
                                    let data = doc.data()
                                    if let wName = data["title"] as? String, let pName  = data["presenter"] as? String, let p = data["price"] as? String, let se = data["seat"] as? String, let desc = data["desc"] as? String, let datetime = data["dateTime"] as? String, let auth = data["uid"] as? String {
                                        var newWorkshop = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                                        newWorkshop.documentId = doc.documentID
                                        self.workshop.append(newWorkshop)
                                        
                                        DispatchQueue.main.async {
                                            self.workshopTable.reloadData()
                                        }
                                    }
                                } })
        
    }// end of loadWorkshops
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === resTable {
            selectedRow = indexPath.row
            let storyboard = UIStoryboard(name: "Resources", bundle: nil)
            if let vc = storyboard.instantiateViewController(identifier: "deleteResViewController") as? deleteResViewController {
                let  res = resources[indexPath.row]
                vc.delegate = self
                vc.index = indexPath
                vc.resource = res
                self.present(vc, animated: true, completion: nil)
            }
        }
        if tableView === notesTable {
            selectedRow = indexPath.row
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(identifier: "deleteNote") as? deleteNote {
                let note  = notes[indexPath.row]
                vc.delegate = self
                vc.index = indexPath
                vc.note = note
                self.present(vc, animated: true, completion: nil)
            }
        }
        if tableView === workshopTable {
            selectedRow = indexPath.row
          //Check this and correct it
            let storyboard = UIStoryboard(name: "ViewProfile", bundle: nil)
            if let vc = storyboard.instantiateViewController(identifier: "MyWorkshop") as? MyWorkshop {
                let  res = workshop[indexPath.row]
                vc.delegate = self
                vc.index = indexPath
                vc.workshop = res
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func getName(completion: @escaping((String) -> ())) {
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let query : Query = db.collection("users").whereField("uid", isEqualTo: thisUserId)
        
        query.getDocuments ( completion:  {(snapShot, errror) in
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                return
            }
            
            if let userData = ds.documents.last {
                let firstname = userData["FirstName"] as? String ?? ""
                let lastName = userData["LastName"] as? String ?? ""
                let fullName = firstname + ((lastName.count > 0) ? " \(lastName)" : "")
                let user = User(FirstName: firstname, LastName: lastName, uid: thisUserId)
                self.user = user
                self.user.docID = userData.documentID
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.thisUser != nil {
                    appDelegate.thisUser = self.user
                }
                self.loadNotes(user: user)
                self.loadResources(user:user)
                completion(fullName)
            }
        })
        
        
    }//end of getName
    
    func getEmail(completion: @escaping((String) -> ())) {
        let user = Auth.auth().currentUser
        if let user = user {
            let theEmail = user.email ?? ""
            completion(theEmail)
        }
        
    }//end of getEmail
    
    
    @IBAction func actionButtonTouched(_ sender: Any) {
        let activityViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let purchaseAction = UIAlertAction(title: "Edit Profile", style: .default) { action in
            self.editButton(UIButton())
        }
        activityViewController.addAction(purchaseAction)

        let logOutAction = UIAlertAction(title: "Sign out", style: .destructive) { action in
            self.logout(UIButton())
        }
        activityViewController.addAction(logOutAction)
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        activityViewController.addAction(cancleAction)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
}

//MARK: - Navigation
extension ProfileDetailViewController : VCEditProfileDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VCEditProfile {
            vc.user = self.user
            vc.delegate = self
        }
    }
    
    func editView (editVC: VCEditProfile, profile : User, updated:Bool) {
        getName { [self] (name) in
            self.fullName.text = name}
    }
}




