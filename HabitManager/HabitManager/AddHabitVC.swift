//
//  AddHabitVC.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit

class AddHabitVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var habitDescription: UITextField!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    private var timePickerVisible = false
    
    private func checkDescription() {
        let description = habitDescription.text ?? ""
        saveButton.isEnabled = !description.isEmpty
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        
        var habits: [String]
 
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
            habits.append(habitDescription.text!)
        }else{
            habits = [habitDescription.text!]
        }
        UserDefaults.standard.set(habits, forKey: "habits")
        habitDescription.text = ""
        performSegue(withIdentifier: "segueToMain", sender: nil)
    }
    
    private func setTimelabelValue () {
        timeLabel.text = DateFormatter.localizedString(from: timePicker.date, dateStyle: .none, timeStyle: .short)
    }
    
    private func toggleShowDateDatepicker () {
        timePickerVisible = !timePickerVisible
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func timePickerAction(_ sender: UIDatePicker) {
        setTimelabelValue()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            toggleShowDateDatepicker()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        checkDescription()
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
