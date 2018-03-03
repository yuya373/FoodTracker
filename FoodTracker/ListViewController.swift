//
//  ListViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import os.log
import CoreData

class ListViewController: UIViewController {
    // MARK: - Properties
    var meals = [Meal]()
    @IBOutlet weak var mealTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mealTableView.delegate = self
        mealTableView.dataSource = self

        let savedMeals = loadMeals()
        if (savedMeals.count > 0) {
            meals += savedMeals
        } else {
            loadSampleMeals()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "nil")")
            }
            guard let indexPath = mealTableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected identifier: \(segue.identifier ?? "nil")")
        }
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController,
            let meal = sourceViewController.meal {
            if let selectedIndex = mealTableView.indexPathForSelectedRow {
                meals[selectedIndex.row] = meal
                mealTableView.reloadRows(at: [selectedIndex], with: .none)
            } else {
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                mealTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    // MARK: - Private Methods
    
    private func loadMeals() -> [Meal] {
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
    
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal.init(name: "Caprese Salad", photo: photo1, rating: 4, dateTime: nil, note: nil, model: nil) else {
            fatalError("Unable to initialize meal1")
        }
        
        guard let meal2 = Meal.init(name: "Chicken and Potatoes", photo: photo2, rating: 5, dateTime: nil, note: nil, model: nil) else {
            fatalError("Unable to initialize meal2")
        }
        guard let meal3 = Meal.init(name: "Pasta with Meatballs", photo: photo3, rating: 3, dateTime: nil, note: nil, model: nil) else {
            fatalError("Unable to initialize meal3")
        }
        
        meals += [meal1, meal2, meal3]
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        // downcast cell to MealTableViewCell and unwrap
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MealTableViewCell else {
            fatalError("The dequeue cell is not a instance of MealTableViewCell")
        }
        
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let meal = meals[indexPath.row]
            meal.delete()
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

extension ListViewController: UITableViewDelegate {
    
}
