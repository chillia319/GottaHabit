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
    var refresh: Bool = false
    var rowDeleted: Int = 0
    
    /* Count how many rows are in the main page */
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return habits.count
    }
    
    /* Do tasks based on row index */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell") as! CustomCell
        
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
            cell.backgroundColor = UIColor(red: 0/255, green: 190/255, blue: 255/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 0/255, green: 200/255, blue: 255/255, alpha: 1.0)
        }
        return cell
    }
    
    /* Deselect row animation for better UX */
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* Do tasks when main page is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitsTable.estimatedRowHeight = 90
        habitsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    /* Do tasks when main page is appeared */
    override func viewDidAppear(_ animated: Bool) {
        // Extract information from local storage and set the values in this class
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
        }
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
        }
        if let tempUUID = uuidObject as? [String] {
            uuid = tempUUID
        }
        
        habitsTable.reloadData()
    }
    
    /* Development purpose only */
    @IBAction func RemoveAllNotifications(_ sender: Any) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /* Controls the Switches for suspending and resuming notifications */
    @IBAction func cellSwitchAction(_ sender: UISwitch) {
        let row = sender.tag
        if(sender.isOn){
            /*let delegate = UIApplication.shared.delegate as? AppDelegate
            let currentString = notificationsString[row]
           
            if(currentString.contains("At")){
                let line = currentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined()
                print("At \(line)")
            }else if(currentString.contains("Every")){
                let line = currentString.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined()
                let interval = 0
                
                if(currentString.contains("h") && currentString.contains("m")){
                    interval = line.
                    print("\(line)hm")
                }else if(currentString.contains("h")){
                    print("\(line)h")
                }else if(currentString.contains("m")){
                    print("\(line)m")
                }
                
            }*/
            
        }else{
            let center = UNUserNotificationCenter.current()
            var breakCount = 0
            var stop = false
            for index in 0..<uuid.count{
                if(stop == false){
                    if(row == 0){
                        var modifier = 0
                        while(uuid[index+modifier] != "break"){
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
            print (uuid)
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
            
            print ("\(uuid)\n")
            habits.remove(at: indexPath.row)
            notificationsString.remove(at: indexPath.row)
            
            // Make sure that when a row is deleted, the next row's "Switch" state does not get affected
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomCell
            if(indexPath.row+1 <= habits.count){
                let nextIndexPath = IndexPath(row: indexPath.row+1, section: 0)
                
                let nextCell = tableView.cellForRow(at: nextIndexPath) as! CustomCell
                currentCell.cellSwitch.isOn = nextCell.cellSwitch.isOn
            }
            
            habitsTable.reloadData()
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
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

