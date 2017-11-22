//
//  LocationHelper.swift
//  Nimble PNM
//
//  Created by ksolves on 25/09/17.
//  Copyright © 2017 ksolves. All rights reserved.
//

import UIKit
import CoreLocation

//CONTANTS
let CONST_MSG_LOCATION_SERVICE_UNAVAILABLE = "Location services are currently unavailable"
let CONST_MSG_LOCATION_SERVICE_DENY = "App is not authorised to use location. Please grant permission from settings"
let CONST_MSG_LOCATION_SERVICE_GRANTED = "Access is granted"

class LocationHelper: NSObject, CLLocationManagerDelegate {

    
    
    var currentLocation : CLLocationCoordinate2D!
    var locationManager = CLLocationManager()
    var status : CLAuthorizationStatus!
    
    override init() {
        super.init()
        
    }
    
    func configureLocationManager(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus(){
            
            case .notDetermined :
                locationManager.requestWhenInUseAuthorization()
                break
            
            default: break
            
        }
        
    }
    
    func startUpdating() -> String{
        
        if CLLocationManager.locationServicesEnabled(){
            status =  CLLocationManager.authorizationStatus()
            if status == .authorizedAlways || status == .authorizedWhenInUse{
                locationManager.startUpdatingLocation()
                return CONST_MSG_LOCATION_SERVICE_GRANTED
                
            }else{
                return CONST_MSG_LOCATION_SERVICE_DENY
                
            }
            
        }else{
            return CONST_MSG_LOCATION_SERVICE_UNAVAILABLE
            
        }
    }
    
    func stopUpdating(){
        locationManager.stopUpdatingLocation()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (manager.location?.coordinate)!
        stopUpdating()
        print(currentLocation)
    }
    
    
}
