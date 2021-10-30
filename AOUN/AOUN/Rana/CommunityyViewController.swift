//
//  communityyViewController.swift
//  communityyViewController
//
//  Created by Macbook pro on 24/10/2021.
//

import UIKit
import Firebase
class CommunityViewController: UIViewController {

    @IBOutlet var requestCommunity: UIButton!
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var collection: UICollectionView!

    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var communities:[CommunityObject] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCommunity.layer.shadowColor = UIColor.black.cgColor
        requestCommunity.layer.shadowOpacity = 0.25
        let nipCell = UINib(nibName: "NoteCellCollectionViewCell", bundle: nil)
        
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadCommunities()
        
    }
    
    @IBAction func requestCommunity(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "RequestCommunity") as? RequestCommunityController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    func loadCommunities() {
        db.collection("Communities").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        let ID = doc.documentID
                        let data = doc.data()
                        if let description = data["Description"] as? String, let title  = data["Title"] as? String  {
                            let comminity = CommunityObject(description: description, title:title, ID:ID)
                            self.communities.append(comminity)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collection.reloadData()
                    }
                }
            }
        }
    }
}

//mark:-
extension CommunityViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110) / 2
        return CGSize(width: w, height: 154)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return communities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteCellCollectionViewCell
        cell.noteLable.text = communities[indexPath.row].title
        cell.noteIcon.image = UIImage(named:"Communities")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let storyboard = UIStoryboard(name: "CommunityHome", bundle: nil)
           if let vc = storyboard.instantiateViewController(identifier: "Community") as? Community{
            vc.ID = communities[indexPath.row].ID
            vc.name = communities[indexPath.row].title
            self.present(vc, animated: true, completion: nil)
    }

    }
}


//MARK:- Add Work
extension CommunityViewController  {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewToAddCommunity", let vc = segue.destination as? RequestCommunityController {
            //vc.delegate = self
        }
//        else if segue.identifier == "si_noteListToDetail", let vc = segue.destination as? detailedNoteViewController, let indexPath = sender as? IndexPath {
//            vc.note = communities[indexPath.row]
//        }
    }
}

//
//
//
//@ -7,7 +7,7 @@
//
//import UIKit
//import Firebase
//import IQKeyboardManagerSwift
////import IQKeyboardManagerSwift
//
//
//@main
//@ -15,7 +15,7 @@ class AppDelegate: UIResponder, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        FirebaseApp.configure()
//        IQKeyboardManager.shared.enable = true
//        //IQKeyboardManager.shared.enable = true
//
//        //setRoot()
//        return true
