//
//  AddHabitVC.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit

class AddHabitVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var repeatOptionsTitleLabel: UILabel!
    @IBOutlet var repeatOptionsLabel: UILabel!
    @IBOutlet var habitDescription: UITextField!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var repeatOptionsTable: UITableView!
    @IBOutlet var repeatOptionCell: UITableViewCell!
    
    private var timePickerVisible = false
    private var firstRun = true
    private var selectedTime: Date!
    private static var daysSelected: [Int] = []
    private var uuid: [String] = []
    
    private func checkDescription() {
        let description = habitDescription.text ?? ""
        saveButton.isEnabled = !description.isEmpty
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        
        var habits: [String]
        var notificationsString: [String]
 
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits

            habits.append(habitDescription.text!)
        }else{
            habits = [habitDescription.text!]
        }
        UserDefaults.standard.set(habits, forKey: "habits")
        
        
        var beautifiedTimeLabel = ""
        if(timeLabel.text == "None"){
            beautifiedTimeLabel = "No Alert"
        }else{
            if(repeatOptionsLabel.text == "Today only"){
                beautifiedTimeLabel = "At " + timeLabel.text!
            }else{
                beautifiedTimeLabel = "At " + timeLabel.text! + " on " + repeatOptionsLabel.text!
            }
        }
        
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
            
            notificationsString.append(beautifiedTimeLabel)
        }else{
            notificationsString = [beautifiedTimeLabel]
        }
        UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
        
    
        if(selectedTime != nil){
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            
            if(AddHabitVC.daysSelected.count != 0){

                for index in 0..<AddHabitVC.daysSelected.count{
                    
                    var gregorianDay = AddHabitVC.daysSelected[index]+2
                    if(gregorianDay == 8){
                        gregorianDay = 1
                    }
                    print (gregorianDay)
                    saveUUID(UUID: UUID().uuidString)
                    delegate?.scheduleWeekdayNotifications(at: selectedTime, title: habitDescription.text!, id: uuid[uuid.count-1], weekday: gregorianDay)
                    print (uuid[uuid.count-1])
                }
                saveUUID(UUID: "break")
            }else{
                saveUUID(UUID: UUID().uuidString)
                delegate?.scheduleOneTimeNotification(at: selectedTime, title: habitDescription.text!, id: uuid[uuid.count-1])
                saveUUID(UUID: "break")
            }
        }
        
        performSegue(withIdentifier: "segueToMain", sender: nil)
    }
    
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
    
    private func setTimelabelValue () {
        timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
        if(firstRun){
            toggleRepeatOptionsCell(enable: true)
            repeatOptionsLabel.text = "Today only"
            firstRun = false;
        }
    }
    
    private func toggleShowDateDatepicker () {
        timePickerVisible = !timePickerVisible
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        setTimelabelValue()
        selectedTime = sender.date
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(restorationIdentifier == "NewHabit"){
            if indexPath.section == 1 && indexPath.row == 1 {
                toggleShowDateDatepicker()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else if (restorationIdentifier == "RepeatOptions"){
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
            print (AddHabitVC.daysSelected)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !timePickerVisible && indexPath.section == 1 && indexPath.row == 2 {
            return 0
        } else {
            if(indexPath.section == 1 && indexPath.row == 2){
                return 216
            } else{
                return super.tableView.rowHeight
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkDescription()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        if(restorationIdentifier == "NewHabit"){
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
            AddHabitVC.daysSelected = []
            checkDescription()
            toggleRepeatOptionsCell(enable: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(restorationIdentifier == "RepeatOptions"){
            
            for cell in repeatOptionsTable.visibleCells {
                let row = repeatOptionsTable.indexPath(for: cell)?.row

                if(AddHabitVC.daysSelected.contains(row!)){
                    cell.accessoryType = .checkmark
                }
            }
            //repeatOptionsTable.reloadData()
        }else if (restorationIdentifier == "NewHabit"){
            if(!AddHabitVC.daysSelected.isEmpty){
                AddHabitVC.daysSelected = AddHabitVC.daysSelected.sorted { $0 < $1 }
                
                let weekdaysList = [0,1,2,3,4]
                let weekendsList = [5,6]
                
                let weekdaysListSet = Set(weekdaysList)
                let weekendsListSet = Set(weekendsList)
                let daysSelectedListSet = Set(AddHabitVC.daysSelected)
                
                let isWeekdays = weekdaysListSet.isSubset(of: daysSelectedListSet)
                let isWeekends = weekendsListSet.isSubset(of: daysSelectedListSet)
                
                var tempRepeatOptionsString = ""
                
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
                            tempRepeatOptionsString += "Tur "
                        case 4:
                            tempRepeatOptionsString += "Fri "
                        case 5:
                            tempRepeatOptionsString += "Sat "
                        case 6:
                            tempRepeatOptionsString += "Sun "
                        default:
                            tempRepeatOptionsString = "Today only"
                        }
                    }
                }
                repeatOptionsLabel.text = tempRepeatOptionsString
                print (AddHabitVC.daysSelected)
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
