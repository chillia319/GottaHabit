//
//  HabitManagerUITests.swift
//  HabitManagerUITests
//
//  Created by Alexis Barltrop on 5/27/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import XCTest

class HabitManagerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAddOneDailyHabit() {
        
        let app = XCUIApplication()
        let table = app.tables.element(boundBy: 0)
        let numRows = table.cells.count
        
        app.navigationBars["All Habits"].buttons["Add"].tap()
        app.tables.buttons["Daily"].tap()
        
        let tablesQuery = app.tables
        print(tablesQuery)
        tablesQuery.textFields["Stand up for 2 minutes"].tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element.typeText("Daily")
        app.buttons["Done"].tap()
        
        app.navigationBars["New Habit"].buttons["Save"].tap()
        
        let expectedRows = numRows+1
        
        XCTAssertEqual(table.cells.count, expectedRows)
    }
    
    /**
     *  Manually adds 100 empty habits - no alerts.
     *
     */
    
    func Add100Habits(){
        let app = XCUIApplication()
        let habitString = "Habit"
        let upperLimit = 1000
        var habitNumber = 0
        
        while habitNumber < upperLimit {
        app.navigationBars["All Habits"].buttons["Add"].tap()
        //app.tables.buttons["Daily"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["Stand up for 2 minutes"].tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element.typeText(habitString+String(habitNumber))
        app.typeText("\r")
            
        
        app.navigationBars["New Habit"].buttons["Save"].tap()
        
        habitNumber += 1
        }
        

    }
    
    func testDeleteOneDailyHabit(){
        
        let app = XCUIApplication()
        let table = app.tables.element(boundBy: 0)
        let numRows = table.cells.count
        
        app.navigationBars["All Habits"].buttons["Add"].tap()
        let tablesQuery = app.tables
        tablesQuery.textFields["Stand up for 2 minutes"].tap()
        
        let textField = tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("DailyTestHabit")
        
        app.buttons["Done"].tap()
        app.navigationBars["New Habit"].buttons["Save"].tap()
        
        
        tablesQuery.staticTexts["DailyTestHabit"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        XCTAssertEqual(table.cells.count, numRows)
    }
    
    
    
}
