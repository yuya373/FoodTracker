//
//  Meal.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/08.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit

class Meal {
    // MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int) {
        guard !name.isEmpty else {
            // need initializer failable (init? || init!)
            // ? return optional value
            // ! return implicitly unwrapped optional value
            return nil
        }
        guard 0 <= rating && rating <= 5 else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
    }
}
