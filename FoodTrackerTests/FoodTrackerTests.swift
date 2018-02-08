//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by 南優也 on 2018/02/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    // MARK: Meal Class Tests
    func testMealInitializationSucceeds() {
        let zeroRating = Meal.init(name: "zeroRating", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRating)
        
        let positiveRating = Meal.init(name: "positiveRating", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRating)
    }
    func testMealInitializationFails() {
        let negativeRating = Meal.init(name: "negativeRating", photo: nil, rating: -1)
        XCTAssertNil(negativeRating)
        
        let largeRating = Meal.init(name: "largeRating", photo: nil, rating: 6)
        XCTAssertNil(largeRating)
        
        let emptyName = Meal.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyName)
    }
}
