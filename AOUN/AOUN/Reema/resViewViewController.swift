//
//  resViewViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//
import UIKit
import Firebase
import FirebaseStorage

class resViewViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate
{
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var post: UIButton!
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var resources:[resFile] = []{
        didSet {
            self.filtered = resources
        }
    }
    let db = Firestore.firestore()
    
    @IBOutlet weak var searchBar: UISearchBar!
    // var searchActive : Bool = false
    var filtered:[resFile] = []{
        didSet {
            self.collection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post.layer.shadowColor = UIColor.black.cgColor
        post.layer.shadowOpacity = 0.25
        
        let nipCell = UINib(nibName: "resourceCellCollectionViewCell", bundle: nil)
        
        //
        collection.delegate = self
        collection.dataSource = self
        
        searchBar.delegate = self
        ///
        
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadResources()
    }
    
    func loadResources(){
        // ********* add it to notes *******
        self.set(message: "Loading..")
        db.collection("Resources").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        
                        let data = doc.data()
                        if let rName = data["ResName"] as? String, let aName  = data["authorName"] as? String, let pName = data["pubName"] as? String, let desc = data["desc"] as? String, let urlName = data["url"] as? String {
                            let newRes = resFile(name: rName, author: aName, publisher: pName, desc: desc, urlString: urlName)
                            self.resources.append(newRes)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.set(message:(self.resources.count == 0) ? "No resources yet." : nil)
                        self.collection.reloadData()
                    }
                }
            }
        }
    }//end loadResources
    
    
    func set(message:String? = nil) {
        self.messageLabel.text = message
        //        if let m = message, m.count > 0 {
        //            self.messageLabel.text = m
        //            self.messageLabel.isHidden = false
        //        }else {
        //            self.messageLabel.isHidden = false
        //        }
    }//end set
    
    //search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchText: searchText)
    }
    
    func filter(searchText:String?) {
        if let s = searchText, s.count > 0 {
            filtered = resources.filter { $0.name.localizedCaseInsensitiveContains(s) }
        } else {
            filtered = resources
        }
        
        set(message:(filtered.count == 0) ? "No results." : nil)
    }
}//end of class

extension resViewViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110)/2
        return CGSize(width: w, height: 160) //154
    }//end size
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filtered.count
        
        //        if(searchActive) {
        //               return filtered.count
        //           } else {
        //        return resources.count
        //           }
    }//end count
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! resourceCellCollectionViewCell
        cell.name.text = filtered[indexPath.row].name
        
        //        if(searchActive) {
        //            cell.name.text = (filtered.count > indexPath.row) ? filtered[indexPath.row].name : ""
        //        } else {
        //        cell.name.text = resources[indexPath.row].name
        //        }
        return cell
    }//end cell
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "si_resourceListToDetail", sender: indexPath)
    }//end
}//extention

//MARK:- Add Work
extension resViewViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewResToPost", let vc = segue.destination as? resPostViewController {
            vc.delegate = self
        } else if segue.identifier == "si_resourceListToDetail",
                  let vc = segue.destination as? detailedResViewController, let indexPath = sender as? IndexPath {
            vc.resource = filtered[indexPath.item]
            
            //            if searchActive && filtered.count != 0 {
            //                vc.resource = filtered[indexPath.item]
            //            } else {
            //            vc.resource = resources[indexPath.row]
            //            }
        }
    }//path for collectionView
}//extention

extension resViewViewController: resPostViewControllerDelegate {
    func resPost(_ vc: resPostViewController, resource: resFile?, added: Bool){
        vc.dismiss(animated: true) {
            if added, let r = resource {
                self.resources.append(r)
                self.collection.reloadData()
            }
        }
    }
}//extention
