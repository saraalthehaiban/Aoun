//
//  ViewNotesViewController.swift
//  AOUN
//
//  Created by Rasha on 19/09/2021.
//

import UIKit
import FirebaseStorage
import Firebase

enum NoteType : Int {
    case allNote = 0
    case myNote = 1
}

class ViewNotesViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var post: UIButton!
    
    @IBOutlet weak var noteTypeSegment: UISegmentedControl!
    
    let db = Firestore.firestore()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!

    var myNotes : [NoteFile] = [] {didSet {updateUpdateActiveNotes()}}
    var notes : [NoteFile] = [] {didSet {updateUpdateActiveNotes()}}
    private var activeNotes : [NoteFile] = [] {
        didSet {
            filtered = activeNotes
        }
    }
    private var filtered:[NoteFile] = [] {
        didSet {
            collection.reloadData()
        }
    }
    
    @IBAction func noteTypeValueChanged(_ sender: UISegmentedControl) {
        updateUpdateActiveNotes()
    }
    
    func updateUpdateActiveNotes () {
        let noteType = NoteType(rawValue: self.noteTypeSegment.selectedSegmentIndex) ?? .allNote
        activeNotes = (noteType == .allNote) ? notes : myNotes
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
        
        loadUserReference()
    }
    
    var purchasedNotesIds : [String] {
        get {
            return self.myNotes.map { $0.id }
        }
    }
    
    var user:QueryDocumentSnapshot?
    func loadUserReference()  {
        guard let userId = Auth.auth().currentUser?.uid else {
            //User is not logged in
            return
        }
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                self.user = querySnapshot?.documents.first
                self.purchasedNotes { notes, success in
                    if let ns = notes {
                        self.myNotes = ns
                    }
                    self.loadNotes()//purchased are loaded now load all notes
                }
            }
        }
    }
    
    func  purchasedNotes(_ complition: @escaping ([NoteFile]?, Bool)->Void) {
        guard let references = self.user?["purchasedNotes"] as? [DocumentReference] else {
            complition(nil, false)
            return
        }
        
        var counter = 0
        var ns : [NoteFile] = []
        for dr in references {
            dr.getDocument { snapshot, error in
                counter += 1
                if let e = error {
                    print (e.localizedDescription)
                } else {
                    if let data = snapshot?.data(), let documentID  = snapshot?.documentID {
                        if let newNote = self.note(with: data, documentID:documentID){
                            ns.append(newNote)
                        }
                    }
                }
                
                if counter == references.count {
                    DispatchQueue.main.async {
                        complition(ns, true)
                    }
                }
            }
        }
        
    }
    
    func loadNotes(){
        self.set(message: "Loading..")
        db.collection("Notes")
            .order(by: "createDate", descending: true)
            .getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    var lnotes : [NoteFile]=[]
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let newNote = self.note(with: data, documentID: doc.documentID) {
                            lnotes.append(newNote)
                        }
                    }
                    DispatchQueue.main.async {
                        self.notes = lnotes.filter {!self.purchasedNotesIds.contains($0.id) }
                        self.set(message:(self.notes.count == 0) ? "No notes." : nil)
                    }
                }
            }
        }
    }//end loadNotes
    
    func note(with data:[String:Any], documentID:String) -> NoteFile? {
        if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String, let auth = data["uid"] as? String , let createDate = data["createDate"] as? Timestamp{
            
            let newNote = NoteFile(id:documentID,  noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName, userId: auth, docID: documentID, createDate:createDate)
            return newNote
        }
        return nil
    }
    
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
            filtered = activeNotes.filter { $0.noteLable.localizedCaseInsensitiveContains(s) }
        } else {
            filtered = activeNotes
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
    }//end count
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteCellCollectionViewCell
        cell.noteLable.text = filtered[indexPath.row].noteLable
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        }
    }
}

extension ViewNotesViewController : PostNoteViewControllerDelegate  {
    func postNote (_ vc: PostNoteViewController, note:NoteFile?, added:Bool) {
        vc.dismiss(animated: true) {
            if added {
                self.loadNotes()
            }
        }
    }
}
