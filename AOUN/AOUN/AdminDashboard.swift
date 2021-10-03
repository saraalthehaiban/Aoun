import UIKit
import Firebase



class AdminDashboard: UIViewController {


    @IBOutlet var EmptyTable: UILabel!
    @IBOutlet var tableView: UITableView!
    let db = Firestore.firestore()
    var requests : [Request] = []
    var empty =  "No new community requests"
    fileprivate var selectedRow: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName:"RequestCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        loadCommunities ()
        if requests.count == 0{
            EmptyTable.text = empty
        }

        
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
                    let id = doc.documentID
                    if let name = data["Title"] as? String , let des = data["Description"] as? String {
                        let newReq = Request(title: name, description: des, doc : id )
                    self.requests.append(newReq)

                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                }}        }
    }
    
        }

        
    }
    
}

extension AdminDashboard: UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.row
    if let vc = storyboard?.instantiateViewController(identifier: "CommunityDetailsViewController") as? CommunityDetailsViewController{
        vc.TitleName = requests[indexPath.row].title
        vc.desc = requests[indexPath.row].description
        vc.doc = requests[indexPath.row].doc
        vc.delegate = self
        vc.index = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
   }

}

extension AdminDashboard: CommunityDetailsViewControllerDelegate{
    func delAt(index : IndexPath) {
        requests.remove(at: index.row)
        tableView.reloadData()
    }
    
    
}
