//
//  viewWorkshopViewController.swift
//  AOUN
//
//  Created by Reema Turki on 28/03/1443 AH.
//

import UIKit
import Firebase
import FirebaseStorage

class viewWorkshopViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var post: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var workshopL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    var workshops:[Workshops] = [] {
        didSet {
            self.filtered = workshops
        }
    }
    let db = Firestore.firestore()
    
    @IBOutlet weak var searchBar: UISearchBar!
//    var searchActive : Bool = false
    var filtered:[Workshops]! = [] {
        didSet {
            self.collection.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post.layer.shadowColor = UIColor.black.cgColor
        post.layer.shadowOpacity = 0.25
        
        let nipCell = UINib(nibName: "workshopCellCollectionViewCell", bundle: nil)
        
        //
        collection.delegate = self
        collection.dataSource = self
        
        searchBar.delegate = self
        ///
        
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadWorkshops()
    }
    
    func loadWorkshops(){
        self.set(message: "Loading..")
        db.collection("Workshops").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {

            if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                    let data = doc.data()
                    if let wName = data["title"] as? String, let pName  = data["presenter"] as? String, let p = data["price"] as? String, let se = data["seat"] as? String, let desc = data["desc"] as? String, let datetime = data["dateTime"] as? String, let auth = data["uid"] as? String {
                        let newWorkshop = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                        self.workshops.append(newWorkshop)
                    }
                }
                
                DispatchQueue.main.async {
                    self.set(message:(self.workshops.count == 0) ? "No workshops yet." : nil)
                    self.collection.reloadData()
                }
            }
        }
     }
    }//end loadWorkshops
    
    func set(message:String? = nil) {
        self.messageLabel.text = message
//        if let m = message, m.count > 0 {
//            self.messageLabel.text = m
//            self.messageLabel.isHidden = false
//        }else {
//            self.messageLabel.isHidden = false
//        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchText: searchText)
    }
    
    func filter(searchText:String?) {
        if let s = searchText, s.count > 0 {
            filtered = workshops.filter { $0.Title.localizedCaseInsensitiveContains(s) }
            
        } else {
            filtered = workshops
        }
        
        set(message:(filtered.count == 0) ? "No results." : nil)

    }
}//end of class


extension viewWorkshopViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110)/2
        return CGSize(width: w, height: 160) //154
    }//end size
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filtered.count
//        if(searchActive) {
//            return filtered.count
//        } else {
//            return workshops.count
//        }
    }//end count
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! workshopCellCollectionViewCell
        
        cell.name.text = filtered[indexPath.row].Title
        
//        if(searchActive) {
//            cell.name.text = (filtered.count > indexPath.row) ? filtered[indexPath.row].Title : ""
//        } else {
//            cell.name.text = workshops[indexPath.row].Title
//        }
        
        return cell
    }//end cell
    //
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        self.performSegue(withIdentifier: "si_viewWorkshopToDetails", sender: indexPath)
    //    }//end
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard =  UIStoryboard(name: "Resources", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "si_WorkshopDetailsVC") as? WorkshopDetailsVC {
            vc.workshop = filtered[indexPath.row]
            vc.authID = filtered[indexPath.row].uid ?? ""
            
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
}//extention

//MARK:- Add Work

extension viewWorkshopViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewWorkshopToPost", let vc = segue.destination as? postWorkshopViewController {
            vc.delegate = self
        } else if segue.identifier == "si_viewWorkshopToDetails", //change
                  let vc = segue.destination as? WorkshopDetailsVC, let indexPath = sender as? IndexPath {
            vc.workshop = filtered[indexPath.item]
            
//            if searchActive && filtered.count != 0 {
//                vc.workshop = filtered[indexPath.item]
//            } else {
//                vc.workshop = workshops[indexPath.row]
//            }
        }
    }//path for collectionView
}//extention

extension viewWorkshopViewController: postWorkshopViewControllerDelegate {
    func postWorkshop(_ vc: postWorkshopViewController, workshop: Workshops?, added: Bool){
        vc.dismiss(animated: true) {
            if added, let r = workshop {
                self.workshops.append(r)
                self.collection.reloadData()
            }
        }
    }
}//extention
