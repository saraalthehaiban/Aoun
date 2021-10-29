//
//  Notificationcode.swift
//  Notificationcode
//
//  Created by Macbook pro on 27/10/2021.
//

import Foundation
import Firebase
import UserNotifications

let notificationCenter = UNUserNotificationCenter.current()
let options: UNAuthorizationOptions = [.alert, .sound, .badge]


func getNotificationSettings() {
  UNUserNotificationCenter.current().getNotificationSettings { settings in
    print("Notification settings: \(settings)")
  }
    
    
   
    
    notificationCenter.requestAuthorization(options: options) {
        (didAllow, error) in
        if !didAllow {
            print("User has declined notifications")
        }
    }
    
    notificationCenter.getNotificationSettings { (settings) in
      if settings.authorizationStatus != .authorized {
        // Notifications not allowed
      }
    }
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent()
        
        content.title = notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
    }
    
    
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
        
        
        
    };func application2(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
      ) {
        print("Failed to register: \(error)")
      }
    

}
