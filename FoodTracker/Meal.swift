//
//  Meal.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/08.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import os.log
import CoreData

class Meal {
    // MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    var model: MealModel
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, model: MealModel?) {
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
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("failed to fetch Delegate")
        }
        self.model = model ?? MealModel(context: delegate.persistentContainer.viewContext)
        save()
    }

    func save() {
        let m = self.model
        m.name = name
        photo.map {
            m.photo = UIImagePNGRepresentation($0)
        }
        m.rating = Int16(rating)
     }
    
    func delete() {
        let m = model
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("failed to fetch Delegate")
        }
        let context = delegate.persistentContainer.viewContext
        context.delete(m)
    }
}
