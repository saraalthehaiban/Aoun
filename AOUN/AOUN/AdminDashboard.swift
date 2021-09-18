import UIKit
import Firebase

class AdminDashboard: UIViewController {


    @IBOutlet var tableView: UITableView!
    //UI Filed
    let db = Firestore.firestore()
    //dummy data
    var requests : [Request] = [
        Request(title: "SWE Level 4", description: "A group for SWE Level 4"),
        Request(title: "SWE Level 5", description: "A group for SWE Level 5"),
        Request(title: "SWE Level 6", description: "A group for SWE Level 6")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    /*
     func loadMessages() {
         
         db.collection(K.FStore.collectionName)
             .order(by: K.FStore.dateField)
             .addSnapshotListener { (querySnapshot, error) in
             
             self.messages = []
             
             if let e = error {
                 print("There was an issue retrieving data from Firestore. \(e)")
             } else {
                 if let snapshotDocuments = querySnapshot?.documents {
                     for doc in snapshotDocuments {
                         let data = doc.data()
                         if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                             let newMessage = Message(sender: messageSender, body: messageBody)
                             self.messages.append(newMessage)
                             
                             DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                 let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                 self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                             }
                         }
                     }
                 }
             }
         }
     }
     */

}
extension AdminDashboard: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        cell.textLabel?.text = "TEST"
        return cell
    }
    
    
}
