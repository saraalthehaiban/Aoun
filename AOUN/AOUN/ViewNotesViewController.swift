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
    
    var notes:[NoteFile] = []{
        didSet {
            self.filtered = notes
        }
    }
    let db = Firestore.firestore()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    //  var searchActive : Bool = false
    var filtered:[NoteFile] = []{
        didSet {
            self.collection.reloadData()
        }
    }
    
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
                        if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String, let auth = data["uid"] as? String , let createDate = data["createDate"] as? Timestamp{
                            let docId = doc.documentID
                            let newNote = NoteFile(id:doc.documentID,  noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName, userId: auth, docID: docId, createDate:createDate)
                            self.notes.append(newNote)
                        }
                    }
                    DispatchQueue.main.async {
                        self.set(message:(self.notes.count == 0) ? "No notes yet." : nil)
                        self.collection.reloadData()
                    }
                }
            }
        }
        //self.activityIndicator.stopAnimating()
    }//end loadNotes
    
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
            filtered = notes.filter { $0.noteLable.localizedCaseInsensitiveContains(s) }
        } else {
            filtered = notes
        }
        
        set(message:(filtered.count == 0) ? "No results." : nil)
    }
}//end class

//mark:-
extension ViewNotesViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110) / 2
        return CGSize(width: w, height: 154)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filtered.count

//        if(searchActive) {
//               return filtered.count
//           } else {
//        return resources.count
//           }
    }//end count
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteCellCollectionViewCell
        cell.noteLable.text = filtered[indexPath.row].noteLable

//        if(searchActive) {
//            cell.noteLable.text = (filtered.count > indexPath.row) ? filtered[indexPath.row].noteLable : ""
//        } else {
//        cell.noteLable.text = notes[indexPath.row].noteLable
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    let destinationVC = detailedNoteViewController()
        
     //   self.performSegue(withIdentifier: "si_noteListToDetail", sender: indexPath)
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
       if let vc = storyboard.instantiateViewController(withIdentifier: "detailedNoteViewController") as? detailedNoteViewController {
            vc.note = filtered[indexPath.row]
        vc.authID = filtered[indexPath.row].userId ?? ""
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
             vc.note = filtered[indexPath.item]

//            if searchActive && filtered.count != 0{
//                vc.note = filtered[indexPath.item]
//            } else {
//            vc.note = notes[indexPath.row]
//            }
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
