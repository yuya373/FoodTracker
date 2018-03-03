//
//  LocationManagerUtil.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import MapKit

class LocationManagerUtil {
    let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    func handleChangeAuthorization(status: CLAuthorizationStatus, onAuthorized: ((CLLocationManager) -> Void)?) -> UIAlertController? {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization();
        case .denied:
            let alert = UIAlertController(title: "Enable Location", message: "Settings -> Privacy -> Location", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {action in
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                    fatalError("Can't get Settings url.")
                }
                if (UIApplication.shared.canOpenURL(url)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            return alert
        case .restricted:
            let alert = UIAlertController(title: "Location can't be use", message: "This device has GPS?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            return alert
        case .authorizedAlways:
            break;
        case .authorizedWhenInUse:
            if let cb = onAuthorized {
                cb(locationManager)
            } else {
                locationManager.requestLocation()
            }
            break;
        }
        return nil
    }
    
    func handleFailWithError(error: Error) -> UIAlertController {
        let alert = UIAlertController(title: "Error in Location", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        return alert
    }
}

