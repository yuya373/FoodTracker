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
    var name: String {
        didSet {
            os_log("didSet [Name]", log: OSLog.default, type: .debug)
            updateModelName()
        }
    }
    var photo: UIImage? {
        didSet {
            updateModelPhoto()
        }
    }
    var rating: Int {
        didSet {
            updateModelRating()
        }
    }
    var model: MealModel
    var dateTime: Date? {
        didSet {
            os_log("didSet [dateTime]", log: OSLog.default, type: .debug)
            updateModelDateTime()
        }
    }
    var note: String? {
        didSet {
            updateModelNote()
        }
    }
    var latitude: Double? {
        didSet {
            updateModelLatitude()
        }
    }
    var longitude: Double? {
        didSet {
            updateModelLongitude()
        }
    }
    
    static func load() -> [Meal] {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("failed to fetch Delegate")
        }
        let context = delegate.persistentContainer.viewContext
        do {
            let request: NSFetchRequest<MealModel> = MealModel.fetchRequest()
            let mealModels = try context.fetch(request)
            return mealModels.map {
                guard let meal = Meal.init(
                    name: $0.name ?? "",
                    photo: $0.photo.flatMap { UIImage(data: $0) },
                    rating: Int($0.rating),
                    dateTime: $0.dateTime,
                    note: $0.note,
                    model: $0
                    ) else {
                        fatalError("Failed to initialize Meal")
                }
                meal.latitude = $0.latitude == 0.0 ? nil : $0.latitude
                meal.longitude = $0.longitude == 0.0 ? nil : $0.longitude
                return meal
            }
        } catch {
            fatalError("Failed to load data")
        }
    }
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, dateTime: Date?, note: String?, model: MealModel?) {
        guard !name.isEmpty else {
            // need initializer failable (init? || init!)
            // ? return optional value
            // ! return implicitly unwrapped optional value
            return nil
        }
        guard 0 <= rating && rating <= 5 else {
            return nil
        }
        
        os_log("init [Name]", log: OSLog.default, type: .debug)
        self.name = name
        self.photo = photo
        self.rating = rating
        self.dateTime = dateTime
        self.note = note
        self.longitude = model.map { $0.longitude }
        self.latitude = model.map { $0.latitude }

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("failed to fetch Delegate")
        }
        
        self.model = model ?? MealModel(context: delegate.persistentContainer.viewContext)
        initModel()
    }
    
    func formattedDate() -> String? {
        return self.dateTime.map { dateTime in
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: dateTime)
        }
    }

    // MARK: Update MealModel
    
    func delete() {
        let m = model
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("failed to fetch Delegate")
        }
        let context = delegate.persistentContainer.viewContext
        context.delete(m)
    }
    
    private func updateModelName() {
        self.model.name = name
    }
    
    private func updateModelRating() {
        self.model.rating = Int16(rating)
    }
    
    private func updateModelPhoto() {
        self.photo.map {
            self.model.photo = UIImagePNGRepresentation($0)
        }
    }
    
    private func updateModelDateTime() {
        self.model.dateTime = self.dateTime
    }
    
    private func updateModelNote() {
        self.model.note = self.note
    }
    
    private func updateModelLatitude() {
        self.model.latitude = self.latitude ?? 0.0
    }
    
    private func updateModelLongitude() {
        self.model.longitude = self.longitude ?? 0.0
    }
    
    private func initModel() {
        updateModelName()
        updateModelRating()
        updateModelPhoto()
        updateModelDateTime()
        updateModelNote()
        updateModelLatitude()
        updateModelLongitude()
    }
}
