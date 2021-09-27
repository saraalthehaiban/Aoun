//
//  resViewViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit
import Firebase
class resViewViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 140, height: 180)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resourcesName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! resourceCellCollectionViewCell
        cell.name.text = resourcesName[indexPath.row]
        return cell
    }
    
    
    

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var welcome1: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var icon: UIImageView!
  
    @IBOutlet weak var resIcon: UIImageView!
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    var resourcesName:[String] = ["swe","math","phy","swe111"]
    
    
    // dataBase
  
    //UI Filed
    let db = Firestore.firestore()
    //dummy data
   // var resources : [resFile] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nipCell = UINib(nibName: "resourceCellCollectionViewCell", bundle: nil)

        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        //tableView.delegate = self <-step 1
 
      //  loadResources()
        // Do any additional setup after loading the view.
    }
    

}
/*extension resViewViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RequestCell
        cell.name.text = resources[indexPath.row].name
        return cell
        
    }
    func loadResources(){
        resources = []
        db.collection("Request").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else { if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let rName = data["resName"] as? String {
                    let newRes = resFile(name : rName)
                    self.resources.append(newRes)

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
*/
