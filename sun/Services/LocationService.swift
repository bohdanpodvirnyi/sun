//
//  LocationService.swift
//  sun
//
//  Created by Bohdan on 3/23/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationService: NSObject {
    
    // MARK: - Properties
    
    private static var sharedLocationService: LocationService = {
        return LocationService()
    }()
    
    private let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    var currentSunInfo: SunInfo? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.SunInfoIsUpdated, object: nil)
        }
    }
    
    // MARK: - Accessors
    
    class func shared() -> LocationService {
        return sharedLocationService
    }
    
    // MARK: - Initializer
    
    func initiate() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        
        refreshLocation()
    }
    
    func refreshLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .restricted, .denied:
//                show error
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
//                show error
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            NetworkService.shared().getTiming(for: location.coordinate) { (result) in
                result
//                .withError()
                    .withValue({ (info) in
                        LocationService.shared().currentSunInfo = info
                    })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        refreshLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//            show error
    }
}
