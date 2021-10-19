//
//  resViewViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit
import Firebase
import FirebaseStorage

class resViewViewController: UIViewController
{
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    var resources:[resFile] = []
    let db = Firestore.firestore()
    //dummy data
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nipCell = UINib(nibName: "resourceCellCollectionViewCell", bundle: nil)
        
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadResources()
    }
    
    func loadResources(){
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
                         
                            DispatchQueue.main.async {
                                self.collection.reloadData()
                            }
                        }
                    }
//                    DispatchQueue.main.async {
//                        self.collection.reloadData()
//                    }
                }
            }
        }
    }//end loadResources
}//end of class




extension resViewViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110)/2
        return CGSize(width: w, height: 160) //154
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! resourceCellCollectionViewCell
        cell.name.text = resources[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "si_resourceListToDetail", sender: indexPath)
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailedResViewController") as? detailedResViewController{
//            vc.resource = resources[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}//extention

//MARK:- Add Work

extension resViewViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewResToPost", let vc = segue.destination as? resPostViewController {
            vc.delegate = self
        } else if segue.identifier == "si_resourceListToDetail",
                  let vc = segue.destination as? detailedResViewController, let indexPath = sender as? IndexPath {
            vc.resource = resources[indexPath.row]
        }
    }
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
