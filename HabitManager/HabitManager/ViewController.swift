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
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return habits.count
    }
  
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell")!
        
        cell.textLabel?.text = habits[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitsTable.estimatedRowHeight = 44
        habitsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let habitsObject = UserDefaults.standard.object(forKey: "habits")
        
        if let tempHabits = habitsObject as? [String] {
            habits = tempHabits
        }
        
        habitsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            habits.remove(at: indexPath.row)
            habitsTable.reloadData()
            UserDefaults.standard.set(habits, forKey: "habits")
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
