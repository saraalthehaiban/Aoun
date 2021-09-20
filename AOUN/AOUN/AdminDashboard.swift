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
        //tableView.delegate = self <-step 1
        tableView.dataSource = self
        tableView.register(UINib(nibName:"RequestCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")

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
    
    
}

//extension AdminDashboard: UITableViewDelegate {<-step 2
 //   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //WHEN CLICKED AT
//    }
//}
