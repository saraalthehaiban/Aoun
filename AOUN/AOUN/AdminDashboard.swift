import UIKit
import Firebase

class AdminDashboard: UIViewController {


    @IBOutlet var tableView: UITableView!
    //UI Filed
    let db = Firestore.firestore()
    //dummy data
    var requests : [Request] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.delegate = self <-step 1
        tableView.dataSource = self
        tableView.register(UINib(nibName:"RequestCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        loadCommunities ()
        // Do any additional setup after loading the view.
    }
    

}
extension AdminDashboard: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RequestCell
        cell.name.text = requests[indexPath.row].title
        return cell
        
    }
    func loadCommunities (){
        requests = []
        db.collection("Request").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else { if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let name = data["Title"] as? String , let des = data["Description"] as? String {
                    let newReq = Request(title: name, description: des)
                    self.requests.append(newReq)

                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                }}        }
    }
    
    
        }}}

//extension AdminDashboard: UITableViewDelegate {<-step 2
 //   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //WHEN CLICKED AT
//    }
//}
