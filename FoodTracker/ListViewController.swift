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
                mealTableView.deselectRow(at: selectedIndex, animated: true)
            } else {
                print("No Meal!")
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                mealTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    // MARK: - Private Methods
    
    private func loadMeals() -> [Meal] {
        return Meal.load()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let id = "MealViewController"
        let mealViewController = storyboard.instantiateViewController(withIdentifier: id) as? MealViewController
        let meal = meals[indexPath.row]
        mealViewController.map {
            $0.meal = meal
            $0.hidesBottomBarWhenPushed = true
            $0.navigationItem.leftBarButtonItem = nil
            navigationController?.pushViewController($0, animated: true)
        }
    }
}
