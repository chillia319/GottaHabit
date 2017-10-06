//
//  ViewController.swift
//  HabitManager
//
//  Created by Percy Hu on 18/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit
import UserNotifications

var uuid: [[String]] = []
var timer: Timer!

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet var habitsTable: UITableView!
    @IBOutlet var tabBar: UITabBar!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var leftBarItem: UIBarButtonItem!
    @IBOutlet var rightBarItem: UIBarButtonItem!
    @IBOutlet var quote: UILabel!
    @IBOutlet var quoteAuthor: UILabel!
    
    private var habits: [String] = []
    private var habitDetails: [String] = []
    private var notificationsString: [String] = []
    private var habitData: [Any] = []
    private var switchState: [Int] = []
    
    //private var tabPressed: Int = 0
    private var rowSelected: Int!
    private var filteredHabits: [String] = []
    private var filteredIndexes: [Int] = []
    private var cellsExpanded: [Int] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    /* Count how many rows are in the main page */
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if isFiltering() {
            return filteredHabits.count
        }
        return habits.count
    }
    
    /* Do tasks based on row index */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell") as! CustomCell
        
        cell.editingAccessoryType = .disclosureIndicator
        
        cell.habitDetailsLabel.textColor = UIColor.white
        cell.habitLabel.textColor = UIColor.white
        cell.notificationsLabel.textColor = UIColor.white
        
        // Assign background colours
        if(indexPath.row%2 == 0){
            cell.backgroundColor = UIColor(red:0.000, green:0.400, blue:0.400, alpha:1.000)
        }else{
            cell.backgroundColor = UIColor(red:0.000, green:0.600, blue:0.600, alpha:1.000)
        }
        
        // Ensures the state of the switches are always correct
        func correctSwitchState(index: Int){
            if(switchState.count > 0){
                var currentSwitchState: Int!
                if(cell.cellSwitch.isOn){
                    currentSwitchState = 1
                    if(currentSwitchState != switchState[index]){
                        cell.cellSwitch.isOn = false
                    }
                }else{
                    currentSwitchState = 0
                    if(currentSwitchState != switchState[index]){
                        cell.cellSwitch.isOn = true
                    }
                }
            }
        }
        
        if isFiltering(){
            cell.habitLabel.text = filteredHabits[indexPath.row]
            if(!cellsExpanded.contains(filteredIndexes[indexPath.row])){
                cell.habitDetailsLabel.text = ""
            }else{
                cell.habitDetailsLabel.text = habitDetails[filteredIndexes[indexPath.row]]
            }
            cell.notificationsLabel.text = notificationsString[filteredIndexes[indexPath.row]]
            
            // Assign switches with tags for easy tracking
            cell.cellSwitch.tag = filteredIndexes[indexPath.row]
            
            correctSwitchState(index: filteredIndexes[indexPath.row])
            
            if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 3){
                cell.habitIcon.image = UIImage(named: "noAlertIcon")
                cell.cellSwitch.isHidden = true
            }else if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 4){
                cell.habitIcon.image = UIImage(named: "reoccuringIcon")
                cell.cellSwitch.isHidden = false
            }else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let noonStart = dateFormatter.date(from: "2017-09-11T12:00:00")!
                let morningStart = dateFormatter.date(from: "2017-09-11T06:00:00")!
                let nightStart = dateFormatter.date(from: "2017-09-11T19:00:00")!
                
                let storedTime = habitData[filteredIndexes[indexPath.row]*3+2] as! Date
                let morning = storedTime.compareTimeOnly(to: morningStart)
                let noon = storedTime.compareTimeOnly(to: noonStart)
                let night = storedTime.compareTimeOnly(to: nightStart)
                
                if(morning.rawValue == 1 && noon.rawValue != 1){ // morning
                    cell.habitIcon.image = UIImage(named: "morningIcon")
                }else if(noon.rawValue == 1 && night.rawValue != 1){ // noon
                    cell.habitIcon.image = UIImage(named: "afternoonIcon")
                }else{ // night
                    cell.habitIcon.image = UIImage(named: "nightIcon")
                }
                cell.cellSwitch.isHidden = false
            }
            
            // Check whether a habit is expired
            if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 2){
                if(dateInThePast(date: habitData[filteredIndexes[indexPath.row]*3+2] as! Date)){
                    switchState[filteredIndexes[indexPath.row]] = 0
                    UserDefaults.standard.set(switchState, forKey: "switchState")
                    cell.cellSwitch.isOn = false
                    cell.cellSwitch.isUserInteractionEnabled = false
                    let expiredColour = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
                    cell.backgroundColor = expiredColour
                }else{
                    cell.cellSwitch.isUserInteractionEnabled = true
                }
            }else{
                cell.cellSwitch.isUserInteractionEnabled = true
            }
        }else{
            if(!habitsTable.isEditing){
                rightBarItem.isEnabled = true
            }
            
            cell.habitLabel.text = habits[indexPath.row]
            if(!cellsExpanded.contains(indexPath.row)){
                cell.habitDetailsLabel.text = ""
            }else{
                cell.habitDetailsLabel.text = habitDetails[indexPath.row]
            }
            cell.notificationsLabel.text = notificationsString[indexPath.row]
            
            // Assign switches with tags for easy tracking
            cell.cellSwitch.tag = indexPath.row
            
            correctSwitchState(index: indexPath.row)
            
            if(habitData[indexPath.row*3] as! Int == 3){
                cell.habitIcon.image = UIImage(named: "noAlertIcon")
                cell.cellSwitch.isHidden = true
            }else if(habitData[indexPath.row*3] as! Int == 4){
                cell.habitIcon.image = UIImage(named: "reoccuringIcon")
                cell.cellSwitch.isHidden = false
            }else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let noonStart = dateFormatter.date(from: "2017-09-11T12:00:00")!
                let morningStart = dateFormatter.date(from: "2017-09-11T06:00:00")!
                let nightStart = dateFormatter.date(from: "2017-09-11T19:00:00")!
                
                let storedTime = habitData[indexPath.row*3+2] as! Date
                let morning = storedTime.compareTimeOnly(to: morningStart)
                let noon = storedTime.compareTimeOnly(to: noonStart)
                let night = storedTime.compareTimeOnly(to: nightStart)
                
                if(morning.rawValue == 1 && noon.rawValue != 1){ // morning
                    cell.habitIcon.image = UIImage(named: "morningIcon")
                }else if(noon.rawValue == 1 && night.rawValue != 1){ // noon
                    cell.habitIcon.image = UIImage(named: "afternoonIcon")
                }else{ // night
                    cell.habitIcon.image = UIImage(named: "nightIcon")
                }
                cell.cellSwitch.isHidden = false
            }
            
            // Check whether a habit is expired
            if(habitData[indexPath.row*3] as! Int == 2){
                if(dateInThePast(date: habitData[indexPath.row*3+2] as! Date)){
                    switchState[indexPath.row] = 0
                    UserDefaults.standard.set(switchState, forKey: "switchState")
                    cell.cellSwitch.isOn = false
                    cell.cellSwitch.isUserInteractionEnabled = false
                    let expiredColour = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
                    cell.backgroundColor = expiredColour
                    //colours[indexPath.row] = expiredColour
                }else{
                    cell.cellSwitch.isUserInteractionEnabled = true
                }
            }else{
                cell.cellSwitch.isUserInteractionEnabled = true
            }
        }
        return cell
    }
    
    // For manual refreshing
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor(red:0.839, green:0.839, blue:0.839, alpha:1.000)
        
        return refreshControl
    }()
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        habitsTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    /* When a tab is presssed */
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 0){
            setTabPressed(0)
            navBar.topItem?.title = "All Habits"
            UIView.animate(withDuration: 0.3, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        } else if(item.tag == 1){
            setTabPressed(1)
            navBar.topItem?.title = "Today"
            UIView.animate(withDuration: 0.3, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        }
    }
    
    /* Set row height for each row */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(getTabPressed() == 1){
            if isFiltering(){
                if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 0){
                    let todayDate = Date()
                    let currentWeekday = Calendar.current.component(.weekday, from: todayDate)
                    let days = habitData[filteredIndexes[indexPath.row]*3+1] as! [Int]
                    var show = false
                    for day in days{
                        if(currentWeekday == day){
                            show = true
                            break
                        }
                    }
                    if(!show){
                        return 0
                    }
                }else if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 1){
                    let todayDate = Date()
                    let currentMonthday = Calendar.current.component(.day, from: todayDate)
                    let days = habitData[filteredIndexes[indexPath.row]*3+1] as! [Int]
                    var show = false
                    for day in days{
                        if(currentMonthday == day){
                            show = true
                            break
                        }
                    }
                    if(!show){
                        return 0
                    }
                }else if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 2){
                    return habitsTable.rowHeight
                }else if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 3){
                    return habitsTable.rowHeight
                }else if(habitData[filteredIndexes[indexPath.row]*3] as! Int == 4){
                    return habitsTable.rowHeight
                }
            }else{
                if(habitData[indexPath.row*3] as! Int == 0){
                    let todayDate = Date()
                    let currentWeekday = Calendar.current.component(.weekday, from: todayDate)
                    let days = habitData[indexPath.row*3+1] as! [Int]
                    var show = false
                    for day in days{
                        if(currentWeekday == day){
                            show = true
                            break
                        }
                    }
                    if(!show){
                        return 0
                    }
                }else if(habitData[indexPath.row*3] as! Int == 1){
                    let todayDate = Date()
                    let currentMonthday = Calendar.current.component(.day, from: todayDate)
                    let days = habitData[indexPath.row*3+1] as! [Int]
                    var show = false
                    for day in days{
                        if(currentMonthday == day){
                            show = true
                            break
                        }
                    }
                    if(!show){
                        return 0
                    }
                }else if(habitData[indexPath.row*3] as! Int == 2){
                    return habitsTable.rowHeight
                }else if(habitData[indexPath.row*3] as! Int == 3){
                    return habitsTable.rowHeight
                }else if(habitData[indexPath.row*3] as! Int == 4){
                    return habitsTable.rowHeight
                }
            }
        }else if (getTabPressed() == 0){
            if isFiltering(){
                if(cellsExpanded.contains(filteredIndexes[indexPath.row])){
                    return habitsTable.rowHeight
                }else{
                    return 72
                }
            }else{
                if(cellsExpanded.contains(indexPath.row)){
                    return habitsTable.rowHeight
                }else{
                    return 72
                }
            }
            //return habitsTable.rowHeight
        }
        return habitsTable.rowHeight
    }
    
    // Check whether the given Date is in the past
    func dateInThePast(date: Date) -> Bool{
        let calender = Calendar.current
        let currentTime = Date()        
        let storedTime = date
        var STComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: storedTime)
        STComponents.second = 0
        let newStoredTime = calender.date(from: STComponents)!
        
        if(newStoredTime < currentTime){
            return true
        }else{
            return false
        }
    }
    
    /* Do tasks before presenting another view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.searchController.dismiss(animated: true, completion: nil)
        if segue.identifier == "segueToNewHabit" && habitsTable.isEditing && leftBarItem.title == "Done" {
            if let navVC = segue.destination as? UINavigationController{
                if let addHabitVC = navVC.viewControllers[0] as? AddHabitVC{
                    addHabitVC.rowPassed = rowSelected
                }
            }
        }
    }
    
    /* Deselect row animation for better UX */
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(habitsTable.isEditing){
            if isFiltering() {
                rowSelected = filteredIndexes[indexPath.row]
            }else{
                rowSelected = indexPath.row
            }
            performSegue(withIdentifier: "segueToNewHabit", sender: self)
        }else{
            let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! CustomCell
            print(cell.bounds.height)
            if isFiltering(){
                if(cellsExpanded.contains(filteredIndexes[indexPath.row])){ // if cell is already expanded
                    cell.habitDetailsLabel.text = ""
                    cellsExpanded.remove(at: cellsExpanded.index(of: filteredIndexes[indexPath.row])!)
                }else{
                    cell.habitDetailsLabel.text = habitDetails[filteredIndexes[indexPath.row]]
                    cellsExpanded.append(filteredIndexes[indexPath.row])
                }
            }else{
                if(cellsExpanded.contains(indexPath.row)){ // if cell is already expanded
                    cell.habitDetailsLabel.text = ""
                    cellsExpanded.remove(at: cellsExpanded.index(of: indexPath.row)!)
                }else{
                    cell.habitDetailsLabel.text = habitDetails[indexPath.row]
                    cellsExpanded.append(indexPath.row)
                }
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.habitsTable.beginUpdates()
                self.habitsTable.endUpdates()
            }, completion: nil)
        }
    }
    
    /* Do tasks when the main page is first loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        // Highlight "All habits" tab by default
        tabBar.selectedItem = tabBar.items![0]
        
        habitsTable.estimatedRowHeight = 90
        habitsTable.rowHeight = UITableViewAutomaticDimension
        
        leftBarItem.title = "Edit"
        habitsTable.allowsSelectionDuringEditing = true
        
        // Trigger "startTimer" when application enters foreground or becomes active
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.startTimer), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.startTimer), name:
            NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        //startTimer()
        
        // Add refresh control
        habitsTable.addSubview(self.refreshControl)
        refreshControl.backgroundColor = UIColor(red:0.176, green:0.227, blue:0.263, alpha:1.000)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Title", comment: "")
        habitsTable.tableHeaderView = searchController.searchBar
        UISearchBar.appearance().barTintColor = UIColor(red: 67/255, green: 66/255, blue: 64/255, alpha: 1.0)
        UISearchBar.appearance().tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(red: 67/255, green: 66/255, blue: 64/255, alpha: 1.0)
        //habitsTable.setContentOffset(CGPoint(x:0, y:self.searchController.searchBar.frame.size.height), animated: false)
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredHabits = habits.filter({( habit : String) -> Bool in
            return habit.lowercased().contains(searchText.lowercased())
        })
        
        filteredIndexes = []
        for filtered in filteredHabits{
            if(habits.contains(filtered)){
                filteredIndexes.append(habits.index(of: filtered)!)
            }
        }
        
        habitsTable.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    /* Create a new timer and excute "reloadData" based on time interval */
    @objc func startTimer(){
        if(timer==nil){
            print("timer started")
            timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector:#selector(ViewController.reloadData), userInfo: nil, repeats: true)
        }
    }
    
    /* reload table data */
    @objc func reloadData(){
        if(!habitsTable.isEditing){
            habitsTable.reloadData()
            print("reloaded")
        }
    }
    
    /* Do tasks before the main page is appeared */
    override func viewWillAppear(_ animated: Bool) {
        // Extract information from local storage and set the values inside this class
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
        
        if(leftBarItem.title == "Edit"){
            habitsTable.setEditing(false,animated:true)
        }
        
        // Disable "Edit" button is no row is present
        if(habits.isEmpty){
            leftBarItem.isEnabled = false
        }else{
            leftBarItem.isEnabled = true
        }
        
        // Hide quote is a row is present
        if(!habits.isEmpty){
            quote.isHidden = true
            quoteAuthor.isHidden = true
        }else{
            quote.isHidden = false
            quoteAuthor.isHidden = false
        }
        
        habitsTable.reloadData()
        
        startTimer()
    }
    
    /* Do tasks when the main page is appeared */
    override func viewDidAppear(_ animated: Bool) {
        // Check if notification access is given by the user, only checks if user added a habit which requires notification access
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if checkNotificationAccess && settings.authorizationStatus != .authorized {
                print("notifications not enabled")
                let alertController = UIAlertController(title: "Notification Not Enabled", message: "You can still use GottaHabit, but the functionalities will be extremly limited, enable notifications by going to Settings->GottaHabit->Notifications", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
                checkNotificationAccess = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(timer != nil){
            print("invalidating")
            timer.invalidate()
            timer = nil
        }
    }
    
    /* When "Edit" is pressed, change it to "Done" and tell the system to start editing */
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if(habitsTable.isEditing){
            leftBarItem.title = "Edit"
            rightBarItem.isEnabled = true
            habitsTable.setEditing(false,animated:true)
        }else{
            leftBarItem.title = "Done"
            rightBarItem.isEnabled = false
            habitsTable.setEditing(true,animated:true)
        }
    }
    
    // Disable the ability to move a row for certain notification types
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    /* Move the relavant data when user moves a row */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempUUIDs = uuid[sourceIndexPath.row]
        uuid.remove(at: sourceIndexPath.row)
        uuid.insert(tempUUIDs, at: destinationIndexPath.row)
        
        let tempHabits = habits[sourceIndexPath.row]
        habits.remove(at: sourceIndexPath.row)
        habits.insert(tempHabits, at: destinationIndexPath.row)
        
        let tempHabitDetails = habitDetails[sourceIndexPath.row]
        habitDetails.remove(at: sourceIndexPath.row)
        habitDetails.insert(tempHabitDetails, at: destinationIndexPath.row)
        
        let tempNotificationString = notificationsString[sourceIndexPath.row]
        notificationsString.remove(at: sourceIndexPath.row)
        notificationsString.insert(tempNotificationString, at: destinationIndexPath.row)
        
        let tempHabitData0 = habitData[sourceIndexPath.row*3]
        let tempHabitData1 = habitData[sourceIndexPath.row*3+1]
        let tempHabitData2 = habitData[sourceIndexPath.row*3+2]
        for _ in 0...2{
            habitData.remove(at: sourceIndexPath.row*3)
        }
        habitData.insert(tempHabitData0, at: destinationIndexPath.row*3)
        habitData.insert(tempHabitData1, at: destinationIndexPath.row*3+1)
        habitData.insert(tempHabitData2, at: destinationIndexPath.row*3+2)
        
        
        let tempSwitchState = switchState[sourceIndexPath.row]
        switchState.remove(at: sourceIndexPath.row)
        switchState.insert(tempSwitchState, at: destinationIndexPath.row)
        
        UserDefaults.standard.set(uuid, forKey: "uuid")
        UserDefaults.standard.set(habits, forKey: "habits")
        UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
        UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
        UserDefaults.standard.set(habitData, forKey: "habitData")
        UserDefaults.standard.set(switchState, forKey: "switchState")
        
        habitsTable.reloadData()
        
        print ("UUIDs: \(uuid)")
        print ("habits: \(habits)")
        print ("notificationString: \(notificationsString)")
        print ("data: \(habitData)")
        print ("switchState: \(switchState)\n")
    }
    
    /* Controls the Switches for suspending and resuming notifications */
    @IBAction func cellSwitchAction(_ sender: UISwitch) {
        let row = sender.tag
        
        // Check if the habit is already expired
        if(habitData[row*3] as! Int == 2){
            if(dateInThePast(date: habitData[row*3+2] as! Date)){
                habitsTable.reloadData()
            }
        }
        
        if(sender.isOn){
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            // Switch is on, store this information
            switchState[row] = 1
            UserDefaults.standard.set(switchState, forKey: "switchState")
            print("Switch states: \(switchState)")
            
            // Find the uuids that were assoiciated with this row
            let uuidsForResume = uuid[row]
            
            // Set the body content for notifications that need rescheduling
            var bodyContentForNotification: String = ""
            if(habitDetails[row] == ""){
                bodyContentForNotification = "It is time to " + habits[row] + "!"
            }else{
                bodyContentForNotification = habitDetails[row]
            }
            
            // Reschedual the notifications
            let notificationType = habitData[row*3] as! Int
            switch notificationType{
            case 0: // If current row needs weekday notifications
                let DaysForResume = habitData[row*3+1] as! [Int]
                for index in 0..<DaysForResume.count{
                    print("Resumed uuid: \(uuidsForResume[index])")
                    delegate?.scheduleWeekdayNotifications(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification,  id: uuidsForResume[index], weekday: DaysForResume[index])
                }
            case 1: // If current row needs monthly notifications
                let DaysForResume = habitData[row*3+1] as! [Int]
                for index in 0..<DaysForResume.count{
                    print("Resumed uuid: \(uuidsForResume[index])")
                    delegate?.scheduleMonthdayNotifications(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification,  id: uuidsForResume[index], monthday: DaysForResume[index])
                }
            case 2: // If current row needs one-time notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleOneTimeNotification(at: habitData[row*3+2] as! Date, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
            case 3: // If current row does not need any notification which should not be triggerd since the switch is hidden
                assert(false, "FATAL: Reschedualing type 3 failed (switch should be hidden)")
            case 4: // If current row needs reoccuring notifications
                print("Resumed uuid: \(uuidsForResume[0])")
                delegate?.scheduleReoccurringNotification(interval: habitData[row*3+2] as! Int, title: habits[row], body: bodyContentForNotification, id: uuidsForResume[0])
            default: // Should not trigger
                assert(false, "FATAL: Unexpected case when reading notificationType from resumeFunData")
            }
        }// Remove notification requests assosiated with this row
        else{
            // Switch is off, store this information
            switchState[row] = 0
            UserDefaults.standard.set(switchState, forKey: "switchState")
            print("Switch states: \(switchState)")
            
            let center = UNUserNotificationCenter.current()
            
            for index in 0..<uuid[row].count{
                center.removeDeliveredNotifications(withIdentifiers: [uuid[row][index]])
                center.removePendingNotificationRequests(withIdentifiers: [uuid[row][index]])
            }
        }
    }
    
    /* Do tasks when a row is being edited (deletion only for now) */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Remove all information related to that row
        if editingStyle == UITableViewCellEditingStyle.delete{
            let center = UNUserNotificationCenter.current()
            print ("UUIDs Before deletion: \(uuid)")
            
            if isFiltering(){
                // Cancel future notifications related to the row and delete UUIDs
                for index in 0..<uuid[filteredIndexes[indexPath.row]].count{
                    center.removeDeliveredNotifications(withIdentifiers: [uuid[filteredIndexes[indexPath.row]][index]])
                    center.removePendingNotificationRequests(withIdentifiers: [uuid[filteredIndexes[indexPath.row]][index]])
                }
                uuid.remove(at: filteredIndexes[indexPath.row])
                habits.remove(at: filteredIndexes[indexPath.row])
                habitDetails.remove(at: filteredIndexes[indexPath.row])
                notificationsString.remove(at: filteredIndexes[indexPath.row])
                switchState.remove(at: filteredIndexes[indexPath.row])
                // There are 3 elements reserved for each row's data, so delete all three
                for _ in 0...2{
                    habitData.remove(at: (filteredIndexes[indexPath.row]*3))
                }
                
                updateSearchResults(for: searchController)
            }else{
                // Cancel future notifications related to the row and delete UUIDs
                for index in 0..<uuid[indexPath.row].count{
                    center.removeDeliveredNotifications(withIdentifiers: [uuid[indexPath.row][index]])
                    center.removePendingNotificationRequests(withIdentifiers: [uuid[indexPath.row][index]])
                }
                uuid.remove(at: indexPath.row)
                habits.remove(at: indexPath.row)
                habitDetails.remove(at: indexPath.row)
                notificationsString.remove(at: indexPath.row)
                switchState.remove(at: indexPath.row)
                // There are 3 elements reserved for each row's data, so delete all three
                for _ in 0...2{
                    habitData.remove(at: (indexPath.row*3))
                }
            }
            
            UserDefaults.standard.set(uuid, forKey: "uuid")
            UserDefaults.standard.set(habits, forKey: "habits")
            UserDefaults.standard.set(habitDetails, forKey: "habitDetails")
            UserDefaults.standard.set(notificationsString, forKey: "notificationsString")
            UserDefaults.standard.set(habitData, forKey: "habitData")
            UserDefaults.standard.set(switchState, forKey: "switchState")
            
            print ("UUIDs After deletion: \(uuid)\n")
            print ("switchState after deletion: \(switchState)\n")
            print ("habitData after deletion: \(habitData)\n")
            
            // Disable "Edit" button if no row is present
            if(habits.isEmpty){
                leftBarItem.title = "Edit"
                leftBarItem.isEnabled = false
                rightBarItem.isEnabled = true
            }else{
                leftBarItem.isEnabled = true
            }
            
            // Show quote is no row is present
            if(habits.isEmpty){
                quote.isHidden = false
                quoteAuthor.isHidden = false
            }
            
            habitsTable.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
