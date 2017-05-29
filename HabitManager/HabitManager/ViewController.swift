//
//  ViewController.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

var uuid: [String] = []

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet var habitsTable: UITableView!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var quote: UILabel!
    @IBOutlet var quoteAuthor: UILabel!
    
    var habits: [String] = []
    var habitDetails: [String] = []
    var notificationsString: [String] = []
    var habitsData: [Any] = []
    var switchState: [Int] = []
    
    var tabPressed: Int = 0
    
    /* Count how many rows are in the main page */
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return habits.count
    }
    
    /* Do tasks based on row index */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell") as! CustomCell
        let currentSwitchState: Int!
        
        // do these for each cell
        cell.habitLabel.text = habits[indexPath.row]
        cell.habitDetailsLabel.numberOfLines = 0
        cell.habitDetailsLabel.text = habitDetails[indexPath.row]
        cell.notificationsLabel.text = notificationsString[indexPath.row]
        cell.notificationsLabel.layer.zPosition = 1
        
        // If this row does not require notifications
        if(notificationsString[indexPath.row] == "No Alert"){
            cell.cellSwitch.isHidden = true
            cell.ribbonHead.isHidden = true
            cell.ribbonTail.isHidden = true
            cell.ribbonBody.isHidden = true
        }else{
            cell.cellSwitch.isHidden = false
            cell.ribbonHead.isHidden = false
            cell.ribbonTail.isHidden = false
            // Set the ribbon body width to the same as the notification label
            cell.ribbonBody.frame = CGRect(x: 8, y: 6, width: cell.notificationsLabel.intrinsicContentSize.width, height: 16)
            cell.ribbonBody.isHidden = false
        }
        
        // Assign switches with tags for easy tracking
        cell.cellSwitch.tag = indexPath.row
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 199/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 77/255, green: 210/255, blue: 199/255, alpha: 1.0)
        }
        
        // if a habit is expired
        if(habitsData[indexPath.row*3] as! Int == 1){
            let currentTime = Date()
            let storedTime = habitsData[indexPath.row*3+2] as! Date
            if(storedTime < currentTime){
                switchState[indexPath.row] = 0
                UserDefaults.standard.set(switchState, forKey: "switchState")
                cell.cellSwitch.isUserInteractionEnabled = false
                cell.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
            }else{
                switchState[indexPath.row] = 1
                UserDefaults.standard.set(switchState, forKey: "switchState")
                cell.cellSwitch.isUserInteractionEnabled = true
            }
        }else{
            cell.cellSwitch.isUserInteractionEnabled = true
        }
        
        // Ensures the state of the switches are always correct
        if(switchState.count > 0){
            if(cell.cellSwitch.isOn){
                currentSwitchState = 1
                if(currentSwitchState != switchState[indexPath.row]){
                    cell.cellSwitch.isOn = false
                }
            }else{
                currentSwitchState = 0
                if(currentSwitchState != switchState[indexPath.row]){
                    cell.cellSwitch.isOn = true
                }
            }
        }
        
        return cell
    }
    
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if (item.tag == 0){
            tabPressed = 0
            navBar.topItem?.title = "All Habits"
            UIView.animate(withDuration: 0.2, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        } else if(item.tag == 1){
            tabPressed = 1
            navBar.topItem?.title = "Today"
            UIView.animate(withDuration: 0.2, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        }
    }
    
    /* Set row height */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tabPressed == 1){
            if(habitsData[indexPath.row*3] as! Int == 0){
                let todayDate = Date()
                let currentWeekday = Calendar.current.component(.weekday, from: todayDate)
                let daysStr = habitsData[indexPath.row*3+1] as! String
                if(!daysStr.contains("\(currentWeekday)")){
                    return 0
                }
            }else if(habitsData[indexPath.row*3] as! Int == 1){
                return habitsTable.rowHeight
            }else if(habitsData[indexPath.row*3] as! Int == 2){
                return habitsTable.rowHeight
            }else if(habitsData[indexPath.row*3] as! Int == 3){
                return habitsTable.rowHeight
            }
        }else if (tabPressed == 0){
            return habitsTable.rowHeight
        }
        return habitsTable.rowHeight
    }
    
    /* Deselect row animation for better UX */
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* Do tasks when main page is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        // Highlight "All habits" by default
        tabBar.selectedItem = tabBar.items![0]

        habitsTable.estimatedRowHeight = 90
        habitsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    /* Do tasks when main page is appeared */
    override func viewDidAppear(_ animated: Bool) {
        // Extract information from local storage and set the values inside this class
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        let habitsDataObject = UserDefaults.standard.object(forKey: "habitsData")
        let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
        
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
        }
        if let tempHabitDetails = habitDetailsObject as? [String] {
            habitDetails = tempHabitDetails
        }
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
        }
        if let tempUUID = uuidObject as? [String] {
            uuid = tempUUID
        }
        if let tempHabitsData = habitsDataObject as? [Any] {
            habitsData = tempHabitsData
        }
        if let tempSwitchState = switchStateObject as? [Int] {
            switchState = tempSwitchState
        }
        
        // Hide quote is a row is present
        if(!habits.isEmpty){
            quote.isHidden = true
            quoteAuthor.isHidden = true
        }else{
            quote.isHidden = false
            quoteAuthor.isHidden = false
        }
        
        habitsTable.reloadData()
        
        // Check if notification access is given by the user, only checks if user added a habit which requires notification access
        let notificationAccess = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationAccess == [] && checkNotificationAccess{
            print("notifications not enabled")
            let alertController = UIAlertController(title: "Notification Not Enabled", message: "You can still use GottaHabit, but the functionalities will be extremly limited, enable notifications by going to Settings->GottaHabit->Notifications", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
            checkNotificationAccess = false
        }
    }
    
    /* Development purpose only */
    @IBAction func RemoveAllNotifications(_ sender: Any) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /* Controls the Switches for suspending and resuming notifications */
    @IBAction func cellSwitchAction(_ sender: UISwitch) {
        let row = sender.tag
        if(sender.isOn){
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            // Switch is on, store this information
            switchState[row] = 1
            UserDefaults.standard.set(switchState, forKey: "switchState")
            print("Switch states: \(switchState)")
            
            // Find the uuids that were assoiciated with this row
            var uuidsForResume: [String] = []
            var breakCount = 0
            var stop = false
            for index in 0..<uuid.count{
                if(stop == false){
                    if(row == 0){
                        var modifier = 0
                        while(uuid[index+modifier] != "break"){
                            uuidsForResume.append(uuid[index+modifier])
                            modifier += 1
                        }
                        stop = true
                    }else{
                        if(uuid[index] == "break"){
                            breakCount += 1
                        }
                        if(row == breakCount){ //bingo
                            var modifier = 1
                            while(uuid[index+modifier] != "break"){
                                uuidsForResume.append(uuid[index+modifier])
                                modifier += 1
                            }
                            stop = true
                        }
                    }
                }
            }
            
            // Set the body content for notifications that need rescheduling
            var bodyContentForNotification: String = ""
            if(habitDetails[row] == ""){
                bodyContentForNotification = "It is time to " + habits[row] + "!"
            }else{
                bodyContentForNotification = habitDetails[row]
            }
            
            // Reschedual the notifications
            let notificationType = habitsData[row*3] as! Int
            switch notificationType{
            case 0: // If current row needs weekday notifications
                let gregorianDaysString = habitsData[row*3+1] as! String
                var dayCount = 0
                for day in gregorianDaysString.characters{
                    if Int("\(day)") != nil {
                        print("Resumed uuid: \(uuidsForResume[dayCount])")
                        delegate?.scheduleWeekdayNotifications(at: habitsData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification,  id: uuidsForResume[dayCount], weekday: Int("\(day)")!)
                    }
                    dayCount += 1
                }
            case 1: // If current row needs one-time notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleOneTimeNotification(at: habitsData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
            case 2: // If current row does not need any notification which should not be triggerd since the switch is hidden
                print("BS there isn't even a switch")
            case 3: // If current row needs reoccuring notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleReoccurringNotification(interval: habitsData[row*3+2] as! Int, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
            default: // Should not trigger
                print("Unexpected case when reading notificationType from resumeFunData")
            }
        }// Remove notification requests assosiated with this row
        else{
            // Switch is off, store this information
            switchState[row] = 0
            UserDefaults.standard.set(switchState, forKey: "switchState")
            print("Switch states: \(switchState)")
            
            let center = UNUserNotificationCenter.current()
            var breakCount = 0
            var stop = false
            for index in 0..<uuid.count{
                if(stop == false){
                    if(row == 0){
                        var modifier = 0
                        while(uuid[index+modifier] != "break"){
                            print("Suspended uuid: \(uuid[index+modifier])")
                            center.removeDeliveredNotifications(withIdentifiers: [uuid[index+modifier]])
                            center.removePendingNotificationRequests(withIdentifiers: [uuid[index+modifier]])
                            modifier += 1
                        }
                        stop = true
                    }else{
                        if(uuid[index] == "break"){
                            breakCount += 1
                        }
                        if(row == breakCount){ //bingo
                            var modifier = 1
                            while(uuid[index+modifier] != "break"){
                                print("Suspended uuid: \(uuid[index+modifier])")
                                center.removeDeliveredNotifications(withIdentifiers: [uuid[index+modifier]])
                                center.removePendingNotificationRequests(withIdentifiers: [uuid[index+modifier]])
                                modifier += 1
                            }
                            stop = true
                        }
                    }
                }
            }
        }
    }
    
    /* Do tasks when a row is being edited (deletion only for now) */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Remove all information related to that row
        if editingStyle == UITableViewCellEditingStyle.delete{
            let center = UNUserNotificationCenter.current()
            var breakCount = 0
            var stop = false
            print ("UUIDs Before deletion: \(uuid)")
            // Delete UUIDs (a bit complecated since some rows have multiple UUIDs)
            for index in 0..<uuid.count{
                if(stop == false){
                    if(indexPath.row == 0){ //first row
                        if(uuid[0] != "break"){
                            center.removeDeliveredNotifications(withIdentifiers: [uuid[0]])
                            center.removePendingNotificationRequests(withIdentifiers: [uuid[0]])
                            uuid.remove(at: 0)
                        }else{
                            uuid.remove(at: 0) //delete "break"
                            stop = true
                        }
                    }else{ //not first row
                        if(uuid[index] == "break"){
                            breakCount += 1
                            if(breakCount == indexPath.row){
                                while(uuid[index+1] != "break"){
                                    center.removeDeliveredNotifications(withIdentifiers: [uuid[index+1]])
                                    center.removePendingNotificationRequests(withIdentifiers: [uuid[index+1]])
                                    uuid.remove(at: index+1)
                                }
                                uuid.remove(at: index+1) //delete "break"
                                stop = true
                            }
                        }
                    }
                }
            }
            UserDefaults.standard.set(uuid, forKey: "uuid")
            
            print ("UUIDs After deletion: \(uuid)\n")
            habits.remove(at: indexPath.row)
            habitDetails.remove(at: indexPath.row)
            notificationsString.remove(at: indexPath.row)
            switchState.remove(at: indexPath.row)
            print ("switchState after deletion: \(switchState)\n")
            // There are 3 elements reserved for each row's resume data, so delete all three
            for _ in 0...2{
                self.habitsData.remove(at: (indexPath.row*3))
            }
            print ("habitsData after deletion: \(habitsData)\n")
            
            // Show quote is no row is present
            if(habits.isEmpty){
                quote.isHidden = false
                quoteAuthor.isHidden = false
            }
            
            habitsTable.reloadData()
            
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(habitsData, forKey: "habitsData")
            UserDefaults.standard.set(switchState, forKey: "switchState")
        }
    }
    
    /*override var prefersStatusBarHidden: Bool {
     return true
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

