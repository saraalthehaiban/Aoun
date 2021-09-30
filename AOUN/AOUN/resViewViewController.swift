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
        return resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! resourceCellCollectionViewCell
        cell.name.text = resources[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detailedResViewController") as? detailedResViewController
        
        vc!.resV = resources[indexPath.row].name
        vc!.authV = resources[indexPath.row].auther
        vc!.pubV = resources[indexPath.row].publisher
        vc!.linkV = resources[indexPath.row].link
        
        //**********FILES***********
        
        self.navigationController?.pushViewController(vc!, animated: true)
    
    }
    
    

    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var welcome1: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var icon: UIImageView!
  
   // @IBOutlet weak var resIcon: UIImageView!
    @IBOutlet weak var resL: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    var resources:[resFile] = []
 

    
    // dataBase
  
    //UI Filed
    let db = Firestore.firestore()
    //dummy data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nipCell = UINib(nibName: "resourceCellCollectionViewCell", bundle: nil)

        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
 
        loadResources()
        
        // Do any additional setup after loading the view.
    }
    
    func loadResources(){
        db.collection("Resources").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else { if let snapshotDocuments = querySnapshot?.documents{
                for doc in snapshotDocuments{
                   
                    let data = doc.data()
                    if let rName = data["resName"] as? String, let aName  = data["autherName"] as? String, let pName = data["pubName"] as? String, let linkName = data["link"] as? String/*, let urlName = data["url"] as? String */ {
                        let newRes = resFile(name: rName, auther: aName, publisher: pName, link: linkName/*, url: urlName*/)
                        self.resources.append(newRes)

                        DispatchQueue.main.async {
                            self.collection.reloadData()
                        }
                        
                }}        }
    }
        }}//end loadResources
   
}//end of class
