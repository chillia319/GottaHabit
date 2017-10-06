//
//  ViewControllerTests.swift
//  HabitManager
//
//  Created by Alexis Barltrop on 5/25/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

//Import testing files
import XCTest
//Import app for testing with access to all functions etc
@testable import HabitManager

class ViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    //All testing funcitons must start with "test"
    
    func testCountRows() {
        let viewController = ViewController()
        viewController.habits.append("Happy")
        viewController.habits.append("Sad")
        
        XCTAssertEqual(viewController.tableView(UITableView: viewController.habitsTable,Int:2), 2)

        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
