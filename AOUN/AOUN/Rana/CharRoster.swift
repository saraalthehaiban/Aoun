//
//  CharRoster.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 19/11/2021.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
    var chat : Chat!
    var user : User! {
        didSet {
            self.textLabel?.text = user.displayName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class VCChatRoster : UIViewController {
    @IBOutlet var tableView: UITableView!
    let db = Firestore.firestore()
    var chats : [Chat] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChat()
    }
    
    func loadChat () {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("Chats").whereField("users", arrayContains: uid).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error: ", e.localizedDescription)
            } else {
                guard let sds  = querySnapshot?.documents else {return}
                
                var cs : [Chat] = []
                for d in sds {
                    if var c = Chat(dictionary: d.data()) {
                        c.documentID = d.documentID
                        if let uid = Auth.auth().currentUser?.uid, let otherUserID = (c.users.filter { $0 != uid}).last {
                            d.reference.collection("thread")
                                .whereField("senderID", isEqualTo: otherUserID)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        c.unreadCount = threadQuery?.documents.count ?? 0
                                    }
                                    cs.append(c)
                                    self.chats = cs
                                })
                        }
                        self.chats = cs
                    }
                }
                
            }
        }
    }
}


extension VCChatRoster:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UserCell!
        if let c = tableView.dequeueReusableCell(withIdentifier: "ci_chatUser") as? UserCell {
            cell = c
        }else {
            cell = UserCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "ci_chatUser")
            cell.detailTextLabel?.textColor = .white
            cell.detailTextLabel?.backgroundColor = .green
            cell.accessoryType = .disclosureIndicator
        }
        let c = chats[indexPath.row]
        cell.detailTextLabel?.text = "\(c.unreadCount ?? 0)"
        c.loadOtherUser { user in
            cell?.user = user
        }
        cell.detailTextLabel?.layer.cornerRadius = (cell.detailTextLabel?.frame.size.width ?? 0) / 2
        cell.detailTextLabel?.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! UserCell
        self.performSegue(withIdentifier: "si_rosterToChat", sender: cell)
    }
}

///navigate
extension VCChatRoster {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = sender as? UserCell, let vc = segue.destination as? ChatViewController, let user = s.user {
            vc.otherUser = user
        }
    }
}
