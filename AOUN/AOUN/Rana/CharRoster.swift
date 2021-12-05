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
class ChatViewController: JSQMessagesViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
    
            let n = Int(arc4random_uniform(1000))
    
            senderId = "anonymous" + String(n)
            senderDisplayName = senderId
        }
    }enum AnonMessageStatus {
        case sending
        case sent
        case delivered
    }
    
    class AnonMessage: JSQMessage {
        var status : AnonMessageStatus
        var id : Int
    
        public init!(senderId: String, status: AnonMessageStatus, displayName: String, text: String, id: Int?) {
            self.status = status
            
            if (id != nil) {
                self.id = id!
            } else {
                self.id = 0
            }
            
            
    
            super.init(senderId: senderId, senderDisplayName: displayName, date: Date.init(), text: text)
        }
    
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
In the class above we have extended the JSQMessage class and we have also added some new properties to track: the id and the status. We also added an initialisation method so we can specify the new properties before instantiating the JSQMessage class properly. We also added an enum that contains all the statuses the message could possibly have.

Returning to the ChatViewController, let’s add a few properties to the class that we will need:

    static let API_ENDPOINT = "http://localhost:4000";
    
    var messages = [AnonMessage]()
    var pusher: Pusher!
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
Now that’s done, let’s start customizing the controller to suit our needs. First, we will add some logic to the viewDidLoad method:

    override func viewDidLoad() {
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
In the above code, we started customizing the way our chat interface will look, using the parent class that has these properties already set. For instance, we are setting the incomingBubble to blue, and the outgoingBubble to green. We have also eliminated the avatar display because we do not need it right now.

The next thing we are going to do is override some of the methods that come with the parent controller so that we can display messages, customize the feel and more:

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if !isAnOutgoingMessage(indexPath) {
            return nil
        }
    
        let message = messages[indexPath.row]
    
        switch (message.status) {
        case .sending:
            return NSAttributedString(string: "Sending...")
        case .sent:
            return NSAttributedString(string: "Sent")
        case .delivered:
            return NSAttributedString(string: "Delivered")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return CGFloat(15.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message = addMessage(senderId: senderId, name: senderId, text: text, id: nil)
    
        if (message != nil) {
            postMessage(message: message as! AnonMessage)
        }
        
        finishSendingMessage(animated: true)
    }
    
    private func isAnOutgoingMessage(_ indexPath: IndexPath!) -> Bool {
        return messages[indexPath.row].senderId == senderId
    }
The next thing we are going to do is create some new methods on the controller that will help us post a new message. After that, we create a method to hit the remote endpoint which sends the message. Finally, we create a method to append the new message sent (or received) to the messages array:

    private func postMessage(message: AnonMessage) {
        let params: Parameters = ["sender": message.senderId, "text": message.text]
        hitEndpoint(url: ChatViewController.API_ENDPOINT + "/messages", parameters: params, message: message)
    }
    
    private func hitEndpoint(url: String, parameters: Parameters, message: AnonMessage? = nil) {
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
    
                if message != nil {
                    message?.id = (response.object(forKey: "ID") as! Int) as Int
                    message?.status = .sent
                    self.collectionView.reloadData()
                }
    
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addMessage(senderId: String, name: String, text: String, id: Int?) -> Any? {
        let status = AnonMessageStatus.sending
        
        let id = id == nil ? nil : id;
    
        let message = AnonMessage(senderId: senderId, status: status, displayName: name, text: text, id: id)
    
        if (message != nil) {
            messages.append(message as AnonMessage!)
        }
    
        return message
    }
Great. Now every time we send a new message, the didPressSend method will be triggered and all the other ones will fall into place nicely!

For the last piece of the puzzle, we want to create the method that listens for Pusher events and fires a callback when an event trigger is received:

    private func listenForNewMessages() {
        let options = PusherClientOptions(
            host: .cluster("PUSHER_CLUSTER")
        )
    
        pusher = Pusher(key: "PUSHER_KEY", options: options)
    
        let channel = pusher.subscribe("chatroom")
    
        channel.bind(eventName: "new_message", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let messageId = data["ID"] as! Int
                let author = data["sender"] as! String
                
                if author != self.senderId {
                    let text = data["text"] as! String
    
                    let message = self.addMessage(senderId: author, name: author, text: text, id: messageId) as! AnonMessage?
                    message?.status = .delivered
                    
                    let params: Parameters = ["ID":messageId]
                    self.hitEndpoint(url: ChatViewController.API_ENDPOINT + "/delivered", parameters: params, message: nil)
    
                    self.finishReceivingMessage(animated: true)
                }
            }
        })
        
        channel.bind(eventName: "message_delivered", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let messageId = (data["ID"] as! NSString).integerValue
                let msg = self.messages.first(where: { $0.id == messageId })
                
                msg?.status = AnonMessageStatus.delivered
                self.finishReceivingMessage(animated: true)
            }
        })
    
        pusher.connect()
    }

  app.post('/delivered', (req, res, next) => {
    let payload = {ID: ""+req.body.ID+""}
    pusher.trigger('chatroom', 'message_delivered', payload)
    res.json({success: 200})
  })
  
  app.post('/messages', (req, res, next) => {
    try {
      let payload = {
        text: req.body.text,
        sender: req.body.sender
      };
  
      db.run("INSERT INTO Messages (Sender, Message) VALUES (?,?)", payload.sender, payload.text)
        .then(query => {
          payload.ID = query.stmt.lastID
          pusher.trigger('chatroom', 'new_message', payload);
  
          payload.success = 200;
  
          res.json(payload);
        });
  
    } catch (err) {
      next(err)
    }
  });
  
  app.get('/', (req, res) => {
    res.json("It works!");
  });
  
  
  // ------------------------------------------------------
  // Catch errors
  // ------------------------------------------------------
  
  app.use((req, res, next) => {
      let err = new Error('Not Found');
      err.status = 404;
      next(err);
  });
  
  
  // ------------------------------------------------------
  // Start application
  // ------------------------------------------------------
  
  Promise.resolve()
    .then(() => db.open('./database.sqlite', { Promise }))
    .then(() => db.migrate({ force: 'last' }))
    .catch(err => console.error(err.stack))
    .finally(() => app.listen(4000, function(){
      console.log('App listening on port 4000!')
    }));
Here we define the entire logic of our backend application. We are also using SQLite to store the chat messages; this is useful to help identify messages. Of course, you can always change the way the application works to suite your needs.

The index.js file also has two routes where it receives messages from the iOS application and triggers the Pusher event which is picked up by the application.

The next file is the packages.json where we define the NPM dependencies:

  {
    "main": "index.js",
    "dependencies": {
      "bluebird": "^3.5.0",
      "body-parser": "^1.16.0",
      "express": "^4.14.1",
      "pusher": "^1.5.1",
      "sqlite": "^2.8.0"
    }
  }
You’ll also need a config.js file in the root directory:

  module.exports = {
      appId: '',
      key: '',
      secret: '',
      cluster: '',
  };
