//
//  AddHabitVCTests.swift
//  HabitManager
//
//  Created by Alexis Barltrop on 5/25/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import XCTest
@testable import HabitManager


class AddHabitVCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    //Want ot check that the save button is disabled if the description is empty
    func CheckDescriptionFalse() {
        let habitVC = AddHabitVC()
        
        habitVC.habitDescription.text = ""
        habitVC.checkDescription()
        XCTAssertFalse(habitVC.saveButton.isEnabled)
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
