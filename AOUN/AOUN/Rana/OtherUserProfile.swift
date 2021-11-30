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
