//
//  AddHabitVC.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit

var checkNotificationAccess: Bool = false

class AddHabitVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var repeatOptionsTitleLabel: UILabel!
    @IBOutlet var repeatOptionsLabel: UILabel!
    @IBOutlet var alertOptionsTitleLabel: UILabel!
    @IBOutlet var alertOptionsLabel: UILabel!
    
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
    private var mode = 0
    private static var repeatMode: Int!
    private var selectedTime: Date!
    private var selectedInterval: Int = 60
    private var selectedIntervalHours: Int = 0
    private var selectedIntervalMinutes: Int = 0
    private var alertOptionsMode0Text: String = "Never"
    private var alertOptionsMode1Text: String = "Every 1 minute"
    private static var weeklyDaysSelected: [Int] = []
    private static var monthlyDaysSelected: [Int] = []
    private var uuid: [[String]] = []
    
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
    
    /* Saves and process information entered by the user, then go to the main page */
    @IBAction func save(_ sender: Any) {
        
        // Set up things for storing these arrays to user's local storage
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let habitDataObject = UserDefaults.standard.object(forKey: "habitData")
        let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
        
        var habits: [String]
        var habitDetails: [String]
        var notificationsString: [String]
        var habitData: [Any]
        var switchState: [Int]
        
        /* ============================================================================================================ */
        
        // Store habit decription to user's local storage
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
            habits.append(habitDescription.text!)
        }else{
            habits = [habitDescription.text!]
        }
        UserDefaults.standard.set(habits, forKey: "habits")
        
        /* ============================================================================================================ */
        
        // Store habit summary to user's local storage
        if let tempHabitDetails = habitDetailsObject as? [String] {
            habitDetails = tempHabitDetails
            habitDetails.append(habitSecondDescription.text!)
        }else{
            habitDetails = [habitSecondDescription.text!]
        }
        UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
        
        /* ============================================================================================================ */
        
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
        
        // Store the label to user's local storage so the main page can access and display
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
            notificationsString.append(beautifiedTimeLabel)
        }else{
            notificationsString = [beautifiedTimeLabel]
        }
        UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
        
        /* ============================================================================================================ */
        
        // Store the state of the added switch to local storage (0 for "off" and 1 for "on")
        if let tempSwitchState = switchStateObject as? [Int] {
            switchState = tempSwitchState
            switchState.append(1)
        }else{
            switchState = [1]
        }
        UserDefaults.standard.set(switchState, forKey: "switchState")
        
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
                print("Added multiple uuids: \(uuid[uuid.count-1])\n")
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
                print("Added multiple uuids: \(uuid[uuid.count-1])\n")
            }// One time notification, type 2
            else{
                saveUUIDs(UUID: [UUID().uuidString])
                delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
                notificationType = 2
                checkNotificationAccess = true
                print ("Added uuid: \(uuid[uuid.count-1])\n")
            }
        }// If in "Standard" mode and no time is selected, type 3
        else if(selectedTime == nil && mode == 0){
            notificationType = 3
            saveUUIDs(UUID: ["none"])
        }// If in "Reoccurring" mode, schedual notifications based on interval specified by the user, type 4
        else if(mode == 1){
            saveUUIDs(UUID: [UUID().uuidString])
            delegate?.scheduleReoccurringNotification(interval: selectedInterval, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1][0])
            notificationType = 4
            checkNotificationAccess = true
            print ("Added uuid: \(uuid[uuid.count-1])\n")
        }
        
        // Store backend data to local storage for functions like "resume" and "edit"
        if let temphabitData = habitDataObject as? [Any] {
            habitData = temphabitData
            
            habitData.append(notificationType)
        }else{
            habitData = [notificationType]
        }
        
        if(notificationDays != []){
            habitData.append(notificationDays)
        }else{
            habitData.append(-1)
        }
        
        if(notificationType == 3){
            habitData.append(-1)
        }else if(notificationType == 4){
            habitData.append(selectedInterval)
        }else{
            habitData.append(selectedTime)
        }
        print ("habits data: \(habitData)")
        UserDefaults.standard.set(habitData, forKey: "habitData")
        
        // Go back to the main page
        dismiss(animated: true, completion: nil)
    }
    
    /* Generates an unique ID if "UUID().uuidString" is the argument, store UUIDs to local storage */
    private func saveUUIDs(UUID: [String]){
        
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        
        if let tempUUIDs = uuidObject as? [[String]]{
            uuid = tempUUIDs
            
            uuid.append(UUID)
        }else{
            uuid = [UUID]
        }
        UserDefaults.standard.set(uuid, forKey: "uuid")
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
        if(firstRun){
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
    
    /* Store the interval picked by user and process the interval (in seconds) so it is more readable to the user */
    @IBAction func intervalPickerAction(_ sender: UIDatePicker) {
        selectedInterval = Int(sender.countDownDuration)
        selectedIntervalHours = selectedInterval / 3600
        if selectedIntervalHours == 0{
            selectedIntervalMinutes = selectedInterval / 60
        } else{
            selectedIntervalMinutes = selectedInterval % 3600 / 60
        }
        
        if((selectedIntervalHours == 0 || selectedIntervalHours == 1) && selectedIntervalMinutes != 0 && selectedIntervalMinutes != 1){
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hour and \(selectedIntervalMinutes) minutes"
        }else if((selectedIntervalHours == 0 || selectedIntervalHours == 1) && (selectedIntervalMinutes == 0 || selectedIntervalMinutes == 1)){
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hour and \(selectedIntervalMinutes) minute"
        }else if(selectedIntervalHours != 0 && selectedIntervalHours != 1 && (selectedIntervalMinutes == 0 || selectedIntervalMinutes == 1)){
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hours and \(selectedIntervalMinutes) minute"
        }else{
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hours and \(selectedIntervalMinutes) minutes"
        }
        
        if(selectedIntervalHours == 0 && selectedIntervalMinutes != 0 && selectedIntervalMinutes != 1){
            alertOptionsMode1Text = "Every \(selectedIntervalMinutes) minutes"
        }else if(selectedIntervalMinutes == 0 && selectedIntervalHours != 0 && selectedIntervalHours != 1){
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hours"
        }else if(selectedIntervalHours == 0 && (selectedIntervalMinutes == 0 || selectedIntervalMinutes == 1)){
            alertOptionsMode1Text = "Every \(selectedIntervalMinutes) minute"
        }else if(selectedIntervalMinutes == 0 && (selectedIntervalHours == 0 || selectedIntervalHours == 1)){
            alertOptionsMode1Text = "Every \(selectedIntervalHours) hour"
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
                                AddHabitVC.monthlyDaysSelected = []
                                let itemToRemove = row
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
    
    /* Do tasks when add new habit page (which includes two views) is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        if(restorationIdentifier == "NewHabit"){
            // Hide the keyboard when user tapped somewhere outside the textfield */
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
            
            // Tasks that need to be done when the view is first loaded
            AddHabitVC.repeatMode = 0
            AddHabitVC.weeklyDaysSelected = []
            AddHabitVC.monthlyDaysSelected = []
            checkDescription()
            toggleRepeatOptionsCell(enable: false)
            toggleAlertOptionsCell(enable: false)
            
            //Work around for: DatePicker in CountDownTimer mode does not update countDownDuration after the first spin (possible system bug)
            let dateComp : NSDateComponents = NSDateComponents()
            dateComp.hour = 0
            dateComp.minute = 1
            let calendar = Calendar(identifier: .gregorian)
            let date : NSDate = calendar.date(from: dateComp as DateComponents)! as NSDate
            intervalPicker.setDate(date as Date, animated: true)
        }
    }
    
    /* Do tasks before a view is loaded */
    override func viewWillAppear(_ animated: Bool) {
        if(restorationIdentifier == "RepeatOptions"){
            if(!AddHabitVC.weeklyDaysSelected.isEmpty){
                AddHabitVC.repeatMode = 0
                repeatModeToggles.selectedSegmentIndex = 0
                
                // Restore the checkmarks for "weekly" mode
                for section in 0 ..< repeatOptionsTable.numberOfSections-1 {
                    if(section == 1){
                        for row in 0 ..< repeatOptionsTable.numberOfRows(inSection: section) {
                            let indexPath = IndexPath(row: row, section: section)
                            let cell = repeatOptionsTable.cellForRow(at: indexPath)
                            if(AddHabitVC.weeklyDaysSelected.contains(row)){
                                cell?.accessoryType = .checkmark
                            }
                        }
                    }
                }
            }else if(!AddHabitVC.monthlyDaysSelected.isEmpty){
                AddHabitVC.repeatMode = 1
                repeatModeToggles.selectedSegmentIndex = 1
                print("Monthly days selected: \(AddHabitVC.monthlyDaysSelected)")
                
                // Restore the checkmarks for "monthly" mode
                for section in 0 ..< repeatOptionsTable.numberOfSections {
                    if(section == 2){
                        for row in 0 ..< repeatOptionsTable.numberOfRows(inSection: section) {
                            let indexPath = IndexPath(row: row, section: section)
                            let cell = repeatOptionsTable.cellForRow(at: indexPath)
                            if(AddHabitVC.monthlyDaysSelected.contains(row+1)){
                                cell?.accessoryType = .checkmark
                            }
                        }
                    }
                }
            }else{
                repeatModeToggles.selectedSegmentIndex = AddHabitVC.repeatMode
            }
        }else if(restorationIdentifier == "NewHabit"){
            if(!repeatOptionsLabel.isEnabled){
                repeatOptionsLabel.text = "Never"
            }else if(!AddHabitVC.weeklyDaysSelected.isEmpty){
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
            }else if(!AddHabitVC.monthlyDaysSelected.isEmpty){
                AddHabitVC.monthlyDaysSelected = AddHabitVC.monthlyDaysSelected.sorted { $0 < $1 }
                if(AddHabitVC.monthlyDaysSelected.count >= 31){
                    repeatOptionsLabel.text = "Everyday"
                }else{
                    repeatOptionsLabel.text = "Place holder monthly"
                }
            }else{
                repeatOptionsLabel.text = "Today only"
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
