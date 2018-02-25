//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/09.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import os.log
import CoreData

class MealTableViewController: UITableViewController {
    // MARK: Properties
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        let savedMeals = loadMeals()
        if (savedMeals.count > 0) {
            meals += savedMeals
        } else {
            loadSampleMeals()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        // downcast cell to MealTableViewCell and unwrap
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeue cell is not a instance of MealTableViewCell")
        }
        
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected identifier: \(segue.identifier ?? "nil")")
        }
    }

    // MARK: Private Methods
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")

        guard let meal1 = Meal.init(name: "Caprese Salad", photo: photo1, rating: 4, dateTime: nil, model: nil) else {
            fatalError("Unable to initialize meal1")
        }
        
        guard let meal2 = Meal.init(name: "Chicken and Potatoes", photo: photo2, rating: 5, dateTime: nil, model: nil) else {
            fatalError("Unable to initialize meal2")
        }
        guard let meal3 = Meal.init(name: "Pasta with Meatballs", photo: photo3, rating: 3, dateTime: nil, model: nil) else {
            fatalError("Unable to initialize meal3")
        }
        
        meals += [meal1, meal2, meal3]
    }
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
                    model: $0
                    ) else {
                        fatalError("Failed to initialize Meal")
                }
                return meal
            }

        } catch {
            fatalError("Failed to load data")
        }
    }
    
    // MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController,
            let meal = sourceViewController.meal {
            if let selectedIndex = tableView.indexPathForSelectedRow {
                meals[selectedIndex.row] = meal
                tableView.reloadRows(at: [selectedIndex], with: .none)
            } else {
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

}
