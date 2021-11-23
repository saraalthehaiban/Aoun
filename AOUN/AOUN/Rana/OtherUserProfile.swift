//
//  OtherUerProfile.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/11/2021.
//

import Foundation
import UIKit

class OtherUserProfile : ProfileDetailViewController {
    
    override func viewDidLoad() {
        self.initialize()
    }
    
    class func present(with user:User, on viewController : UIViewController) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let vc = appDelegate.viewController(storyBoardname: "OtherUserProfile", viewControllerId: "sbi_OtherUserProfile") as? OtherUserProfile {
            vc.user = user
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    @IBOutlet var chatButton : UIButton!
    
    @IBAction func chatButtonTouched_( sender:UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let chatViewController = appDelegate.viewController(storyBoardname: "Chat", viewControllerId: "sbi_ChatViewController") as? ChatViewController {
            chatViewController.otherUser = self.user
            self.present(chatViewController, animated: true, completion: nil)
        }
    }
    
    override func getName(completion: @escaping((String) -> ())) {
        completion(self.user.displayName)
    }//end of getName
    
    override func getEmail(completion: @escaping((String) -> ())) {
        completion("_")
    }//end of getEmail
 
    
    
    
    
    
    
    override func loadNotes (user:User){
        notes = []
        let query : Query = db.collection("Notes").whereField("uid", isEqualTo: user.uid)
        query.getDocuments ( completion:  {(snapShot, errror) in
            self.notesTable.tableHeaderView = nil
            guard let ds = snapShot, !ds.isEmpty else {
                //TODO: Add error handeling here
                let lable = UILabel()
                lable.textAlignment = .center
                lable.text = "No posted notes yet"
                lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                lable.sizeToFit()
                
                self.notesTable.tableHeaderView = lable
                self.notesTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                return
            }
            
            for doc in ds.documents {
                let data = doc.data()
                if let noteName = data["noteTitle"] as? String, let autherName  = data["autherName"] as? String, let desc = data["briefDescription"] as? String, let price = data["price"] as? String, let urlName = data["url"] as? String, let createDate = data["createDate"] as? Timestamp {
                    var newNote = NoteFile(id:doc.documentID, noteLable: noteName, autherName: autherName, desc: desc, price: price, urlString: urlName, docID: "", createDate:createDate)
                    newNote.documentId = doc.documentID
                    self.notes.append(newNote)
                }
            }
            DispatchQueue.main.async {
                self.notesTable.reloadData()
            }
        })
        
    }// end of load note
    
    override func loadResources(user:User){
        resources = []
        let query : Query = db.collection("Resources").whereField("uid", isEqualTo: user.uid)
        query.getDocuments ( completion:  {(snapShot, errror) in
                                
                                guard let ds = snapShot, !ds.isEmpty else {
                                    //TODO: Add error handeling here
                                    let lable = UILabel()
                                    lable.textAlignment = .center
                                    lable.text = "No posted resources yet"
                                    lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                                    lable.sizeToFit()
                                    
                                    self.resTable.tableHeaderView = lable
                                    self.resTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                                    return
                                }
                                
                                for doc in ds.documents {
                                    
                                    let data = doc.data()
                                    if let rName = data["ResName"] as? String, let aName  = data["authorName"] as? String, let pName = data["pubName"] as? String, let desc = data["desc"] as? String, let urlName = data["url"] as? String , let createDate = data["createDate"] as? Timestamp {
                                        var newRes = resFile(name: rName, author: aName, publisher: pName, desc: desc, urlString: urlName, createDate:createDate)
                                        newRes.documentId = doc.documentID
                                        self.resources.append(newRes)
                                        
                                        DispatchQueue.main.async {
                                            self.resTable.reloadData()
                                        }
                                    }
                                } })
        
    }// end of loadResources
    
    func loadWorkshops(user:User){
            workshop = []
            let query : Query = db.collection("Workshops").whereField("uid", isEqualTo: user.uid)
            query.getDocuments ( completion:  {(snapShot, errror) in
                                    
                                    guard let ds = snapShot, !ds.isEmpty else {
                                        //TODO: Add error handeling here
                                        let lable = UILabel()
                                        lable.textAlignment = .center
                                        lable.text = "No posted workshops yet"
                                        lable.textColor = UIColor(red: 0.0, green: 0.004, blue: 0.502, alpha: 1.0)
                                        lable.sizeToFit()
                                        
                                        self.workshopTable.tableHeaderView = lable
                                        self.workshopTable.reloadData()//reload table for blank record set (in case of deleting last object we need this)
                                        return
                                    }
                                    
                                    for doc in ds.documents {
                                        
                                        let data = doc.data()
                                        if let wName = data["title"] as? String, let pName  = data["presenter"] as? String, let p = data["price"] as? String, let se = data["seat"] as? String, let desc = data["desc"] as? String, let datetime = data["dateTime"] as? String, let auth = data["uid"] as? String {
                                            var newWorkshop = Workshops(Title: wName, presenter: pName, price: p, seat: se, description: desc, dateTime: datetime, uid: auth)
                                            newWorkshop.documentId = doc.documentID
                                            self.workshop.append(newWorkshop)
                                            
                                            DispatchQueue.main.async {
                                                self.workshopTable.reloadData()
                                            }
                                        }
                                    } })
            
        }// end of loadWorkshops
}
