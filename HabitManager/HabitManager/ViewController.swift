//
//  ViewController.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var habitsTable: UITableView!
    
    var habits: [String] = []
    var notificationsString: [String] = []
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return habits.count
    }
  
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell") as! CustomCell
        
        cell.habitLabel.text = habits[indexPath.row]
        cell.habitLabel.numberOfLines = 0
        //cell.habitLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.notificationsLabel.text = notificationsString[indexPath.row]
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0/255, green: 190/255, blue: 255/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 0/255, green: 200/255, blue: 255/255, alpha: 1.0)
        }
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitsTable.estimatedRowHeight = 44
        habitsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        let notificationsStringObject = UserDefaults.standard.object(forKey: "notificationsString")
        
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
        }
        if let tempNotificationsString = notificationsStringObject as? [String] {
            notificationsString = tempNotificationsString
        }
        
        habitsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            habits.remove(at: indexPath.row)
            notificationsString.remove(at: indexPath.row)
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

