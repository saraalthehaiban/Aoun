//
//  AppDelegate.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 18/09/2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift
import PayPalCheckout

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var thisUser : User! {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoaded"), object: nil, userInfo: nil)//trigger local notification will use it later
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        
        let config = CheckoutConfig(
            clientID: "AXv9g7HZI6zUH1f_ZAdauJfwi9hvocNKBs-r8J2n37e8FstRt_QojYEt4pmEzN76qWj8jjfd2HZHNT2I",
            returnUrl: "aoun.aoun://paypalpay",
            environment: .sandbox)
        Checkout.set(config: config)
        
        //        //start Rasha
        //        Auth.auth().signIn(withEmail: "rasha.alsughier@gmail.com", password: "123456") { result, error in
        //                    if let error = error, result == nil {
        //                        print(error)
        //                    } else {
        //                        print("Success:", result)
        //                    }
        //                }
        //        //end Rasha
        
        IQKeyboardManager.shared.enable = true
        
        
        
        //NOtificaion setting
        application.registerForRemoteNotifications()
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options:  authOption) { condition, error in
            //Check for authorization status and handle error
        }
        Messaging.messaging().delegate = self
        
        self.perform(#selector(setRoot), with: nil, afterDelay: 0.9)
        
        return true
    }
    
    func viewController (storyBoardname:String,viewControllerId:String) -> UIViewController {
        let sb = UIStoryboard(name: storyBoardname, bundle: .main)
        return sb.instantiateViewController(withIdentifier: viewControllerId)
    }
    
    @objc
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
                updateFirestorePushTokenIfNeeded()
            }
        }else {
            //set landing screen to be internal
            window?.rootViewController = viewController(storyBoardname: "Auth", viewControllerId: "si_LandingViewController")
        }
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            //  let usersRef = Firestore.firestore().collection("users_table").document(userID)
            //  usersRef.setData(["fcmToken": token], merge: true)
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

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken  = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func process(_ notification:UNNotification) {
        let userInfor = notification.request.content.userInfo
        print (userInfor)
        //UIApplication.shared.applicationIconBadgeNumber = 0
        //if let title
        //Perform user notification handeling
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {return}
//        let tokenDictionary = ["token":token]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FCMToken"), object: nil, userInfo: tokenDictionary)//trigger local notification will use it later
        self.updateToken(fcmToken: token)
    }
    
    func updateToken(fcmToken:String)  {
        guard let userId = Auth.auth().currentUser?.uid else {
            //User is not logged in
            return
        }
        let db = Firestore.firestore()
        let updateData = ["fcmToken":fcmToken]
        db.collection("users").whereField("uid", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                guard let user = querySnapshot?.documents.first  else {return}
                //"users/\(user?.documentID)"
                let fName = (user["FirstName"] as? String) ?? ""
                let lName = (user["LastName"] as? String) ?? ""
                self.thisUser = User(FirstName:fName , LastName: lName, uid: userId, docID: user.documentID)
                user.reference.updateData(updateData, completion: { error in
                    if let error = error {
                        print(error)
                    } else {
                    }
                })
            }
        }
    }
}
