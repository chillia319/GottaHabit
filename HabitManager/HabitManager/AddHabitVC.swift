//
//  AddHabitVC.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

var checkNotificationAccess: Bool = false

class AddHabitVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var repeatOptionsTitleLabel: UILabel!
    @IBOutlet var repeatOptionsLabel: UILabel!
    @IBOutlet var alertOptionsTitleLabel: UILabel!
    @IBOutlet var alertOptionsLabel: UILabel!
    
    @IBOutlet var modeToggle: UISegmentedControl!
    @IBOutlet var habitDescription: UITextField!
    @IBOutlet var habitSecondDescription: UITextField!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var intervalPicker: UIDatePicker!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var repeatOptionsTable: UITableView!
    @IBOutlet var repeatModeToggles: UISegmentedControl!
    
    @IBOutlet var startOptionsCell: UITableViewCell!
    @IBOutlet var timePickerCell: UITableViewCell!
    @IBOutlet var repeatOptionCell: UITableViewCell!
    @IBOutlet var alertOptionsCell: UITableViewCell!
    @IBOutlet var intervalPickerCell: UITableViewCell!
    
    public var rowPassed: Int = -1
    private static var rowBeingEdited: Int = -1
    private static var repeatMode: Int!
    private var selectedTime: Date!

    private static var weeklyDaysSelected: [Int] = []
    private static var monthlyDaysSelected: [Int] = []
    
    private var habits: [String] = []
    private var habitDetails: [String] = []
    private var notificationsString: [String] = []
    private var habitData: [Any] = []
    private var switchState: [Int] = []
    
    //private var timePickerVisible = false
    //private var intervalPickerVisible = false
    //private var firstRun = true
    //private var mode: Int = 0
    
    //private var selectedInterval: Int = 60
    //private var alertOptionsMode0Text: String = "Never"
    //private var alertOptionsMode1Text: String = "Every 1 minute"
    
    /* Disables "Save" button if no text is in the textfield */
    internal func checkDescription() {
        let description = habitDescription.text ?? ""
        saveButton.isEnabled = !description.isEmpty
    }
    
    /* Dynamically checks if there's text in the textfield as you type */
    @IBAction func habitDescriptionEntered(_ sender: Any) {
        checkDescription()
    }
    
    /* Toggles between "Standard" and "Reoccurring", set up the relevant interface */
    @IBAction func modeToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            setMode(0)
            setIntervalPickerVisible(0)
            // Temporary solution for unfinished "alert" option
            /*if(timeLabel.text == "None"){
             toggleAlertOptionsCell(enable: false)
             }*/
            toggleAlertOptionsCell(enable: false)
            alertOptionsLabel.text = String(cString: getAlertOptionsMode0Text())
        }else{
            setMode(1)
            setTimePickerVisible(0)
            toggleAlertOptionsCell(enable: true)
            alertOptionsLabel.text = String(cString: getAlertOptionsMode1Text())
        }
        updateTable(withAnimation: true)
    }
    
    /* If "Cancel" button is pressed, go back to the main page */
    @IBAction func cancel(_ sender: Any) {
        setMode(0)
        setIntervalPickerVisible(0)
        setTimePickerVisible(0)
        setSelectedInterval(Int32(60))
        setFirstRun(1)
        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "None"))
        setAlertOptionsMode1Text(UnsafeMutablePointer<Int8>(mutating: "Every 1 minute"))
        dismiss(animated: true, completion: nil)
    }
    
    /* When "Save" is tapped */
    @IBAction func save(_ sender: Any) {
        // Developer mode
        if(habitDescription.text == "#Add" && AddHabitVC.rowBeingEdited == -1){ // Add random habits
            if habitSecondDescription.text != ""{
                guard let times = Int(habitSecondDescription.text!) else{
                    print("Error converting summary string to integer")
                    return
                }
                randomlyGenHabits(numOfTimes: times)
            }else{
                randomlyGenHabits(numOfTimes: 10)
            }
        }else if(habitDescription.text == "#Delete" && AddHabitVC.rowBeingEdited == -1){ // Delete all habits
            habits = []
            habitDetails = []
            notificationsString = []
            habitData = []
            switchState = []
            uuid = []
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(habitData, forKey: "habitData")
            UserDefaults.standard.set(switchState, forKey: "switchState")
            UserDefaults.standard.set(uuid, forKey: "uuid")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            cellsExpanded = []
        }
        // User mode
        else{
            saveHabits()
        }
        // Go back to the main page
        setMode(0)
        setIntervalPickerVisible(0)
        setTimePickerVisible(0)
        setFirstRun(1)
        setSelectedInterval(Int32(60))
        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "None"))
        setAlertOptionsMode1Text(UnsafeMutablePointer<Int8>(mutating: "Every 1 minute"))
        dismiss(animated: true, completion: nil)
    }
    
    /*  Saves and process information entered by the user */
    private func saveHabits(){
        // Prepare the label that descripbes the notications
        var beautifiedTimeLabel = ""
        if(getMode() == 0){
            if(timeLabel.text == "None"){
                beautifiedTimeLabel = "No Alert"
            }else{
                if(repeatOptionsLabel.text == "Today only"){
                    beautifiedTimeLabel = "At " + timeLabel.text! + " Today"
                }else{
                    beautifiedTimeLabel = "At " + timeLabel.text! + " on " + repeatOptionsLabel.text!
                }
            }
        }else{
            beautifiedTimeLabel = String(cString: getAlertOptionsMode1Text())
        }
        
        var rowToInsert = -1
        var appendNeeded = false
        
        // If in New Habit Mode
        if(AddHabitVC.rowBeingEdited == -1){
            // Set up things for storing these arrays to user's local storage
            let habitsObject = UserDefaults.standard.object(forKey: "habits")
            let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
            let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
            let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
            
            // Find the correct row for the new habit to be added, also stores habit description to local storage
            if let tempHabits = habitsObject as? [String]{ //  if not the first habit
                habits = tempHabits
                if(selectedTime != nil && getMode() == 0){ // type 0, 1, 2
                    let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
                    if let temphabitData = habitDataObject as? [Any] {
                        habitData = temphabitData
                    }
                    for index in 0..<habits.count{
                        if(habitData[index*3] as! Int == 0 || habitData[index*3] as! Int == 1 || habitData[index*3] as! Int == 2){ // if this notification has a selected time
                            let result = selectedTime.compareTimeOnly(to: habitData[index*3+2] as! Date)
                            if(result.rawValue == -1){
                                rowToInsert = index
                                break
                            }
                        }
                    }
                    if(rowToInsert == -1){ // if didn't find a row to insert
                        appendNeeded = true
                    }
                }else if(selectedTime == nil && getMode() == 0){ // type 3
                    rowToInsert = 0
                }else if(getMode() == 1){ // type 4
                    let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
                    if let temphabitData = habitDataObject as? [Any] {
                        habitData = temphabitData
                    }
                    var type3Count = 0
                    for index in 0..<habits.count{
                        if(habitData[index*3] as! Int == 4){ // if this notification has a selected interval
                            if(Int(getSelectedInterval()) <= habitData[index*3+2] as! Int){ // found a bigger one
                                rowToInsert = index
                                break
                            }else if(index == habits.count-1 || (habitData[(index+1)*3] as! Int != 4 && habitData[(index+1)*3] as! Int != 3)){ // I am the biggest
                                rowToInsert = index+1
                                break
                            }
                        }else if(habitData[index*3] as! Int == 3){
                            type3Count += 1
                        }
                    }
                    if(rowToInsert == -1){ // no other type 4 are present
                        rowToInsert = type3Count
                    }
                }else{
                    assert(false, "FATAL: Unexpected insertion case")
                }
                
                if(appendNeeded){
                    habits.append(habitDescription.text!)
                }else{
                    habits.insert(habitDescription.text!, at: rowToInsert)
                }
            }else{ // if it is the first habit
                appendNeeded = true
                habits = [habitDescription.text!]
            }
            UserDefaults.standard.set(habits, forKey: "habits")
            
            // Store habit summary to user's local storage
            if let tempHabitDetails = habitDetailsObject as? [String] {
                habitDetails = tempHabitDetails
                if(appendNeeded){
                    habitDetails.append(habitSecondDescription.text!)
                }else{
                    habitDetails.insert(habitSecondDescription.text!, at: rowToInsert)
                }
            }else{
                habitDetails = [habitSecondDescription.text!]
            }
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            
            // Store the label to user's local storage so the main page can access and display
            if let tempNotificationsString = notificationsStringObject as? [String] {
                notificationsString = tempNotificationsString
                if(appendNeeded){
                    notificationsString.append(beautifiedTimeLabel)
                }else{
                    notificationsString.insert(beautifiedTimeLabel, at: rowToInsert)
                }
            }else{
                notificationsString = [beautifiedTimeLabel]
            }
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            
            // Store the state of the added switch to local storage (0 for "off" and 1 for "on")
            if let tempSwitchState = switchStateObject as? [Int] {
                switchState = tempSwitchState
                if(appendNeeded){
                    switchState.append(1)
                }else{
                    switchState.insert(1, at: rowToInsert)
                }
            }else{
                switchState = [1]
            }
            UserDefaults.standard.set(switchState, forKey: "switchState")
        }// If in Edit Mode
        else{
            // Remove old data to find the correct row for new data to be inserted
            habits.remove(at: AddHabitVC.rowBeingEdited)
            for _ in 0...2{
                habitData.remove(at: AddHabitVC.rowBeingEdited*3)
            }
            habitDetails.remove(at: AddHabitVC.rowBeingEdited)
            notificationsString.remove(at: AddHabitVC.rowBeingEdited)
            switchState.remove(at: AddHabitVC.rowBeingEdited)
            print("value of habitData is \(habitData)")
            if(selectedTime != nil && getMode() == 0){ // type 0, 1, 2
                for index in 0..<habits.count{
                    if(habitData[index*3] as! Int == 0 || habitData[index*3] as! Int == 1 || habitData[index*3] as! Int == 2){ // if this notification has a selected time
                        let result = selectedTime.compareTimeOnly(to: habitData[index*3+2] as! Date)
                        if(result.rawValue == -1){
                            rowToInsert = index
                            break
                        }
                    }
                }
                if(rowToInsert == -1){ // if didn't find a row to insert
                    appendNeeded = true
                }
            }else if(selectedTime == nil && getMode() == 0){ // type 3
                rowToInsert = 0
            }else if(getMode() == 1){ // type 4
                var type3Count = 0
                for index in 0..<habits.count{
                    if(habitData[index*3] as! Int == 4){ // if this notification has a selected interval
                        if(Int(getSelectedInterval()) <= habitData[index*3+2] as! Int){ // found a bigger one
                            rowToInsert = index
                            break
                        }else if(index == habits.count-1 || (habitData[(index+1)*3] as! Int != 4 && habitData[(index+1)*3] as! Int != 3)){ // I am the biggest
                            rowToInsert = index+1
                            break
                        }
                    }else if(habitData[index*3] as! Int == 3){
                        type3Count += 1
                    }
                }
                if(rowToInsert == -1){ // no other type 4 are present
                    rowToInsert = type3Count
                }
            }else{
                assert(false, "FATAL: Unexpected insertion case")
            }
            
            if(appendNeeded){
                habits.append(habitDescription.text!)
                habitDetails.append(habitSecondDescription.text!)
                notificationsString.append(beautifiedTimeLabel)
                switchState.append(1)
            }else{
                habits.insert(habitDescription.text!, at: rowToInsert)
                habitDetails.insert(habitSecondDescription.text!, at: rowToInsert)
                notificationsString.insert(beautifiedTimeLabel, at: rowToInsert)
                switchState.insert(1, at: rowToInsert)
            }
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(switchState, forKey: "switchState")
            
            let center = UNUserNotificationCenter.current()
            // Cancel future notifications related to the row and delete UUIDs
            for index in 0..<uuid[AddHabitVC.rowBeingEdited].count{
                center.removeDeliveredNotifications(withIdentifiers: [uuid[AddHabitVC.rowBeingEdited][index]])
                center.removePendingNotificationRequests(withIdentifiers: [uuid[AddHabitVC.rowBeingEdited][index]])
            }
        }
        
        /* ============================================================================================================ */
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        var bodyContentForNotification: String = ""
        var notificationType: Int!
        var notificationDays: [Int] = []
        
        if(habitSecondDescription.text?.isEmpty)!{
            bodyContentForNotification = "It is time to " + habitDescription.text! + "!"
        }else{
            bodyContentForNotification = habitSecondDescription.text!
        }
        
        // If in "Standard" mode, schedual the notifications based on time and day selected by the user
        if(selectedTime != nil && getMode() == 0){
            // Weekday based notification, type 0
            if(AddHabitVC.weeklyDaysSelected.count != 0){
                var tempUUIDs: [String] = []
                for index in 0..<AddHabitVC.weeklyDaysSelected.count{
                    
                    // Convert days selected by the user (stored in weeklyDaysSelected array) to gregorian format
                    var gregorianDay = AddHabitVC.weeklyDaysSelected[index]+2
                    // Sunday is 1, Monday is 2 ... Saturaday is 7
                    if(gregorianDay == 8){
                        gregorianDay = 1
                    }
                    // Generate an unique ID and store it in the tempUUID array
                    let tempUUID = UUID().uuidString
                    tempUUIDs.append(tempUUID)
                    delegate?.scheduleWeekdayNotifications(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: tempUUID, weekday: gregorianDay)
                    notificationDays.append(gregorianDay)
                }
                notificationType = 0
                checkNotificationAccess = true
                saveUUIDs(UUID: tempUUIDs, appendNeeded: appendNeeded, rowToInsert: rowToInsert)
                if(AddHabitVC.rowBeingEdited == -1){
                    if(appendNeeded){
                        print("Added multiple uuids: \(uuid[uuid.count-1])\n")
                    }else{
                        print("Added multiple uuids: \(uuid[rowToInsert])\n")
                    }
                }else{
                    if(appendNeeded){
                        print("Replaced with multiple uuids: \(uuid[uuid.count-1])\n")
                    }else{
                        print("Replaced with multiple uuids: \(uuid[rowToInsert])\n")
                    }
                }
            }// Month day based notification, type 1
            else if(AddHabitVC.monthlyDaysSelected.count != 0){
                var tempUUIDs: [String] = []
                for index in 0..<AddHabitVC.monthlyDaysSelected.count{
                    let tempUUID = UUID().uuidString
                    tempUUIDs.append(tempUUID)
                    delegate?.scheduleMonthdayNotifications(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: tempUUID, monthday: AddHabitVC.monthlyDaysSelected[index])
                    notificationDays.append(AddHabitVC.monthlyDaysSelected[index])
                }
                notificationType = 1
                checkNotificationAccess = true
                saveUUIDs(UUID: tempUUIDs, appendNeeded: appendNeeded, rowToInsert: rowToInsert)
                if(AddHabitVC.rowBeingEdited == -1){
                    if(appendNeeded){
                        print("Added multiple uuids: \(uuid[uuid.count-1])\n")
                    }else{
                        print("Added multiple uuids: \(uuid[rowToInsert])\n")
                    }
                }else{
                    if(appendNeeded){
                        print("Replaced with multiple uuids: \(uuid[uuid.count-1])\n")
                    }else{
                        print("Replaced with multiple uuids: \(uuid[rowToInsert])\n")
                    }
                }
            }// One time notification, type 2
            else{
                notificationType = 2
                checkNotificationAccess = true
                saveUUIDs(UUID: [UUID().uuidString], appendNeeded: appendNeeded, rowToInsert: rowToInsert)
                if(AddHabitVC.rowBeingEdited == -1){
                    if(appendNeeded){
                        delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                        print ("Added uuid: \(uuid[uuid.count-1])\n")
                    }else{
                        delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[rowToInsert][0])
                        print ("Added uuid: \(uuid[rowToInsert])\n")
                    }
                }else{
                    if(appendNeeded){
                        delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                        print ("Replaced with uuid: \(uuid[uuid.count-1])\n")
                    }else{
                        delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[rowToInsert][0])
                        print ("Replaced with uuid: \(uuid[rowToInsert])\n")
                    }
                }
            }
        }// If in "Standard" mode and no time is selected, type 3
        else if(selectedTime == nil && getMode() == 0){
            notificationType = 3
            saveUUIDs(UUID: ["none"], appendNeeded: appendNeeded, rowToInsert: rowToInsert)
        }// If in "Reoccurring" mode, schedual notifications based on interval specified by the user, type 4
        else if(getMode() == 1){
            notificationType = 4
            checkNotificationAccess = true
            saveUUIDs(UUID: [UUID().uuidString], appendNeeded: appendNeeded, rowToInsert: rowToInsert)
            if(AddHabitVC.rowBeingEdited == -1){
                if(appendNeeded){
                    delegate?.scheduleReoccurringNotification(interval: Int(getSelectedInterval()), title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                    print ("Added uuid: \(uuid[uuid.count-1])\n")
                }else{
                    delegate?.scheduleReoccurringNotification(interval: Int(getSelectedInterval()), title: habitDescription.text!, body: bodyContentForNotification, id: uuid[rowToInsert][0])
                    print ("Added uuid: \(uuid[rowToInsert])\n")
                }
            }else{
                if(appendNeeded){
                    delegate?.scheduleReoccurringNotification(interval: Int(getSelectedInterval()), title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                    print ("Replaced with uuid: \(uuid[uuid.count-1])\n")
                }else{
                    delegate?.scheduleReoccurringNotification(interval: Int(getSelectedInterval()), title: habitDescription.text!, body: bodyContentForNotification, id: uuid[rowToInsert][0])
                    print ("Replaced with uuid: \(uuid[rowToInsert])\n")
                }
            }
        }
        
        // Store backend data to local storage for functions like "resume" and "edit"
        if(AddHabitVC.rowBeingEdited == -1){
            
            // Retrieve habit data for type 3 and 4
            if habitData.isEmpty && habits.count != 0{
                let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
                if let temphabitData = habitDataObject as? [Any] {
                    habitData = temphabitData
                }
            }
            
            // Type
            if !habitData.isEmpty {
                if(appendNeeded){
                    habitData.append(notificationType)
                }else{
                    habitData.insert(notificationType, at: rowToInsert*3)
                }
            }else{
                habitData = [notificationType]
            }
            
            // Weekly Days/Monthly Days
            if(notificationDays != []){
                if(appendNeeded){
                    habitData.append(notificationDays)
                }else{
                    habitData.insert(notificationDays, at: rowToInsert*3+1)
                }
            }else{
                if(appendNeeded){
                    habitData.append(-1)
                }else{
                    habitData.insert(-1, at: rowToInsert*3+1)
                }
            }
            
            // Time/Interval
            if(notificationType == 3){
                if(appendNeeded){
                    habitData.append(-1)
                }else{
                    habitData.insert(-1, at: rowToInsert*3+2)
                }
            }else if(notificationType == 4){
                if(appendNeeded){
                    habitData.append(getSelectedInterval())
                }else{
                    habitData.insert(Int(getSelectedInterval()), at: rowToInsert*3+2)
                }
            }else{
                if(appendNeeded){
                    habitData.append(selectedTime)
                }else{
                    habitData.insert(selectedTime, at: rowToInsert*3+2)
                }
            }
        }else{
            if(appendNeeded){
                // Type
                habitData.append(notificationType)
                
                // Weekly Days/Monthly Days
                if(notificationDays != []){
                    habitData.append(notificationDays)
                }else{
                    habitData.append(-1)
                }
                
                // Time/Interval
                if(notificationType == 3){
                    habitData.append(-1)
                }else if(notificationType == 4){
                    habitData.append(Int(getSelectedInterval()))
                }else{
                    habitData.append(selectedTime)
                }
            }else{
                // Type
                habitData.insert(notificationType, at: rowToInsert*3)
                
                // Weekly Days/Monthly Days
                if(notificationDays != []){
                    habitData.insert(notificationDays, at: rowToInsert*3+1)
                }else{
                    habitData.insert(-1, at: rowToInsert*3+1)
                }
                
                // Time/Interval
                if(notificationType == 3){
                    habitData.insert(-1, at: rowToInsert*3+2)
                }else if(notificationType == 4){
                    habitData.insert(Int(getSelectedInterval()), at: rowToInsert*3+2)
                }else{
                    habitData.insert(selectedTime, at: rowToInsert*3+2)
                }
            }
        }
        print ("habits data: \(habitData)")
        UserDefaults.standard.set(habitData, forKey: "habitData")
    }
    
    /* Generates an unique ID if "UUID().uuidString" is the argument, store UUIDs to local storage */
    private func saveUUIDs(UUID: [String], appendNeeded: Bool, rowToInsert: Int){
        if(AddHabitVC.rowBeingEdited == -1){
            let uuidObject = UserDefaults.standard.object(forKey: "uuid")
            
            if let tempUUIDs = uuidObject as? [[String]]{
                uuid = tempUUIDs
                if(appendNeeded){
                    uuid.append(UUID)
                }else{
                    uuid.insert(UUID, at: rowToInsert)
                }
            }else{
                uuid = [UUID]
            }
        }else{
            uuid.remove(at: AddHabitVC.rowBeingEdited)
            if(appendNeeded){
                uuid.append(UUID)
            }else{
                uuid.insert(UUID, at: rowToInsert)
            }
        }
        
        UserDefaults.standard.set(uuid, forKey: "uuid")
    }
    
    /* Generate random habits for development purposes */
    private func randomlyGenHabits(numOfTimes: Int){
        var count = 1
        while(count <= numOfTimes){
            AddHabitVC.weeklyDaysSelected = []
            let randomModeChance = Int(arc4random_uniform(100))
            if(randomModeChance < 10){
                setMode(1)
            }else{
                setMode(0)
            }
            
            habitDescription.text = "Test " + String(count)
            let randomSummaryBool: UInt32 = arc4random_uniform(5)
            if(Int(randomSummaryBool) == 0){
                habitSecondDescription.text = ""
            }else{
                habitSecondDescription.text = "test "
                var randomWordCount: UInt32 = arc4random_uniform(20)+2
                while(Int(randomWordCount) != 0){
                    habitSecondDescription.text = habitSecondDescription.text! + "test "
                    randomWordCount -= 1
                }
            }
            
            if(getMode() == 0){
                let chance = Int(arc4random_uniform(100))
                if(chance < 5){ // notification type 3
                    timeLabel.text = "None"
                    selectedTime = nil
                }else{ // notification type 0, 1, 2
                    let currentTime = Date()
                    let calender = Calendar.current
                    var components = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentTime)
                    components.hour = Int(arc4random_uniform(25))
                    components.minute = Int(arc4random_uniform(61))
                    let randomTime = calender.date(from: components)!
                    timePicker.setDate(randomTime, animated: true)
                    timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
                    selectedTime = randomTime
                    
                    let type2Chance = Int(arc4random_uniform(100))
                    var randomDaysCount: UInt32
                    if(type2Chance < 5){
                        randomDaysCount = 0 // type 2
                    }else{
                        randomDaysCount = arc4random_uniform(7)+1 // type 0 and 1
                    }
                    while(Int(randomDaysCount) != 0){
                        var randomWeeklyDay: UInt32 = arc4random_uniform(7)
                        while(AddHabitVC.weeklyDaysSelected.contains(Int(randomWeeklyDay))){
                            randomWeeklyDay = arc4random_uniform(7)
                        }
                        AddHabitVC.weeklyDaysSelected.append(Int(randomWeeklyDay))
                        randomDaysCount -= 1
                    }
                    if(AddHabitVC.weeklyDaysSelected.count == 0){
                        repeatOptionsLabel.text = "Today only"
                    }else{
                        convertToString(reapeatMode: 0)
                    }
                }
            }else{ // notification type 4
                let randomHour: UInt32 = arc4random_uniform(24)
                var randomMinute: UInt32
                if(Int(randomHour) == 0){
                    randomMinute = arc4random_uniform(59)+1
                }else{
                    randomMinute = arc4random_uniform(60)
                }
                alertOptionsLabel.text = String(cString: convertIntervalAndDisplay(Int32(Int(randomHour)), Int32(randomMinute)))
                setSelectedInterval(Int32(Int(randomHour)*3600 + Int(randomMinute)*60))
            }
            saveHabits()
            count += 1
        }
    }
    
    /* updates table with/without animation */
    private func updateTable(withAnimation: Bool){
        if(withAnimation){
            tableView.beginUpdates()
            tableView.endUpdates()
        }else{
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    /* Enables or disables "Repeat" optinos cell */
    private func toggleRepeatOptionsCell(enable: Bool){
        if(enable){
            repeatOptionCell.isUserInteractionEnabled = true
            repeatOptionsTitleLabel.isEnabled = true
            repeatOptionsLabel.isEnabled = true
        } else{
            repeatOptionCell.isUserInteractionEnabled = false
            repeatOptionsTitleLabel.isEnabled = false
            repeatOptionsLabel.isEnabled = false
        }
    }
    
    /* Toggles between "Weekly" and "Monthly" mode inside repeat option cell */
    @IBAction func repeatOptionMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            AddHabitVC.repeatMode = 0
        }else{
            AddHabitVC.repeatMode = 1
        }
        updateTable(withAnimation: false)
    }
    
    /* Enables or disables "Alert" optinos cell */
    private func toggleAlertOptionsCell(enable: Bool){
        if(enable){
            alertOptionsCell.isUserInteractionEnabled = true
            alertOptionsTitleLabel.isEnabled = true
            alertOptionsLabel.isEnabled = true
        } else{
            alertOptionsCell.isUserInteractionEnabled = false
            alertOptionsTitleLabel.isEnabled = false
            alertOptionsLabel.isEnabled = false
        }
    }
    
    /* Stores value that's given by the date picker and make changes to the relevant UI */
    private func setTimelabelValue (){
        timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "At " + timeLabel.text!))
        alertOptionsLabel.text = String(cString: getAlertOptionsMode0Text())
        if(getFirstRun() == 1 && repeatOptionsLabel.text == "Never"){
            toggleRepeatOptionsCell(enable: true)
            //toggleAlertOptionsCell(enable: true)
            repeatOptionsLabel.text = "Today only"
            setFirstRun(0)
        }
    }
    
    /* Trigged by user spinning the date picker */
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        setTimelabelValue()
        selectedTime = sender.date
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowTimePicker (){
        if getTimePickerVisible() == 1 {
            setTimePickerVisible(0)
        } else {
            setTimePickerVisible(1)
        }
        updateTable(withAnimation: true)
    }
    
    /* Do tasks when interval picker is spinned */
    @IBAction func intervalPickerAction(_ sender: UIDatePicker) {
//        var selectedIntervalHours: Int
//        var selectedIntervalMinutes: Int
        
        setSelectedInterval(Int32(sender.countDownDuration))
        setSelectedIntervalHours(getSelectedInterval() / 3600)
        if getSelectedIntervalHours() == 0{
            setSelectedIntervalMinutes(getSelectedInterval() / 60)
        } else{
            setSelectedIntervalMinutes(getSelectedInterval() % 3600 / 60)
        }
        
        alertOptionsLabel.text = String(cString: convertIntervalAndDisplay(getSelectedIntervalHours(), getSelectedIntervalMinutes()))
        
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowInvervalPicker(){
        if getIntervalPickerVisible() == 1 {
            setIntervalPickerVisible(0)
        } else {
            setIntervalPickerVisible(1)
        }
        updateTable(withAnimation: true)
    }
    
    /* Do tasks when a certain row is selected */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(restorationIdentifier == "NewHabit"){
            // If certain row is selected, change the cell height
            if(indexPath.section == 1 && indexPath.row == 0) {
                toggleShowTimePicker()
            }else if(indexPath.section == 1 && indexPath.row == 3){
                toggleShowInvervalPicker()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }else if(restorationIdentifier == "RepeatOptions"){
            // Toggle the checkmarks based on row selected and mode selected when in "Repeat" options view
            
            if(AddHabitVC.repeatMode == 0){
                let rowsCount = tableView.numberOfRows(inSection: 1)
                let rowsCountForTheOtherSection = tableView.numberOfRows(inSection: 2)
                
                for row in 0..<rowsCount {
                    if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 1)) {
                        //cell.accessoryType = row == indexPath.row ? .checkmark : .none
                        if(indexPath.section == 1){
                            if(row == indexPath.row && cell.accessoryType == .none){
                                cell.accessoryType = .checkmark
                                AddHabitVC.weeklyDaysSelected.append(row)
                            }else if(row == indexPath.row && cell.accessoryType != .none){
                                cell.accessoryType = .none
                                let itemToRemove = row
                                if let index = AddHabitVC.weeklyDaysSelected.index(of: itemToRemove) {
                                    AddHabitVC.weeklyDaysSelected.remove(at: index)
                                }
                            }
                        }
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
                AddHabitVC.monthlyDaysSelected = []
                for row in 0..<rowsCountForTheOtherSection {
                    if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 2)) {
                        cell.accessoryType = .none
                    }
                }
            }else{
                let rowsCount = tableView.numberOfRows(inSection: 2)
                let rowsCountForTheOtherSection = tableView.numberOfRows(inSection: 1)
                
                for row in 0..<rowsCount {
                    if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 2)) {
                        if(indexPath.section == 2){
                            if(row == indexPath.row && cell.accessoryType == .none){
                                cell.accessoryType = .checkmark
                                AddHabitVC.monthlyDaysSelected.append(row+1)
                            }else if(row == indexPath.row && cell.accessoryType != .none){
                                cell.accessoryType = .none
                                let itemToRemove = row+1
                                if let index = AddHabitVC.monthlyDaysSelected.index(of: itemToRemove) {
                                    AddHabitVC.monthlyDaysSelected.remove(at: index)
                                }
                            }
                        }
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
                AddHabitVC.weeklyDaysSelected = []
                for row in 0..<rowsCountForTheOtherSection {
                    if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 1)) {
                        cell.accessoryType = .none
                    }
                }
            }
        }
    }
    
    /* Changes row heights if certain condition is met */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(restorationIdentifier == "NewHabit"){
            if(getMode() == 0){
                if(indexPath.section == 1 && indexPath.row == 4){
                    return 0
                }else if(getTimePickerVisible() == 0 && indexPath.section == 1 && indexPath.row == 1){
                    return 0
                }else {
                    if(indexPath.section == 1 && indexPath.row == 1){
                        return 216
                    }
                }
            }else{
                if(indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2)){
                    return 0
                }else if(getIntervalPickerVisible() == 0 && indexPath.section == 1 && indexPath.row == 4){
                    return 0
                }else{
                    if(indexPath.section == 1 && indexPath.row == 4){
                        return 216
                    }
                }
            }
        }else if(restorationIdentifier == "RepeatOptions"){
            if(AddHabitVC.repeatMode == 0){
                if(indexPath.section == 1){
                    return super.tableView.rowHeight
                }else if(indexPath.section == 2){
                    return 0
                }
            }else{
                if(indexPath.section == 1){
                    return 0
                }else if(indexPath.section == 2){
                    return super.tableView.rowHeight
                }
            }
        }
        return super.tableView.rowHeight
    }
    
    /* Hide extra space between weekly day section and monthly day section */
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(restorationIdentifier == "RepeatOptions" && AddHabitVC.repeatMode == 1){
            return  CGFloat.leastNormalMagnitude
        }
        return super.tableView.sectionFooterHeight
    }
    
    /* If user tapped "Return" button on his/her keyboard, then hide the keyboard */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* Do tasks when New Habit/Edit Habit page (includes two views) is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        
        if(restorationIdentifier == "NewHabit"){
            // Edit Mode
            if(rowPassed != -1){
                AddHabitVC.rowBeingEdited = rowPassed
                print("Edit Mode: row \(AddHabitVC.rowBeingEdited)")
                
                // Retrieve data from local storage
                let habitsObject = UserDefaults.standard.object(forKey: "habits")
                let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
                let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
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
                if let temphabitData = habitDataObject as? [Any] {
                    habitData = temphabitData
                }
                if let tempSwitchState = switchStateObject as? [Int] {
                    switchState = tempSwitchState
                }
                
                // If editing reccuring habit
                if(habitData[AddHabitVC.rowBeingEdited*3] as! Int == 4){
                    modeToggle.selectedSegmentIndex = 1
                    setMode(1)
                    
                    // Restore interval picker data
                    var storedIntervalMinutes: Int
                    setSelectedInterval(Int32(habitData[AddHabitVC.rowBeingEdited*3+2] as! Int))
                    
                    let storedIntervalHours = Int(getSelectedInterval() / 3600)
                    if storedIntervalHours == 0{
                        storedIntervalMinutes = Int(getSelectedInterval() / 60)
                    } else{
                        storedIntervalMinutes = Int(getSelectedInterval() % 3600 / 60)
                    }
                    alertOptionsLabel.text = String(cString: convertIntervalAndDisplay(Int32(storedIntervalHours), Int32(storedIntervalMinutes)))
                    var dateComp = DateComponents()
                    dateComp.hour = storedIntervalHours
                    dateComp.minute = storedIntervalMinutes
                    let calendar = Calendar(identifier: .gregorian)
                    let date = calendar.date(from: dateComp as DateComponents)!
                    intervalPicker.setDate(date as Date, animated: true)
                    
                    toggleRepeatOptionsCell(enable: false)
                    toggleAlertOptionsCell(enable: true)
                    AddHabitVC.repeatMode = 0
                    AddHabitVC.weeklyDaysSelected = []
                    AddHabitVC.monthlyDaysSelected = []
                }// If editing standard habit
                else{
                    // If a start time exists
                    AddHabitVC.weeklyDaysSelected = []
                    AddHabitVC.monthlyDaysSelected = []
                    
                    if(habitData[AddHabitVC.rowBeingEdited*3] as! Int != 3){
                        let time = habitData[AddHabitVC.rowBeingEdited*3+2] as! Date
                        timePicker.setDate(time, animated: true)
                        timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
                        selectedTime = timePicker.date
                        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "At " + timeLabel.text!))
                        alertOptionsLabel.text = String(cString: getAlertOptionsMode0Text())
                        
                        if(habitData[AddHabitVC.rowBeingEdited*3] as! Int  == 0){
                            AddHabitVC.weeklyDaysSelected = habitData[AddHabitVC.rowBeingEdited*3+1] as! [Int]
                            for index in 0..<AddHabitVC.weeklyDaysSelected.count{
                                if(AddHabitVC.weeklyDaysSelected[index] == 1){
                                    AddHabitVC.weeklyDaysSelected[index] = 6
                                }else{
                                    AddHabitVC.weeklyDaysSelected[index] -= 2
                                }
                            }
                        }else if(habitData[AddHabitVC.rowBeingEdited*3] as! Int  == 1){
                            AddHabitVC.monthlyDaysSelected = habitData[AddHabitVC.rowBeingEdited*3+1] as! [Int]
                        }
                    }// If no start time
                    else{
                        toggleRepeatOptionsCell(enable: false)
                        AddHabitVC.repeatMode = 0
                    }
                    toggleAlertOptionsCell(enable: false)
                }
                habitDescription.text = habits[AddHabitVC.rowBeingEdited]
                habitSecondDescription.text = habitDetails[AddHabitVC.rowBeingEdited]
            }// New Habit Mode
            else{
                AddHabitVC.rowBeingEdited = -1
                toggleAlertOptionsCell(enable: false)
                toggleRepeatOptionsCell(enable: false)
                AddHabitVC.repeatMode = 0
                AddHabitVC.weeklyDaysSelected = []
                AddHabitVC.monthlyDaysSelected = []
                
                //Work around for: DatePicker in CountDownTimer mode does not update countDownDuration after the first spin (possible system bug)
                var dateComp = DateComponents()
                dateComp.hour = 0
                dateComp.minute = 1
                let calendar = Calendar(identifier: .gregorian)
                let date = calendar.date(from: dateComp as DateComponents)!
                intervalPicker.setDate(date as Date, animated: true)
            }
            
            // Hide the keyboard when user tapped somewhere outside the textfield */
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
            
            checkDescription()
        }
    }
    
    /* Do tasks before a cell is displayed */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(restorationIdentifier == "RepeatOptions"){
            // Restore the checkmarks for "weekly" mode
            if(!AddHabitVC.weeklyDaysSelected.isEmpty && indexPath.section == 1){
                if(AddHabitVC.weeklyDaysSelected.contains(indexPath.row)){
                    cell.accessoryType = .checkmark
                }
            }// Restore the checkmarks for "monthly" mode
            else if(!AddHabitVC.monthlyDaysSelected.isEmpty && indexPath.section == 2){
                if(AddHabitVC.monthlyDaysSelected.contains(indexPath.row+1)){
                    cell.accessoryType = .checkmark
                }
            }
        }
    }
    
    /* Do tasks before a view is loaded */
    override func viewWillAppear(_ animated: Bool) {
        if(restorationIdentifier == "RepeatOptions"){
            title = "Repeat"
            if(!AddHabitVC.weeklyDaysSelected.isEmpty){
                AddHabitVC.repeatMode = 0
                repeatModeToggles.selectedSegmentIndex = 0
            }else if(!AddHabitVC.monthlyDaysSelected.isEmpty){
                AddHabitVC.repeatMode = 1
                repeatModeToggles.selectedSegmentIndex = 1
                print("Monthly days selected: \(AddHabitVC.monthlyDaysSelected)")
            }else{
                repeatModeToggles.selectedSegmentIndex = AddHabitVC.repeatMode
            }
        }else if(restorationIdentifier == "NewHabit"){
            if(AddHabitVC.rowBeingEdited != -1){
                title = "Edit Habit"
            }else{
                title = "New Habit"
            }
            
            if(!repeatOptionsLabel.isEnabled){
                repeatOptionsLabel.text = "Never"
            }else if(!AddHabitVC.weeklyDaysSelected.isEmpty){
                convertToString(reapeatMode: 0)
            }else if(!AddHabitVC.monthlyDaysSelected.isEmpty){
                convertToString(reapeatMode: 1)
            }else{
                repeatOptionsLabel.text = "Today only"
            }
        }
    }
    
    private func convertToString(reapeatMode: Int){
        if(reapeatMode == 0){
            // Sort the array from smaller value to bigger value
            AddHabitVC.weeklyDaysSelected = AddHabitVC.weeklyDaysSelected.sorted { $0 < $1 }
            
            let weekdaysList = [0,1,2,3,4]
            let weekendsList = [5,6]
            
            let weekdaysListSet = Set(weekdaysList)
            let weekendsListSet = Set(weekendsList)
            let weeklyDaysSelectedListSet = Set(AddHabitVC.weeklyDaysSelected)
            
            let isWeekdays = weekdaysListSet.isSubset(of: weeklyDaysSelectedListSet)
            let isWeekends = weekendsListSet.isSubset(of: weeklyDaysSelectedListSet)
            
            var tempRepeatOptionsString = ""
            
            // Process the information given by the user and improve readability
            if(AddHabitVC.weeklyDaysSelected.count == 7){
                tempRepeatOptionsString = "Everyday"
            }else if(isWeekdays && AddHabitVC.weeklyDaysSelected.count == 5){
                tempRepeatOptionsString = "Weekdays"
            }else if(isWeekends && AddHabitVC.weeklyDaysSelected.count == 2){
                tempRepeatOptionsString = "Weekends"
            }else{
                for index in 0..<AddHabitVC.weeklyDaysSelected.count{
                    
                    switch AddHabitVC.weeklyDaysSelected[index] {
                    case 0:
                        tempRepeatOptionsString += "Mon "
                    case 1:
                        tempRepeatOptionsString += "Tue "
                    case 2:
                        tempRepeatOptionsString += "Wed "
                    case 3:
                        tempRepeatOptionsString += "Thu "
                    case 4:
                        tempRepeatOptionsString += "Fri "
                    case 5:
                        tempRepeatOptionsString += "Sat "
                    case 6:
                        tempRepeatOptionsString += "Sun "
                    default:
                        assert(false, "FATAL: Unexpected case when converting weeklyDaysSelected to readable String")
                    }
                }
            }
            repeatOptionsLabel.text = tempRepeatOptionsString
        }else{
            AddHabitVC.monthlyDaysSelected = AddHabitVC.monthlyDaysSelected.sorted { $0 < $1 }
            if(AddHabitVC.monthlyDaysSelected.count >= 31){
                repeatOptionsLabel.text = "Everyday"
            }else{
                repeatOptionsLabel.text = "Place holder monthly"
            }
        }
    }
    
    /*override var prefersStatusBarHidden: Bool {
     return true
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension Date {
    func compareTimeOnly(to: Date) -> ComparisonResult {
        let calendar = Calendar.current
        let components2 = calendar.dateComponents([.hour, .minute, .second], from: to)
        let date3 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!
        
        let seconds = calendar.dateComponents([.second], from: self, to: date3).second!
        if seconds == 0 {
            return .orderedSame
        } else if seconds > 0 {
            // Ascending means before
            return .orderedAscending
        } else {
            // Descending means after
            return .orderedDescending
        }
    }
}
