//
//  MapViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import MapKit

class MealPointAnnotation: MKPointAnnotation {
    var mealIndex: Int?
    
    override init() {
        super.init()
    }
    
    func setMeal(_ i: Int) {
        self.mealIndex = i
    }
}

class MapViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    var meals = [Meal]()
    var locationManager: CLLocationManager!
    var mapInitiallyLoaded = false
    var shouldReloadPins = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.delegate = self
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if (shouldReloadPins) {
            reloadPins()
            shouldReloadPins = false
        }
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
    
    // MARK: - Private Methods
    private func reloadPins() {
        meals = Meal.fetchHasLocation()
        mapView.removeAnnotations(mapView.annotations)
        let pins = meals.enumerated().map { (index, meal) -> MKPointAnnotation in
            let pin = MealPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: meal.latitude!, longitude: meal.longitude!)
            pin.title = meal.name
            pin.subtitle = meal.note
            pin.mealIndex = index
            return pin
        }
        mapView.addAnnotations(pins)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let util = LocationManagerUtil(locationManager: locationManager)
        util.handleChangeAuthorization(status: status, onAuthorized: {
            $0.startUpdatingLocation()
        }).map {
            present($0, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let util = LocationManagerUtil(locationManager: locationManager)
        let alert = util.handleFailWithError(error: error)
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
         locations.last.map {
         print($0)
         }
         */
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let reuseId = "Pin"
            let pinView = (mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)) as? MKPinAnnotationView ??
                MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.annotation = annotation
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView.rightCalloutAccessoryView = button
            return pinView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MealPointAnnotation, let i = annotation.mealIndex {
            let meal = self.meals[i]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let id = "MapMealDetailViewController"
            let mealViewController = storyboard.instantiateViewController(withIdentifier: id) as? MapMealDetailViewController
            mealViewController.map {
                $0.meal = meal
                $0.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController($0, animated: true)
            }
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (!self.mapInitiallyLoaded) {
            mapView.showAnnotations(mapView.annotations, animated: true)
            self.mapInitiallyLoaded = true
        }
    }
}
