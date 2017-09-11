//
//  ViewController.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

var uuid: [[String]] = []
var timer: Timer!

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet var habitsTable: UITableView!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var leftBarItem: UIBarButtonItem!
    @IBOutlet var rightBarItem: UIBarButtonItem!
    @IBOutlet var quote: UILabel!
    @IBOutlet var quoteAuthor: UILabel!
    
    private var habits: [String] = []
    private var habitDetails: [String] = []
    private var notificationsString: [String] = []
    private var habitData: [Any] = []
    private var switchState: [Int] = []
    
    //private var tabPressed: Int = 0
    private var rowSelected: Int!
    private var colours: [UIColor] = []
    
    
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
            // Set the ribbon body width to the same width as the notification label
            cell.ribbonBody.frame = CGRect(x: 8, y: 6, width: cell.notificationsLabel.intrinsicContentSize.width, height: 16)
            cell.ribbonBody.isHidden = false
        }
        
        // Assign switches with tags for easy tracking
        cell.cellSwitch.tag = indexPath.row
        
        let reoccuringColour1 = UIColor(red:0.000, green:0.730, blue:1.000, alpha:1.000)
        let reoccuringColour2 = UIColor(red:0.000, green:0.770, blue:1.000, alpha:1.000)
        let standardColour1 = UIColor(red: 77/255, green: 200/255, blue: 199/255, alpha: 1.0)
        let standardColour2 = UIColor(red: 77/255, green: 215/255, blue: 199/255, alpha: 1.0)
        
        if(habitData[indexPath.row*3] as! Int == 4){
            if(indexPath.row == 0){
                cell.backgroundColor = reoccuringColour1
                if(colours.isEmpty){
                    colours = [reoccuringColour1]
                }else{
                    colours[0] = reoccuringColour1
                }
            }else{
                if(colours[indexPath.row-1] == reoccuringColour1){
                    cell.backgroundColor = reoccuringColour2
                    if(indexPath.row > colours.count-1){ // If the row hasn't been seen before
                        colours.append(reoccuringColour2)
                    }else{
                        colours[indexPath.row] = reoccuringColour2
                    }
                }else{
                    cell.backgroundColor = reoccuringColour1
                    if(indexPath.row > colours.count-1){ // If the row hasn't been seen before
                        colours.append(reoccuringColour1)
                    }else{
                        colours[indexPath.row] = reoccuringColour1                    }
                }
            }
        }else{
            /*if indexPath.row % 2 == 0 {
             cell.backgroundColor = UIColor(red: 77/255, green: 200/255, blue: 199/255, alpha: 1.0)
             }else{
             cell.backgroundColor = UIColor(red: 77/255, green: 215/255, blue: 199/255, alpha: 1.0)
             }*/
            if(indexPath.row == 0){
                cell.backgroundColor = standardColour1
                if(colours.isEmpty){
                    colours = [standardColour1]
                }else{
                    colours[0] = standardColour1
                }
            }else{
                if(colours[indexPath.row-1] == standardColour1){
                    cell.backgroundColor = standardColour2
                    if(indexPath.row > colours.count-1){ // If the row hasn't been seen before
                        colours.append(standardColour2)
                    }else{
                        colours[indexPath.row] = standardColour2
                    }
                }else{
                    cell.backgroundColor = standardColour1
                    if(indexPath.row > colours.count-1){ // If the row hasn't been seen before
                        colours.append(standardColour1)
                    }else{
                        colours[indexPath.row] = standardColour1
                    }
                }
            }
        }
        
        // Check whether a habit is expired
        if(habitData[indexPath.row*3] as! Int == 2){
            let calender = Calendar.current
            
            let currentTime = Date()
            
            let storedTime = habitData[indexPath.row*3+2] as! Date
            var STComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: storedTime)
            STComponents.second = 0
            let newStoredTime = calender.date(from: STComponents)!
            
            if(newStoredTime < currentTime){
                switchState[indexPath.row] = 0
                UserDefaults.standard.set(switchState, forKey: "switchState")
                cell.cellSwitch.isUserInteractionEnabled = false
                cell.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
                colours[indexPath.row] = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
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
    
    /* When a tab is presssed */
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 0){
            setTabPressed(0)
            navBar.topItem?.title = "All Habits"
            UIView.animate(withDuration: 0.2, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        } else if(item.tag == 1){
            setTabPressed(1)
            navBar.topItem?.title = "Today"
            UIView.animate(withDuration: 0.2, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        }
    }
    
    /* Set row height for each row */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(getTabPressed() == 1){
            if(habitData[indexPath.row*3] as! Int == 0){
                let todayDate = Date()
                let currentWeekday = Calendar.current.component(.weekday, from: todayDate)
                let days = habitData[indexPath.row*3+1] as! [Int]
                var show = false
                for day in days{
                    if(currentWeekday == day){
                        show = true
                        break
                    }
                }
                if(!show){
                    return 0
                }
            }else if(habitData[indexPath.row*3] as! Int == 1){
                let todayDate = Date()
                let currentMonthday = Calendar.current.component(.day, from: todayDate)
                let days = habitData[indexPath.row*3+1] as! [Int]
                var show = false
                for day in days{
                    if(currentMonthday == day){
                        show = true
                        break
                    }
                }
                if(!show){
                    return 0
                }
            }else if(habitData[indexPath.row*3] as! Int == 2){
                return habitsTable.rowHeight
            }else if(habitData[indexPath.row*3] as! Int == 3){
                return habitsTable.rowHeight
            }else if(habitData[indexPath.row*3] as! Int == 4){
                return habitsTable.rowHeight
            }
        }else if (getTabPressed() == 0){
            return habitsTable.rowHeight
        }
        return habitsTable.rowHeight
    }
    
    /* Do tasks before presenting another view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNewHabit" && habitsTable.isEditing {
            if let navVC = segue.destination as? UINavigationController{
                if let addHabitVC = navVC.viewControllers[0] as? AddHabitVC{
                    addHabitVC.rowPassed = rowSelected
                }
            }
        }
    }
    
    /* Deselect row animation for better UX */
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        if(habitsTable.isEditing){
            rowSelected = indexPath.row
            performSegue(withIdentifier: "segueToNewHabit", sender: self)
        }
    }
    
    /* Do tasks when the main page is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        // Highlight "All habits" tab by default
        tabBar.selectedItem = tabBar.items![0]
        
        habitsTable.estimatedRowHeight = 90
        habitsTable.rowHeight = UITableViewAutomaticDimension
        
        leftBarItem.title = "Edit"
        habitsTable.allowsSelectionDuringEditing = true
        
        // trigger "startTimer" when application enters foreground or becomes active
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.startTimer), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.startTimer), name:
            NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        //startTimer()
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /* Create a new timer and excute "reloadData" based on time interval */
    func startTimer(){
        if(timer==nil){
            print("timer started")
            timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector:#selector(ViewController.reloadData), userInfo: nil, repeats: true)
        }
    }
    
    /* reload table data */
    func reloadData(){
        if(!habitsTable.isEditing){
            habitsTable.reloadData()
            print("reloaded")
        }
    }
    
    /* Do tasks before the main page is appeared */
    override func viewWillAppear(_ animated: Bool) {
        // Extract information from local storage and set the values inside this class
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
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
        if let tempUUIDs = uuidObject as? [[String]] {
            uuid = tempUUIDs
        }
        if let temphabitData = habitDataObject as? [Any] {
            habitData = temphabitData
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
        startTimer()
    }
    
    /* Do tasks when the main page is appeared */
    override func viewDidAppear(_ animated: Bool) {
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
    
    //    /* Development purpose only */
    //    @IBAction func RemoveAllNotifications(_ sender: Any) {
    //        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    //        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    //    }
    
    /* When "Edit" is pressed, change it to "Done" and tell the system to start editing */
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if(habitsTable.isEditing){
            leftBarItem.title = "Edit"
            rightBarItem.isEnabled = true
            habitsTable.setEditing(false,animated:true)
        }else{
            leftBarItem.title = "Done"
            rightBarItem.isEnabled = false
            habitsTable.setEditing(true,animated:true)
        }
    }
    
    /* Move the relavant data when user moves a row */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempUUIDs = uuid[sourceIndexPath.row]
        uuid.remove(at: sourceIndexPath.row)
        uuid.insert(tempUUIDs, at: destinationIndexPath.row)
        
        let tempHabits = habits[sourceIndexPath.row]
        habits.remove(at: sourceIndexPath.row)
        habits.insert(tempHabits, at: destinationIndexPath.row)
        
        let tempHabitDetails = habitDetails[sourceIndexPath.row]
        habitDetails.remove(at: sourceIndexPath.row)
        habitDetails.insert(tempHabitDetails, at: destinationIndexPath.row)
        
        let tempNotificationString = notificationsString[sourceIndexPath.row]
        notificationsString.remove(at: sourceIndexPath.row)
        notificationsString.insert(tempNotificationString, at: destinationIndexPath.row)
        
        let tempHabitData0 = habitData[sourceIndexPath.row*3]
        let tempHabitData1 = habitData[sourceIndexPath.row*3+1]
        let tempHabitData2 = habitData[sourceIndexPath.row*3+2]
        for _ in 0...2{
            habitData.remove(at: sourceIndexPath.row*3)
        }
        habitData.insert(tempHabitData0, at: destinationIndexPath.row*3)
        habitData.insert(tempHabitData1, at: destinationIndexPath.row*3+1)
        habitData.insert(tempHabitData2, at: destinationIndexPath.row*3+2)
        
        
        let tempSwitchState = switchState[sourceIndexPath.row]
        switchState.remove(at: sourceIndexPath.row)
        switchState.insert(tempSwitchState, at: destinationIndexPath.row)
        
        UserDefaults.standard.set(uuid, forKey: "uuid")
        UserDefaults.standard.set(habits, forKey: "habits")
        UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
        UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
        UserDefaults.standard.set(habitData, forKey: "habitData")
        UserDefaults.standard.set(switchState, forKey: "switchState")
        
        habitsTable.reloadData()
        
        print ("UUIDs: \(uuid)")
        print ("habits: \(habits)")
        print ("notificationString: \(notificationsString)")
        print ("data: \(habitData)")
        print ("switchState: \(switchState)\n")
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
            let uuidsForResume = uuid[row]
            
            // Set the body content for notifications that need rescheduling
            var bodyContentForNotification: String = ""
            if(habitDetails[row] == ""){
                bodyContentForNotification = "It is time to " + habits[row] + "!"
            }else{
                bodyContentForNotification = habitDetails[row]
            }
            
            // Reschedual the notifications
            let notificationType = habitData[row*3] as! Int
            switch notificationType{
            case 0: // If current row needs weekday notifications
                let DaysForResume = habitData[row*3+1] as! [Int]
                for index in 0..<DaysForResume.count{
                    print("Resumed uuid: \(uuidsForResume[index])")
                    delegate?.scheduleWeekdayNotifications(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification,  id: uuidsForResume[index], weekday: DaysForResume[index])
                }
            case 1: // If current row needs monthly notifications
                let DaysForResume = habitData[row*3+1] as! [Int]
                for index in 0..<DaysForResume.count{
                    print("Resumed uuid: \(uuidsForResume[index])")
                    delegate?.scheduleMonthdayNotifications(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification,  id: uuidsForResume[index], monthday: DaysForResume[index])
                }
            case 2: // If current row needs one-time notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleOneTimeNotification(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
            case 3: // If current row does not need any notification which should not be triggerd since the switch is hidden
                print("BS there isn't even a switch")
            case 4: // If current row needs reoccuring notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleReoccurringNotification(interval: habitData[row*3+2] as! Int, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
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
            
            for index in 0..<uuid[row].count{
                center.removeDeliveredNotifications(withIdentifiers: [uuid[row][index]])
                center.removePendingNotificationRequests(withIdentifiers: [uuid[row][index]])
            }
        }
    }
    
    /* Do tasks when a row is being edited (deletion only for now) */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Remove all information related to that row
        if editingStyle == UITableViewCellEditingStyle.delete{
            let center = UNUserNotificationCenter.current()
            print ("UUIDs Before deletion: \(uuid)")
            // Cancel future notifications related to the row and delete UUIDs
            for index in 0..<uuid[indexPath.row].count{
                center.removeDeliveredNotifications(withIdentifiers: [uuid[indexPath.row][index]])
                center.removePendingNotificationRequests(withIdentifiers: [uuid[indexPath.row][index]])
            }
            uuid.remove(at: indexPath.row)
            UserDefaults.standard.set(uuid, forKey: "uuid")
            print ("UUIDs After deletion: \(uuid)\n")
            
            habits.remove(at: indexPath.row)
            habitDetails.remove(at: indexPath.row)
            notificationsString.remove(at: indexPath.row)
            switchState.remove(at: indexPath.row)
            print ("switchState after deletion: \(switchState)\n")
            // There are 3 elements reserved for each row's resume data, so delete all three
            for _ in 0...2{
                habitData.remove(at: (indexPath.row*3))
            }
            print ("habitData after deletion: \(habitData)\n")
            
            // Show quote is no row is present
            if(habits.isEmpty){
                quote.isHidden = false
                quoteAuthor.isHidden = false
            }
            
            habitsTable.reloadData()
            
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(habitData, forKey: "habitData")
            UserDefaults.standard.set(switchState, forKey: "switchState")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
