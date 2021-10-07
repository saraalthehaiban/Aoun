//
//  ViewNotesViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit
import FirebaseStorage
import Firebase

class ViewNotesViewController: UIViewController {
    
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var addNoteButton: UIButton!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var notes:[NoteFile] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
        
        let nipCell = UINib(nibName: "NoteCellCollectionViewCell", bundle: nil)
        
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
                        if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String  {
                            let newNote = NoteFile(noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName)
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
    }
    
}

//mark:-
extension ViewNotesViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.size.width - 110) / 2
        return CGSize(width: w, height: 154)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteCellCollectionViewCell
        cell.noteLable.text = notes[indexPath.row].noteLable
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "si_noteListToDetail", sender: indexPath)
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailedNoteViewController") as? detailedNoteViewController {
//            vc.note = notes[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}


//MARK:- Add Work
extension ViewNotesViewController  {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "si_viewNoteToPost", let vc = segue.destination as? PostNoteViewController {
            vc.delegate = self
        } else if segue.identifier == "si_noteListToDetail", let vc = segue.destination as? detailedNoteViewController, let indexPath = sender as? IndexPath {
            vc.note = notes[indexPath.row]
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
