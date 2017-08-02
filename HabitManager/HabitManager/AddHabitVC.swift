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
    
    private var timePickerVisible = false
    private var intervalPickerVisible = false
    private var firstRun = true
    private var mode: Int = 0
    public var rowPassed: Int = -1
    private static var rowBeingEdited: Int = -1
    private static var repeatMode: Int!
    private var selectedTime: Date!
    private var selectedInterval: Int = 60
    private var alertOptionsMode0Text: String = "Never"
    private var alertOptionsMode1Text: String = "Every 1 minute"
    private static var weeklyDaysSelected: [Int] = []
    private static var monthlyDaysSelected: [Int] = []
    private var uuid: [[String]] = []
    
    private var habits: [String] = []
    private var habitDetails: [String] = []
    private var notificationsString: [String] = []
    private var habitData: [Any] = []
    private var switchState: [Int] = []
    
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
            mode = 0
            
            // Temporary solution for unfinished "alert" option
            /*if(timeLabel.text == "None"){
             toggleAlertOptionsCell(enable: false)
             }*/
            toggleAlertOptionsCell(enable: false)
            alertOptionsLabel.text = alertOptionsMode0Text
        }else{
            mode = 1
            toggleAlertOptionsCell(enable: true)
            alertOptionsLabel.text = alertOptionsMode1Text
        }
        updateTable(withAnimation: true)
    }
    
    /* If "Cancel" button is pressed, go back to the main page */
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /* When "Save" is tapped */
    @IBAction func save(_ sender: Any) {
        // Developer mode
        if(habitDescription.text == "#Add" && AddHabitVC.rowBeingEdited == -1){ // Add random habits
            randomlyGenHabits(numOfTimes: 10)
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
        }
        // User mode
        else{
          saveHabits()
        }
        
        // Go back to the main page
        dismiss(animated: true, completion: nil)
    }
    
    /*  Saves and process information entered by the user */
    private func saveHabits(){
        // Prepare the label that descripbes the notications
        var beautifiedTimeLabel = ""
        if(mode == 0){
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
            beautifiedTimeLabel = alertOptionsMode1Text
        }
        
        // If in New Habit Mode
        if(AddHabitVC.rowBeingEdited == -1){
            // Set up things for storing these arrays to user's local storage
            let habitsObject = UserDefaults.standard.object(forKey: "habits")
            let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
            let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
            let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
            
            // Store habit decription to user's local storage
            if let tempHabits = habitsObject as? [String] {
                habits = tempHabits
                habits.append(habitDescription.text!)
            }else{
                habits = [habitDescription.text!]
            }
            UserDefaults.standard.set(habits, forKey: "habits")
            
            // Store habit summary to user's local storage
            if let tempHabitDetails = habitDetailsObject as? [String] {
                habitDetails = tempHabitDetails
                habitDetails.append(habitSecondDescription.text!)
            }else{
                habitDetails = [habitSecondDescription.text!]
            }
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            
            // Store the label to user's local storage so the main page can access and display
            if let tempNotificationsString = notificationsStringObject as? [String] {
                notificationsString = tempNotificationsString
                notificationsString.append(beautifiedTimeLabel)
            }else{
                notificationsString = [beautifiedTimeLabel]
            }
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            
            // Store the state of the added switch to local storage (0 for "off" and 1 for "on")
            if let tempSwitchState = switchStateObject as? [Int] {
                switchState = tempSwitchState
                switchState.append(1)
            }else{
                switchState = [1]
            }
            UserDefaults.standard.set(switchState, forKey: "switchState")
        }// If in Edit Mode
        else{
            habits[AddHabitVC.rowBeingEdited] = habitDescription.text!
            UserDefaults.standard.set(habits, forKey: "habits")
            
            habitDetails[AddHabitVC.rowBeingEdited] = habitSecondDescription.text!
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            
            notificationsString[AddHabitVC.rowBeingEdited] = beautifiedTimeLabel
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            
            switchState[AddHabitVC.rowBeingEdited] = 1
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
        if(selectedTime != nil && mode == 0){
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
                saveUUIDs(UUID: tempUUIDs)
                if(AddHabitVC.rowBeingEdited == -1){
                    print("Added multiple uuids: \(uuid[uuid.count-1])\n")
                }else{
                    print("Replaced multiple uuids: \(uuid[AddHabitVC.rowBeingEdited])\n")
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
                saveUUIDs(UUID: tempUUIDs)
                if(AddHabitVC.rowBeingEdited == -1){
                    print("Added multiple uuids: \(uuid[uuid.count-1])\n")
                }else{
                    print("Replaced multiple uuids: \(uuid[AddHabitVC.rowBeingEdited])\n")
                }
            }// One time notification, type 2
            else{
                notificationType = 2
                checkNotificationAccess = true
                saveUUIDs(UUID: [UUID().uuidString])
                if(AddHabitVC.rowBeingEdited == -1){
                    delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                    print ("Added uuid: \(uuid[uuid.count-1])\n")
                }else{
                    delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[AddHabitVC.rowBeingEdited][0])
                    print("Replaced uuid: \(uuid[AddHabitVC.rowBeingEdited])\n")
                }
            }
        }// If in "Standard" mode and no time is selected, type 3
        else if(selectedTime == nil && mode == 0){
            notificationType = 3
            saveUUIDs(UUID: ["none"])
        }// If in "Reoccurring" mode, schedual notifications based on interval specified by the user, type 4
        else if(mode == 1){
            notificationType = 4
            checkNotificationAccess = true
            saveUUIDs(UUID: [UUID().uuidString])
            if(AddHabitVC.rowBeingEdited == -1){
                delegate?.scheduleReoccurringNotification(interval: selectedInterval, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                print ("Added uuid: \(uuid[uuid.count-1])\n")
            }else{
                delegate?.scheduleReoccurringNotification(interval: selectedInterval, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[AddHabitVC.rowBeingEdited][0])
                print("Replaced uuid: \(uuid[AddHabitVC.rowBeingEdited])\n")
            }
        }
        
        // Store backend data to local storage for functions like "resume" and "edit"
        if(AddHabitVC.rowBeingEdited == -1){
            // Type
            let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
            if let temphabitData = habitDataObject as? [Any] {
                habitData = temphabitData
                
                habitData.append(notificationType)
            }else{
                habitData = [notificationType]
            }
            
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
                habitData.append(selectedInterval)
            }else{
                habitData.append(selectedTime)
            }
        }else{
            // Type
            habitData[AddHabitVC.rowBeingEdited*3] = notificationType
            
            // Weekly Days/Monthly Days
            if(notificationDays != []){
                habitData[AddHabitVC.rowBeingEdited*3+1] = notificationDays
            }else{
                habitData[AddHabitVC.rowBeingEdited*3+1] = -1
            }
            
            // Time/Interval
            if(notificationType == 3){
                habitData[AddHabitVC.rowBeingEdited*3+2] = -1
            }else if(notificationType == 4){
                habitData[AddHabitVC.rowBeingEdited*3+2] = selectedInterval
            }else{
                habitData[AddHabitVC.rowBeingEdited*3+2] = selectedTime
            }
        }
        print ("habits data: \(habitData)")
        UserDefaults.standard.set(habitData, forKey: "habitData")
    }
    
    /* Generates an unique ID if "UUID().uuidString" is the argument, store UUIDs to local storage */
    private func saveUUIDs(UUID: [String]){
        if(AddHabitVC.rowBeingEdited == -1){
            let uuidObject = UserDefaults.standard.object(forKey: "uuid")
            
            if let tempUUIDs = uuidObject as? [[String]]{
                uuid = tempUUIDs
                uuid.append(UUID)
            }else{
                uuid = [UUID]
            }
        }else{
            uuid[AddHabitVC.rowBeingEdited] = UUID
        }
        
        UserDefaults.standard.set(uuid, forKey: "uuid")
    }
    
    /* Generate random habits for development purposes */
    private func randomlyGenHabits(numOfTimes: Int){
        var count = 1
        while(count <= numOfTimes){
            AddHabitVC.weeklyDaysSelected = []
            let randomModeChance: UInt32 = arc4random_uniform(3) // range is 0 to 2
            if(randomModeChance == 2){
                mode = 1
            }else{
                mode = 0
            }
            
            habitDescription.text = "test " + String(count)
            let randomSummaryBool: UInt32 = arc4random_uniform(2)
            if(Int(randomSummaryBool) == 0){
                habitSecondDescription.text = "test "
                var randomWordCount: UInt32 = arc4random_uniform(20)+2
                while(Int(randomWordCount) != 0){
                    habitSecondDescription.text = habitSecondDescription.text! + "test "
                    randomWordCount -= 1
                }
                
            }else{
                habitSecondDescription.text = ""
            }
            
            if(mode == 0){
                let currentTime = Date()
                let calender = Calendar.current
                var components = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentTime)
                components.hour = Int(arc4random_uniform(25))
                components.minute = Int(arc4random_uniform(61))
                let randomTime = calender.date(from: components)!
                timePicker.setDate(randomTime, animated: true)
                timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
                selectedTime = randomTime
                
                var randomDaysCount: UInt32 = arc4random_uniform(8)
                while(Int(randomDaysCount) != 0){
                    var randomWeeklyDay: UInt32 = arc4random_uniform(7) // range is 0 to 6
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
            }else{
                let randomHour: UInt32 = arc4random_uniform(24) // range is 0 to 23
                var randomMinute: UInt32 = 0
                if(Int(randomHour) == 0){
                    randomMinute = arc4random_uniform(60)+1 // range is 1 to 60
                }else{
                    randomMinute = arc4random_uniform(61) // range is 0 to 60
                }
                
                convertIntervalAndDisplay(hour: Int(randomHour), minute: Int(randomMinute))
                selectedInterval = Int(randomHour)*3600 + Int(randomMinute)*60
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
        alertOptionsMode0Text = "At " + timeLabel.text!
        alertOptionsLabel.text = alertOptionsMode0Text
        if(firstRun && repeatOptionsLabel.text == "Never"){
            toggleRepeatOptionsCell(enable: true)
            //toggleAlertOptionsCell(enable: true)
            repeatOptionsLabel.text = "Today only"
            firstRun = false
        }
    }
    
    /* Trigged by user spinning the date picker */
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        setTimelabelValue()
        selectedTime = sender.date
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowTimePicker (){
        timePickerVisible = !timePickerVisible
        updateTable(withAnimation: true)
    }
    
    /* Do tasks when interval picker is spinned */
    @IBAction func intervalPickerAction(_ sender: UIDatePicker) {
        var selectedIntervalHours: Int
        var selectedIntervalMinutes: Int
        
        selectedInterval = Int(sender.countDownDuration)
        selectedIntervalHours = selectedInterval / 3600
        if selectedIntervalHours == 0{
            selectedIntervalMinutes = selectedInterval / 60
        } else{
            selectedIntervalMinutes = selectedInterval % 3600 / 60
        }
        
        convertIntervalAndDisplay(hour: selectedIntervalHours, minute: selectedIntervalMinutes)
    }
    
    /* convert the interval (in seconds) to readable text */
    private func convertIntervalAndDisplay(hour: Int, minute: Int){
        if((hour == 0 || hour == 1) && minute != 0 && minute != 1){
            alertOptionsMode1Text = "Every \(hour) hour and \(minute) minutes"
        }else if((hour == 0 || hour == 1) && (minute == 0 || minute == 1)){
            alertOptionsMode1Text = "Every \(hour) hour and \(minute) minute"
        }else if(hour != 0 && hour != 1 && (minute == 0 || minute == 1)){
            alertOptionsMode1Text = "Every \(hour) hours and \(minute) minute"
        }else{
            alertOptionsMode1Text = "Every \(hour) hours and \(minute) minutes"
        }
        
        if(hour == 0 && minute != 0 && minute != 1){
            alertOptionsMode1Text = "Every \(minute) minutes"
        }else if(minute == 0 && hour != 0 && hour != 1){
            alertOptionsMode1Text = "Every \(hour) hours"
        }else if(hour == 0 && (minute == 0 || minute == 1)){
            alertOptionsMode1Text = "Every \(minute) minute"
        }else if(minute == 0 && (hour == 0 || hour == 1)){
            alertOptionsMode1Text = "Every \(hour) hour"
        }
        alertOptionsLabel.text = alertOptionsMode1Text
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowInvervalPicker(){
        intervalPickerVisible = !intervalPickerVisible
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
            if(mode == 0){
                if(indexPath.section == 1 && indexPath.row == 4){
                    return 0
                }else if(!timePickerVisible && indexPath.section == 1 && indexPath.row == 1){
                    return 0
                }else {
                    if(indexPath.section == 1 && indexPath.row == 1){
                        return 216
                    }
                }
            }else{
                if(indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2)){
                    return 0
                }else if(!intervalPickerVisible && indexPath.section == 1 && indexPath.row == 4){
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
                
                // If editing reoccuring habit
                if(habitData[AddHabitVC.rowBeingEdited*3] as! Int == 4){
                    modeToggle.selectedSegmentIndex = 1
                    mode = 1
                    
                    // Restore interval picker data
                    var storedIntervalMinutes: Int
                    selectedInterval = habitData[AddHabitVC.rowBeingEdited*3+2] as! Int
                    let storedIntervalHours = selectedInterval / 3600
                    if storedIntervalHours == 0{
                        storedIntervalMinutes = selectedInterval / 60
                    } else{
                        storedIntervalMinutes = selectedInterval % 3600 / 60
                    }
                    convertIntervalAndDisplay(hour: storedIntervalHours, minute: storedIntervalMinutes)
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
                        alertOptionsMode0Text = "At " + timeLabel.text!
                        alertOptionsLabel.text = alertOptionsMode0Text
                        
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
        if(timer != nil){
            print("invalidating")
            timer.invalidate()
            timer = nil
        }
        
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
                        print("Unexpected case when converting weeklyDaysSelected to readable String")
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
