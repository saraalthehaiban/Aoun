//
//  OtherUerProfile.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/11/2021.
//

import Foundation
import UIKit

class OtherUserProfile : ProfileDetailViewController {
    @IBOutlet var chatButton : UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        self.initialize()
        
        self.loadNotes(user: self.user, noDataMessage: "No Notes.")
        self.loadResources(user: self.user, noDataMessage: "No Resourses.")
        self.loadWorkshops(user: self.user, noDataMessage: "No Workshops.")
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.notesTable {
            self.selectedRow = indexPath.row
            if let vc = appDelegate.viewController(storyBoardname: "Main", viewControllerId: "detailedNoteViewController") as? detailedNoteViewController{
                let note = notes[indexPath.row]
            vc.note = note
            vc.delegate = self
                vc.authID = note.userId ?? ""
                self.present(vc, animated: true, completion: nil)
            }
            
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let vc = storyboard.instantiateViewController(identifier: "deleteNote") as? deleteNote {
//                let note  = notes[indexPath.row]
//                vc.delegate = self
//                vc.index = indexPath
//                vc.note = note
//                self.present(vc, animated: true, completion: nil)
//            }
        }else{
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
 }


//MARK: Class Functions
extension OtherUserProfile {
    class func present(with user:User, on viewController : UIViewController) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let vc = appDelegate.viewController(storyBoardname: "OtherUserProfile", viewControllerId: "sbi_OtherUserProfile") as? OtherUserProfile {
            vc.user = user
            viewController.present(vc, animated: true, completion: nil)
        }
    }
}
extension OtherUserProfile : detailedNoteViewControllerDelegate {
    func detail(_ vc : detailedNoteViewController, notePurched:Bool) {
        
    }
}
