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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
