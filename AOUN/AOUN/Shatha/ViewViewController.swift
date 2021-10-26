//
//  ViewViewController.swift
//  AOUN
//
//  Created by shatha on 10/03/1443 AH.
//

import UIKit
import Firebase

class ViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, deleteNoteDelegate {
    func delAt(index : IndexPath) {
        self.loadNotes()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === notesTable {
            return notes.count
        }
        else if tableView === resTable {
            return resources.count
        }else {
            fatalError("Invalid table")
        }}
    
    
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
        } else {
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
        
        let ca = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(ca)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var waves: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var myNotes: UILabel!
    @IBOutlet weak var myRes: UILabel!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var resTable: UITableView!
    @IBOutlet weak var email: UILabel!
    var user : User!
    
    @IBAction func editButton(_ sender: UIButton) {
        performSegue(withIdentifier: "si_profileToEdit", sender: self.user)
        
    }
    
  
    
    
    var notes: [NoteFile] = []
    var resources:[resFile] = []
    var empty =  "No notes"
    let db = Firestore.firestore()
    
    fileprivate var selectedRow: Int?
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTable.register(UINib(nibName:"notesTableViewCell", bundle: nil), forCellReuseIdentifier: "notesTableViewCell")
        notesTable.delegate = self
        notesTable.dataSource = self
        loadNotes ()
        resTable.register(UINib(nibName:"ResTableViewCell", bundle: nil), forCellReuseIdentifier: "ResTableViewCell")
        resTable.delegate = self
        resTable.dataSource = self
        loadResources()
//        getName { [self] (name) in
//            self.fullName.text = name}
        
        getEmail { [self] (uEmail) in
            self.email.text = uEmail
        }
        //        saveButton.e  = true
        getName { [self] (name) in
            self.fullName.text = name}
    }
    
    func loadNotes (){
        notes = []
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let query : Query = db.collection("Notes").whereField("uid", isEqualTo: thisUserId)
        //        query.collection("Notes").getDocuments { querySnapshot, error in
        query.getDocuments ( completion:  {(snapShot, errror) in
            self.notesTable.tableHeaderView = nil
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                let lable = UILabel()
                lable.textAlignment = .center
                lable.text = "You haven’t posted any notes yet"
                lable.sizeToFit()
                
                self.notesTable.tableHeaderView = lable
                self.notesTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                return
            }
            
            for doc in ds.documents {
                let data = doc.data()
                if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String  {
                    var newNote = NoteFile(noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName)
                    newNote.documentId = doc.documentID
                    self.notes.append(newNote)
                }
            }
            DispatchQueue.main.async {
                self.notesTable.reloadData()
            }
        })
        
    }// end of load note
    
    func loadResources(){
        
        resources = []
        
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let query : Query = db.collection("Resources").whereField("uid", isEqualTo: thisUserId)
        
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
                                    if let rName = data["ResName"] as? String, let aName  = data["authorName"] as? String, let pName = data["pubName"] as? String, let desc = data["desc"] as? String, let urlName = data["url"] as? String {
                                        let newRes = resFile(name: rName, author: aName, publisher: pName, desc: desc, urlString: urlName)
                                        self.resources.append(newRes)
                                        
                                        DispatchQueue.main.async {
                                            self.resTable.reloadData()
                                        }
                                    }
                                } })
        
    }// end of loadResources
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === notesTable {
            selectedRow = indexPath.row
            if let vc = storyboard?.instantiateViewController(identifier: "deleteNote") as? VCDeleteNote {
                let note  = notes[indexPath.row]
                vc.delegate = self
                vc.index = indexPath
                vc.note = note
                self.present(vc, animated: true, completion: nil)
            }
        }
    }//function to view note details
    
    func getName(completion: @escaping((String) -> ())) {
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        //let docRefernce = db.collection("users").document(thisUserId)
        
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
    
    
    
    
}

//MARK: - Navigation
extension ViewViewController : VCEditProfileDelegate {
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




