//
//  MapViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    var meals = [Meal]()
    var locationManager: CLLocationManager!
    var mapInitiallyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        meals = Meal.load()
        
        locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.delegate = self
        
        mapView.delegate = self
        
        showMeals()
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
    private func showMeals() {
        let pins = meals.map { meal -> MKPointAnnotation? in
            if let latitude = meal.latitude, let longitude = meal.longitude {
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                pin.title = meal.name
                return pin
            }
            return nil
        }
        mapView.addAnnotations(pins.flatMap({ $0 }))
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
            return pinView
        } else {
            return nil
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (!self.mapInitiallyLoaded) {
            mapView.showAnnotations(mapView.annotations, animated: true)
            self.mapInitiallyLoaded = true
        }
    }
}
