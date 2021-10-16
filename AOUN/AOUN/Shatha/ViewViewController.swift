//
//  ViewViewController.swift
//  AOUN
//
//  Created by shatha on 10/03/1443 AH.
//

import UIKit
import Firebase
class ViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesTableViewCell", for: indexPath) as! RequestCell
        cell.contentView.isUserInteractionEnabled = false
        cell.name.text = notes[indexPath.row].noteLable
        return cell
    }
    

    

    @IBOutlet weak var waves: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var myNotes: UILabel!
    @IBOutlet weak var myRes: UILabel!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var resTable: UITableView!
    var notes: [NoteFile] = []
    var empty =  "No notes"
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTable.register(UINib(nibName:"notesTableViewCell", bundle: nil), forCellReuseIdentifier: "notesTableViewCell")
//        tableView.register(UINib(nibName:"RCell", bundle: nil), forCellReuseIdentifier: "ci_RCell")
        notesTable.delegate = self
        notesTable.dataSource = self
//        loadCommunities ()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var Email: UILabel!
    
    func loadCommunities (){
        notes = []
        db.collection("Notes").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String  {
                            let newNote = NoteFile(noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName)
                            self.notes.append(newNote)
                            DispatchQueue.main.async {
//                                tableView.reloadData()
                    
                }
            }
            
        }
        
        
                }}}}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
