//
//  AppDelegate.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    /* Do tasks when the app is lauched */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor(red: 45/255, green: 58/255, blue: 67/255, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().clipsToBounds = true
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 45/255, green: 58/255, blue: 67/255, alpha: 1.0)
        
        // Request access to notifications
        let centre = UNUserNotificationCenter.current()
        centre.requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification authorization denied")
            }
        }
        
        // Add a snooze option to the notifications
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let category = UNNotificationCategory(identifier: "UYLReminderCategory", actions: [snoozeAction], intentIdentifiers: [], options: [])
        centre.setNotificationCategories([category])

        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    /* Present the notification in foreground if one is received when inside the app (only for iOS 10+) */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    /* Schedual a new notification if user pressed Snooze */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "Snooze" {
            let receivedTitle = response.notification.request.content.title
            let receivedUUID = response.notification.request.identifier
            for id in uuid{
                if(id == receivedUUID){
                    uuid.insert(UUID().uuidString, at: uuid.index(of: receivedUUID)!+1)
                    UserDefaults.standard.set(uuid, forKey: "uuid")
                    print("uuid after inserting: \(uuid)\n")
                    scheduleSnoozeNotification(interval: 600, title: receivedTitle, id: uuid[uuid.index(of: receivedUUID)!+1])
                    print("snooze uuid: \(uuid[uuid.index(of: receivedUUID)!+1])\n")
                    break
                }
            }
        }
        completionHandler()
    }
    
    /* Schedual weekday-based notifications */
    func scheduleWeekdayNotifications(at date: Date, title: String, id: String, weekday: Int) {
        let calendar = Calendar(identifier: .gregorian)
        
        //let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
        var triggerDate = calendar.dateComponents([.weekday,.hour,.minute,], from: date)
        triggerDate.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "You know you want to!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "UYLReminderCategory"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("An error has occured when adding a weekday-based notification: \(error)")
            }
        })
    }
    
    /* Schedual one-time notifications */
    func scheduleOneTimeNotification(at date: Date, title: String, id: String) {
        let calendar = Calendar(identifier: .gregorian)
        
        let triggerDate = calendar.dateComponents([.year,.month,.day,.hour,.minute,], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "You know you want to!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "UYLReminderCategory"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("An error has occured when adding a one-time notification: \(error)")
            }
        })
    }
    
    /* Schedual reoccurring notifications */
    func scheduleReoccurringNotification(interval: Int, title: String, id: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "You know you want to!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "UYLReminderCategory"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("An error has occured when adding a reoccurring notification: \(error)")
            }
        })
    }
    
    /* Schedual a new notification when user snoozes a received notification */
    func scheduleSnoozeNotification(interval: Int, title: String, id: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "You know you want to!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "UYLReminderCategory"
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("An error has occured when adding a snooze notification: \(error)")
            }
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

/*extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}*/

/*if let topController = UIApplication.topViewController() {
 
 }*/


