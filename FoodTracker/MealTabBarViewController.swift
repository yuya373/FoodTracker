//
//  MealTabBarViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/04.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit

class MealTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
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

extension MealTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let alreadyDisplayMapView = (selectedViewController as? UINavigationController)?.visibleViewController is MapViewController
        if (alreadyDisplayMapView) {
            return true
        }
        
        if let navCon = viewController as? UINavigationController,
            let mapViewController = navCon.visibleViewController as? MapViewController {
            mapViewController.shouldReloadPins = true
        }
        
        return true
    }
}
