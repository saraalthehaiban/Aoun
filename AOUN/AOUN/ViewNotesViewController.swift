//
//  ViewNotesViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit
import FirebaseStorage
import Firebase

class ViewNotesViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var addNoteButton: UIButton!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var post: UIButton!
    
    var notes:[NoteFile] = []
    let db = Firestore.firestore()
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    var filtered:[NoteFile] = []
    
    @IBOutlet weak var delete: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
        post.layer.shadowColor = UIColor.black.cgColor
        post.layer.shadowOpacity = 0.25
        
        let nipCell = UINib(nibName: "NoteCellCollectionViewCell", bundle: nil)
        
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        
        collection.register(nipCell, forCellWithReuseIdentifier: "cell")
        
        loadNotes()
        
    }
    
    
    
    func loadNotes(){
        db.collection("Notes").getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String, let auth = data["uid"] as? String, let docId = doc.documentID as? String{
                            let newNote = NoteFile(noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName, userId: auth, docID: docId)
                            self.notes.append(newNote)
                            DispatchQueue.main.async {
                                self.collection.reloadData()
                            }
                        }
                    }
                }
            }
        }
        //self.activityIndicator.stopAnimating()
    }//end loadNotes
    
    //search
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filtered = notes.filter { $0.noteLable.localizedCaseInsensitiveContains(searchText) }
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
       
        self.collection.reloadData()
    }
}//end class

//mark:-
extension ViewNotesViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110) / 2
        return CGSize(width: w, height: 154)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(searchActive) {
               return filtered.count
           } else {
        return notes.count
           }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteCellCollectionViewCell
        
        if(searchActive) {
            cell.noteLable.text = (filtered.count > indexPath.row) ? filtered[indexPath.row].noteLable : ""
        } else {
        cell.noteLable.text = notes[indexPath.row].noteLable
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    let destinationVC = detailedNoteViewController()
        
     //   self.performSegue(withIdentifier: "si_noteListToDetail", sender: indexPath)
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
       if let vc = storyboard.instantiateViewController(withIdentifier: "detailedNoteViewController") as? detailedNoteViewController {
            vc.note = notes[indexPath.row]
        vc.authID = notes[indexPath.row].userId ?? ""
        vc.docID = notes[indexPath.row].docID
            self.present(vc, animated: true, completion: nil)
            
        }
    }
}



//MARK:- Add Work
extension ViewNotesViewController  {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewNoteToPost", let vc = segue.destination as? PostNoteViewController {
            vc.delegate = self
        } else if segue.identifier == "si_noteListToDetail", let vc = segue.destination as? detailedNoteViewController, let indexPath = sender as? IndexPath {
            if searchActive && filtered.count != 0{
                vc.note = filtered[indexPath.item]
            } else {
            vc.note = notes[indexPath.row]
            
            }
                    }
    }
}

extension ViewNotesViewController : PostNoteViewControllerDelegate  {
    func postNote (_ vc: PostNoteViewController, note:NoteFile?, added:Bool) {
        vc.dismiss(animated: true) {
            if added, let n = note {
                self.notes.append(n)
                self.collection.reloadData()
            }
        }
    }
}
