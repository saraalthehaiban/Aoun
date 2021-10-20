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
        //        requests.remove(at: index.row)
        //        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesTableViewCell", for: indexPath) as! notesTableViewCell
        cell.contentView.isUserInteractionEnabled = false
        cell.noteTitle.text = notes[indexPath.row].noteLable
        return cell
    }
    
    
    
    
    @IBOutlet weak var waves: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var myNotes: UILabel!
    @IBOutlet weak var myRes: UILabel!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var resTable: UITableView!
    @IBOutlet weak var email: UILabel!
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
        loadResources()
        getName { [self] (name) in
            self.fullName.text = name}
       
        getEmail { [self] (uEmail) in
           self.email.text = uEmail
       }
//        let user = Auth.auth().currentUser
//        fullName.text = user?.displayName
        // Do any additional setup after loading the view.
    }
    func loadNotes (){
        notes = []
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let query : Query = db.collection("Notes").whereField("uid", isEqualTo: thisUserId)
//        query.collection("Notes").getDocuments { querySnapshot, error in
        query.getDocuments ( completion:  {(snapShot, errror) in
            
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                return
            }
            
            for doc in ds.documents {
                let data = doc.data()
                if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String  {
                    let newNote = NoteFile(noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName)
                    self.notes.append(newNote)
                    //                            self.EmptyTable.text = "";
                    DispatchQueue.main.async {
                        self.notesTable.reloadData()
                    }
                }
            }
        })
                                
        }// end of load note
    
    func loadResources(){
        
        resources = []
        
        guard let thisUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let query : Query = db.collection("Notes").whereField("uid", isEqualTo: thisUserId)
//        query.collection("Notes").getDocuments { querySnapshot, error in
        query.getDocuments ( completion:  {(snapShot, errror) in
            
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
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
        selectedRow = indexPath.row
        if let vc = storyboard?.instantiateViewController(identifier: "deleteNote") as? deleteNote {
            vc.TitleName = notes[indexPath.row].noteLable
            vc.authorname = notes[indexPath.row].autherName
            vc.descr = notes[indexPath.row].desc
            vc.pr = notes[indexPath.row].price!
            vc.delegate = self
            vc.index = indexPath
            self.present(vc, animated: true, completion: nil)
        }
    }//function to go to note details
    
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
