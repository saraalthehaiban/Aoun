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
                    if let c = Chat(dictionary: d.data()) {
                        cs.append(c)
                    }
                }
                self.chats = cs
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
            cell = UserCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ci_chatUser")
            cell.accessoryType = .disclosureIndicator
        }
        let c = chats[indexPath.row]
        c.loadOtherUser { user in
            cell?.user = user
        }
        
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
        
        
     func viewDidLoad() {
            super.viewDidLoad()

            let n = Int(arc4random_uniform(1000))

            senderId = "anonymous" + String(n)
            senderDisplayName = senderId

            inputToolbar.contentView.leftBarButtonItem = nil

            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())

            collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
            collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

            automaticallyScrollsToMostRecentMessage = true

            collectionView?.reloadData()
            collectionView?.layoutIfNeeded()
        }
    }
}
