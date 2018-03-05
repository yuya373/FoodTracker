//
//  MapMealDetailViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/04.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit

class MapMealDetailViewController: UIViewController {
    @IBOutlet weak var mealDateLabel: UILabel!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealTextView: UITextView!
    @IBOutlet weak var mealRatingControl: RatingControl!
    // MARK: - Properties
    
    var meal: Meal?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let meal = self.meal {
            navigationItem.title = meal.name
            mealImageView.image = meal.photo
            mealTextView.text = meal.note
            mealRatingControl.rating = meal.rating
            mealDateLabel.text = meal.formattedDate() ?? ""
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
