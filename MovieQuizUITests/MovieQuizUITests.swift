//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Андрей Чупрыненко on 15.08.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testScreenCast() throws {
        
        let app = XCUIApplication()
        let button = app.buttons["Да"]
        button.tap()
        
        let button2 = app.buttons["Нет"]
        button2.tap()
        button.swipeUp()
        button.swipeUp()
        button2.tap()
        
        let element = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.swipeRight()
        app/*@START_MENU_TOKEN@*/.scrollViews/*[[".windows[\"SBSwitcherWindow:Main\"]",".otherElements[\"AppSwitcherContentView\"]",".otherElements[\"MovieQuiz\"].scrollViews",".otherElements[\"card:a.chuprynenko:sceneID:a.chuprynenko-default\"].scrollViews",".scrollViews"],[[[-1,4],[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,2],[-1,1,2]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.otherElements.statusBars.children(matching: .other).element.children(matching: .other).element.tap()
        element.swipeDown()
        app.otherElements["ControlCenterView"].children(matching: .scrollView).element.swipeUp()
        
    }

    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()

        
    }
}
