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
    
    @IBOutlet var startOptionsCell: UITableViewCell!
    @IBOutlet var timePickerCell: UITableViewCell!
    @IBOutlet var repeatOptionCell: UITableViewCell!
    @IBOutlet var alertOptionsCell: UITableViewCell!
    @IBOutlet var intervalPickerCell: UITableViewCell!
    
    private var selectedTime: Date!
    private static var daysSelected: [Int] = []
    private var uuid: [String] = []
    
    /* Disables "Save" button if no text is in the textfield */
    internal func checkDescription() {
        let description = habitDescription.text ?? ""
        saveButton.isEnabled = !description.isEmpty
    }
    
    /* Dynamically checks if there's text in the textfield as you type */
    @IBAction func habitDescriptionEntered(_ sender: Any) {
        checkDescription()
    }
    
    /* Toggles between "Daily" and "Reoccurring", set up the relevant interface */
    @IBAction func modeToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            setMode(0)
            
            // Temporary solution for unfinished "alert" option
            /*if(timeLabel.text == "None"){
                toggleAlertOptionsCell(enable: false)
            }*/
            toggleAlertOptionsCell(enable: false)
            
            alertOptionsLabel.text = String(cString: getAlertOptionsMode0Text())
        }else{
            setMode(1)
            toggleAlertOptionsCell(enable: true)
            alertOptionsLabel.text = String(cString: getAlertOptionsMode1Text())
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    /* If "Cancel" button is pressed, go back to the main page */
    @IBAction func cancel(_ sender: Any) {
        setMode(0)
        setIntervalPickerVisible(0)
        setTimePickerVisible(0)
        setSelectedInterval(Int32(60))
        setMessage()
        setFirstRun(1)
        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "None"))
        setAlertOptionsMode1Text(UnsafeMutablePointer<Int8>(mutating: "Every 1 minute"))
        dismiss(animated: true, completion: nil)
    }
    
    /* Saves and process information entered by the user, then go to the main page */
    @IBAction func save(_ sender: Any) {
        
        // Set up things for storing these arrays to user's local storage
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let habitDetailsObject = UserDefaults.standard.object(forKey: "habitDetails")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        let habitsDataObject = UserDefaults.standard.object(forKey: "habitsData")
        let switchStateObject = UserDefaults.standard.object(forKey: "switchState")
        
        var habits: [String]
        var habitDetails: [String]
        var notificationsString: [String]
        var habitsData: [Any]
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
        var notificationDays: String = ""
        
        if(habitSecondDescription.text?.isEmpty)!{
            bodyContentForNotification = "It is time to " + habitDescription.text! + "!"
        }else{
            bodyContentForNotification = habitSecondDescription.text!
        }
        
        // If in "Daily" mode, schedual the notifications based on time and day selected by the user
        if(selectedTime != nil && getMode() == 0){
            
            if(AddHabitVC.daysSelected.count != 0){
                print ("Added multiple uuids: ")
                for index in 0..<AddHabitVC.daysSelected.count{
                    
                    // Convert days selected by the user (stored in daysSelected array) to gregorian format
                    var gregorianDay = AddHabitVC.daysSelected[index]+2
                    // Sunday is 1, Monday is 2 ... Saturaday is 7
                    if(gregorianDay == 8){
                        gregorianDay = 1
                    }
                    // Once this is called, an unique ID is generated by the system and stored to local storage
                    saveUUID(UUID: UUID().uuidString)
                    // Schedual the notifications based on information provided
                    delegate?.scheduleWeekdayNotifications(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1], weekday: gregorianDay)
                    notificationDays += "\(gregorianDay)"
                    print (uuid[uuid.count-1])
                }
                notificationType = 0
                checkNotificationAccess = true
                print ("\n")
                saveUUID(UUID: "break")
            }else{
                saveUUID(UUID: UUID().uuidString)
                delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1])
                notificationType = 1
                checkNotificationAccess = true
                print ("Added uuid: \(uuid[uuid.count-1])\n")
                saveUUID(UUID: "break")
            }
        }// If in "Daily" mode and no time is selected
        else if(selectedTime == nil && getMode() == 0){
            notificationType = 2
            saveUUID(UUID: "break")
        }// If in "Reoccurring" mode, schedual notifications based on interval specified by the user
        else if(getMode() == 1){
            saveUUID(UUID: UUID().uuidString)
            delegate?.scheduleReoccurringNotification(interval: Int(getSelectedInterval()), title: habitDescription.text!, body: bodyContentForNotification, id: uuid[uuid.count-1])
            notificationType = 3
            checkNotificationAccess = true
            print ("Added uuid: \(uuid[uuid.count-1])\n")
            saveUUID(UUID: "break")
        }
        
        // Store data needed for the resume function to local storage
        if let tempHabitsData = habitsDataObject as? [Any] {
            habitsData = tempHabitsData
            
            habitsData.append(notificationType)
        }else{
            habitsData = [notificationType]
        }
        
        if(notificationDays != ""){
            habitsData.append(notificationDays)
        }else{
            habitsData.append(-1)
        }
        
        if(notificationType == 2){
            habitsData.append(-1)
        }else if(notificationType == 3){
            habitsData.append(Int(getSelectedInterval()))
        }else{
            habitsData.append(selectedTime)
        }
        print ("habits data: \(habitsData)")
        UserDefaults.standard.set(habitsData, forKey: "habitsData")
        
        // Go back to the main page
        setMode(0)
        setIntervalPickerVisible(0)
        setTimePickerVisible(0)
        setMessage()
        setFirstRun(1)
        setSelectedInterval(Int32(60))
        setAlertOptionsMode0Text(UnsafeMutablePointer<Int8>(mutating: "None"))
        setAlertOptionsMode1Text(UnsafeMutablePointer<Int8>(mutating: "Every 1 minute"))
        dismiss(animated: true, completion: nil)
    }
    
    /* Generates an unique ID if "UUID().uuidString" is the argument and stores it to user's local storage */
    private func saveUUID(UUID: String){
        
        let uuidObject = UserDefaults.standard.object(forKey: "uuid")
        
        if let tempUUID = uuidObject as? [String] {
            uuid = tempUUID
            
            uuid.append(UUID)
        }else{
            uuid = [UUID]
        }
        UserDefaults.standard.set(uuid, forKey: "uuid")
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
        if(getFirstRun() == 1){
            toggleRepeatOptionsCell(enable: true)
            //toggleAlertOptionsCell(enable: true)
            repeatOptionsLabel.text = "Today only"
            setFirstRun(0)
        }
    }
    
    /* Trigged by user spinning the date picker */
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        toggleRepeatOptionsCell(enable: true)
        setTimelabelValue()
        selectedTime = sender.date
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowTimePicker (){
        if(getTimePickerVisible() == 0){
            setTimePickerVisible(1)
        } else {
            setTimePickerVisible(0)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    /* Store the interval picked by user and process the interval (in seconds) so it is more readable to the user */
    @IBAction func intervalPickerAction(_ sender: UIDatePicker) {
        setSelectedInterval(Int32(sender.countDownDuration))
        setMessage()
        alertOptionsLabel.text = String(cString: getAlertOptionsMode1Text())
    }
    
    /* Toggle the boolean so another method "heightForRowAt" is called and changes the cell height */
    private func toggleShowInvervalPicker(){
        if(getIntervalPickerVisible() == 0){
            setIntervalPickerVisible(1)
        } else {
            setIntervalPickerVisible(0)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        } else if(restorationIdentifier == "RepeatOptions"){
            // Toggle the checkmarks based on row selected when in "Repeat" options view
            let numberOfRows = tableView.numberOfRows(inSection: 0)
            
            for row in 0..<numberOfRows {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                    //cell.accessoryType = row == indexPath.row ? .checkmark : .none
 
                    if(row == indexPath.row && cell.accessoryType == .none){
                        cell.accessoryType = .checkmark
                        AddHabitVC.daysSelected.append(row)
                    }else if(row == indexPath.row && cell.accessoryType != .none){
                        cell.accessoryType = .none
                        let itemToRemove = row
                        if let index = AddHabitVC.daysSelected.index(of: itemToRemove) {
                            AddHabitVC.daysSelected.remove(at: index)
                        }
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
    
    /* Changes row heights if certain condition is met */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(getMode() == 0){
            if(indexPath.section == 1 && indexPath.row == 4){
                return 0
            }else if(getTimePickerVisible() == 0 && indexPath.section == 1 && indexPath.row == 1){
                return 0
            }else {
                if(indexPath.section == 1 && indexPath.row == 1){
                    return 216
                }
                return super.tableView.rowHeight
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
                return super.tableView.rowHeight
            }
        }
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
            AddHabitVC.daysSelected = []
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
    
    /* Do tasks when add new habit page (which includes two views) is appeared */
    override func viewDidAppear(_ animated: Bool) {
        if(restorationIdentifier == "RepeatOptions"){
            
            // Redo the checkmarks, there's probably a better solution
            for cell in repeatOptionsTable.visibleCells {
                let row = repeatOptionsTable.indexPath(for: cell)?.row

                if(AddHabitVC.daysSelected.contains(row!)){
                    cell.accessoryType = .checkmark
                }
            }
        }else if (restorationIdentifier == "NewHabit"){
            if(!AddHabitVC.daysSelected.isEmpty){
                // Sort the array from smaller value to bigger value
                AddHabitVC.daysSelected = AddHabitVC.daysSelected.sorted { $0 < $1 }
                
                let weekdaysList = [0,1,2,3,4]
                let weekendsList = [5,6]
                
                let weekdaysListSet = Set(weekdaysList)
                let weekendsListSet = Set(weekendsList)
                let daysSelectedListSet = Set(AddHabitVC.daysSelected)
                
                let isWeekdays = weekdaysListSet.isSubset(of: daysSelectedListSet)
                let isWeekends = weekendsListSet.isSubset(of: daysSelectedListSet)
                
                var tempRepeatOptionsString = ""
                
                // Process the information given by the user and improve readability
                if(AddHabitVC.daysSelected.count == 7){
                    tempRepeatOptionsString = "Everyday"
                }else if(isWeekdays && AddHabitVC.daysSelected.count == 5){
                    tempRepeatOptionsString = "Weekdays"
                }else if(isWeekends && AddHabitVC.daysSelected.count == 2){
                    tempRepeatOptionsString = "Weekends"
                }else{
                    for index in 0..<AddHabitVC.daysSelected.count{
                        
                        switch AddHabitVC.daysSelected[index] {
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
                            print("Unexpected case when converting daysSelected to readable String")
                        }
                    }
                }
                repeatOptionsLabel.text = tempRepeatOptionsString
            }else if(repeatOptionsLabel.text != "Today only" && repeatOptionsLabel.text != "Never"){
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
