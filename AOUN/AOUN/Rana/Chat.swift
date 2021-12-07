import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore

//MARK: -
struct Chat {
    var users: [String]
    var dictionary: [String: Any] {
        return ["users": users]
    }
    
    var documentID:String?
    var otherUser : User?
    var unreadCount : Int?
}

extension Chat {
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {return nil}
        self.init(users: chatUsers)
    }
    
    func loadOtherUser(_ complitation:@escaping(User)->()) {
        guard let uid = Auth.auth().currentUser?.uid, let otherUserID = (self.users.filter { $0 != uid}).last else {
            return
        }
        
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: otherUserID).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error:", e.localizedDescription)
            }else{
                guard let user = querySnapshot?.documents.first  else {return}
                //"users/\(user?.documentID)"
                let fName = (user["FirstName"] as? String) ?? ""
                let lName = (user["LastName"] as? String) ?? ""
                let ou =  User(FirstName:fName , LastName: lName, uid: otherUserID, docID: user.documentID)
                complitation(ou)
            }
        }
    }
    
    func unreadMessageCount(_ complitation:@escaping(Int)->()) {
        guard let uid = Auth.auth().currentUser?.uid, let otherUserID = (self.users.filter { $0 != uid}).last else {
            return
        }
        
        Firestore.firestore().collection("Chats").whereField("uid", isEqualTo: otherUserID).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error:", e.localizedDescription)
            }else{
                guard let user = querySnapshot?.documents.first  else {return}
                //"users/\(user?.documentID)"
                let fName = (user["FirstName"] as? String) ?? ""
                let lName = (user["LastName"] as? String) ?? ""
                let ou =  User(FirstName:fName , LastName: lName, uid: otherUserID, docID: user.documentID)
                complitation(0)
            }
        }
    }
}

//MARK: -
struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

//MARK: -
struct Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    var isRead : Bool
    var dictionary: [String: Any] {
        return [
            "id": id,
            "content": content,
            "created": created,
            "senderID": senderID,
            "senderName":senderName,
            "isRead": isRead
        ]
    }
}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let isRead = dictionary["isRead"] as? Bool
        else {return nil}
        self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName, isRead  : isRead)
    }
}

//MARK: -
extension Message: MessageType {
    
    var sender: SenderType {
        return ChatUser(senderId: senderID, displayName: senderName)
    }
    
    var messageId: String {
        return id
    }
    var sentDate: Date {
        return created.dateValue()
    }
    var kind: MessageKind {
        return .text(content)
    }
}

//MARK: -
class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate {
    var currentUser = Auth.auth().currentUser!
    var otherUser : User!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    var newMessageListner : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = otherUser.displayName
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.inputTextView.delegate = self
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
        
        if let mcl = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            mcl.textMessageSizeCalculator.outgoingAvatarSize = .zero
//            mcl.textMessageSizeCalculator.messae
            mcl.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.newMessageListner?.remove()
    }
    
    // MARK: - Custom messages handlers
    
    func createNewChat() {
        let users = [self.currentUser.uid, self.otherUser.uid]
        let data: [String: Any] = [
            "users":users
        ]
        
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    func loadChat() {
        
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats")
            .whereField("users", arrayContains: currentUser.uid)
        
        
        db.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createNewChat()
                }
                else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        
                        let chat = Chat(dictionary: doc.data())
                        //Get the chat which has user2 id
                        if ((chat!.users.contains(self.otherUser.uid))) {
                            
                            self.docReference = doc.reference
                            //fetch it's thread collection
                            self.newMessageListner = doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        for message in threadQuery!.documents {
                                            var msg = Message(dictionary: message.data())
                                            if msg?.senderID != self.currentUser.uid && msg?.isRead == false {
                                                msg?.isRead = true
                                                if let d = msg?.dictionary {
                                                    message.reference.updateData(d)
                                                }
                                            }
                                            self.messages.append(msg!)
                                        }
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                                    }
                                })
                            //list.remove()
                            return
                        } //end of if
                    } //end of for
                    self.createNewChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    
    private func insertNewMessage(_ message: Message) {
        
        messages.append(message)
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName,
            "isRead" : false
        ]
        
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            self.triggerNotification(message: message)
        })
    }
    
    func triggerNotification(message:Message)  {
        let db = Firestore.firestore()
        
        //
        db.collection("users").whereField("uid", isEqualTo: otherUser.uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                guard let user = querySnapshot?.documents.first, let fcmToken = user["fcmToken"] as? String else {
                    return
                }
                let appd = UIApplication.shared.delegate as? AppDelegate
                PushNotificationSender.sendPushNotification(to: fcmToken, title: "New message", body: "\(appd?.thisUser.displayName ?? "User") sent you a message.")
            }
        }
    }
    
    // MARK: - InputBarAccessoryViewDelegate
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName ?? "User", isRead: false)
        
        //messages.append(message)
        insertNewMessage(message)
        save(message)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension  ChatViewController:  UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var updatedText = textView.text ?? ""
        if let textRange = Range(range, in:updatedText) {
            updatedText = updatedText.replacingCharacters(in: textRange, with: text)
        }
        if updatedText.count > 240 {return false}
        
        return true
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController : MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.1039655283, green: 0.40598014, blue: 0.8277289271, alpha: 1) : #colorLiteral(red: 0.6924675703, green: 0.8397012353, blue: 0.9650663733, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController : MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "\(self.messages[indexPath.section].sentDate.displayString())", attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1),                         .foregroundColor: UIColor.lightGray])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
}

// MARK: - MessagesDataSource
extension ChatViewController : MessagesDataSource {
    func currentSender() -> SenderType {
        return ChatUser(senderId: currentUser.uid, displayName: currentUser.displayName ?? "Chat")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("No messages to display")
            return 0
        } else {
            return messages.count
        }
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let m = self.messages[indexPath.section]
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .right
            print("-", m.content, m.isRead)
            return NSAttributedString(string: (m.isRead ? "Read" : "Sent" ), attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: (m.isRead ? #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) : #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)), .paragraphStyle:paragraph
            ])
        }
        return nil
    }
}
