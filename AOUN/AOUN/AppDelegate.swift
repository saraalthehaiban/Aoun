//
//  AppDelegate.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/09/2021.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        //setRoot()
        return true
    }
    
    func viewController (storyBoardname:String,viewControllerId:String) -> UIViewController {
        let sb = UIStoryboard(name: storyBoardname, bundle: .main)
        return sb.instantiateViewController(withIdentifier: viewControllerId)
    }
    
    func setRoot () {
        let window = UIApplication.shared.windows.first
        if let cu =  Auth.auth().currentUser {//User is logged in
           //navigate to internal screens
            if cu.email == "u001@aoun.com" {//TODO: Update this logic for admin sign up later
                let vc = viewController(storyBoardname: "Admin", viewControllerId: "si_AdminDashboard")
                window?.rootViewController = vc
            } else {
                let vc = viewController(storyBoardname: "Main", viewControllerId: "userHome")
                window?.rootViewController = vc
            }
        }else {
            //set landing screen to be internal
            window?.rootViewController = viewController(storyBoardname: "Auth", viewControllerId: "si_LandingViewController")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

