//
//  LocationService.swift
//  Weather
//
//  Created by Jan Konieczny on 18/08/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation




class LocationFetcher: NSObject, CLLocationManagerDelegate, ObservableObject{
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
    
   
}


