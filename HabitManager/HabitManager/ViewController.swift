//
//  ViewController.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var habitsTable: UITableView!
    
    var habits: [String] = []
    var notificationsString: [String] = []
    var uuid: [String] = []
    var resumeFuncData: [Any] = []
    var switchState: [Int] = []
    
    var refresh: Bool = false
    var rowDeleted: Int = 0
    
    /* Count how many rows are in the main page */
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return habits.count
    }
    
    /* Do tasks based on row index */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell") as! CustomCell
        let currentSwitchState: Int!
        
        // Fill the cell with information saved previously
        cell.habitLabel.text = habits[indexPath.row]
        cell.habitLabel.numberOfLines = 0
        cell.notificationsLabel.text = notificationsString[indexPath.row]
        if(notificationsString[indexPath.row] == "No Alert"){
            cell.cellSwitch.isHidden = true;
        }else{
            cell.cellSwitch.isHidden = false;
        }
        cell.cellSwitch.tag = indexPath.row
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 199/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 77/255, green: 205/255, blue: 199/255, alpha: 1.0)
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
    
    /* Set row height */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    /* Deselect row animation for better UX */
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* Do tasks when main page is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitsTable.estimatedRowHeight = 80
        habitsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    /* Do tasks when main page is appeared */
    override func viewDidAppear(_ animated: Bool) {
        // Extract information from local storage and set the values inside this class
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        let resumeFuncDataObject = UserDefaults.standard.object(forKey: "resumeFuncData")
        let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
        
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
        }
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
        }
        if let tempUUID = uuidObject as? [String] {
            uuid = tempUUID
        }
        if let tempResumeFuncData = resumeFuncDataObject as? [Any] {
            resumeFuncData = tempResumeFuncData
        }
        if let tempSwitchState = switchStateObject as? [Int] {
            switchState = tempSwitchState
        }
        
        habitsTable.reloadData()
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
            
            let notificationType = resumeFuncData[row*3] as! Int
            switch notificationType{
            case 0: // If current row needs weekday notifications
                let gregorianDaysString = resumeFuncData[row*3+1] as! String
                var dayCount = 0
                for day in gregorianDaysString.characters{
                    if Int("\(day)") != nil {
                        print("Resumed uuid: \(uuidsForResume[dayCount])")
                        delegate?.scheduleWeekdayNotifications(at: resumeFuncData[row*3+2] as! Date, title: habits[row], id: uuidsForResume[dayCount], weekday: Int("\(day)")!)
                    }
                    dayCount += 1
                }
            case 1: // If current row needs one-time notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleOneTimeNotification(at: resumeFuncData[row*3+2] as! Date, title: habits[row], id: uuidsForResume[0])
            case 2: // If current row does not need any notification which should not be triggerd since the switch is hidden
                print("BS there isn't even a switch")
            case 3: // If current row needs reoccuring notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleReoccurringNotification(interval: resumeFuncData[row*3+2] as! Int, title: habits[row], id: uuidsForResume[0])
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
            notificationsString.remove(at: indexPath.row)
            switchState.remove(at: indexPath.row)
            print ("switchState after deletion: \(switchState)\n")
            // There are 3 elements reserved for each row's resume data, so delete all three
            for _ in 0...2{
                self.resumeFuncData.remove(at: (indexPath.row*3))
            }
            print ("resumeFuncData after deletion: \(resumeFuncData)\n")
            
            habitsTable.reloadData()
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(resumeFuncData, forKey: "resumeFuncData")
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

