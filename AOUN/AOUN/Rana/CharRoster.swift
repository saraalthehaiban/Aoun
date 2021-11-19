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


class VCChatRoster : UITableViewController {
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
                    if let c = Chat(dictionary: d.data()) {
                        cs.append(c)
                    }
                }
                self.chats = cs
            }
        }
    }
}


extension VCChatRoster {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ci_chatUser") as? UserCell
        let c = chats[indexPath.row]
        c.loadOtherUser { user in
            cell?.user = user
        }
        
        return cell ?? UITableViewCell()
    }
}



///navigate
extension VCChatRoster {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = sender as? UserCell, let vc = segue.destination as? ChatViewController, s.user != nil  {
            vc.otherUser = s.user
        }
    }
}
