//
//  NetworkService.swift
//  sun
//
//  Created by Bohdan on 3/23/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import GooglePlaces

final class NetworkService {
    
    // MARK: - Properties
    
    private static var sharedNetworkService: NetworkService = {
        return NetworkService()
    }()
    
    static let googlePlacesApiKey: String = "AIzaSyAB12oBtV1KJcMiYiGUfy9VoTQYnzzuo14"
    static let googleTimeZonesApiKey: String = "AIzaSyBO0Mb1fZmCQaODFzpv2Q79nfzIdRqL2gw"
    
    private let apiBaseUrl: String = "https://api.sunrise-sunset.org/json"
    private let timeZoneUrl: String = "https://maps.googleapis.com/maps/api/timezone/json"
    
    private let token = GMSAutocompleteSessionToken.init()
    
    // MARK: - Accessors
    
    class func shared() -> NetworkService {
        return sharedNetworkService
    }
    
    func getTiming(for coordinates: CLLocationCoordinate2D, _ completion: @escaping (Result<SunInfo>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = createBaseUrl(for: coordinates)
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            response.result
                .withError({ error in completion(.failure(error)) })
                .withValue({ (value) in
                    guard let result = value as? [String: AnyObject] else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: ""])))
                        return
                    }
                    if let status = result["status"] as? String {
                        if status == "OK" {
                            let info = SunInfo(result: result["results"] as? NSDictionary)
                            completion(.success(info))
                            return
                        }
                    }
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: ""])))
                })
        })
    }
    
    func findAutocompletePrediction(for string: String, _ completion: @escaping (Result<[GMSAutocompletePrediction]>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GMSPlacesClient.shared().findAutocompletePredictions(
            fromQuery: string,
            bounds: nil,
            boundsMode: .bias,
            filter: nil,
            sessionToken: token
        ) { (predictionsList, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let list = predictionsList {
                completion(.success(list))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func getPlaceLocation(by placeId: String, _ completion: @escaping (Result<CLLocation>) -> Void) {
        GMSPlacesClient.shared().fetchPlace(
            fromPlaceID: placeId,
            placeFields: .coordinate,
            sessionToken: token
        ) { (place, error) in
            if let place = place {
                let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                NetworkService.shared().getPlaceTimeZone(for: location, { (result) in
                    result
                    .withError({ error in completion(.failure(error)) })
                    .withValue({ (value) in
                        LocationService.shared().currentTimeZone = value
                        completion(.success(location))
                    })
                })
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    private func getPlaceTimeZone(for location: CLLocation, _ completion: @escaping (Result<TimeZone>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = createTimeZoneUrl(for: location.coordinate)
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            response.result
                .withError({ error in completion(.failure(error)) })
                .withValue({ (value) in
                    guard let result = value as? [String: AnyObject] else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: ""])))
                        return
                    }
                    if result["status"] as! String == "OK" {
                        let timeZone = TimeZone(identifier: result["timeZoneId"] as? String ?? "")
                        completion(.success(timeZone ?? TimeZone.current))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: ""])))
                    }
                })
        })
    }
    
    private func createBaseUrl(for coordinates: CLLocationCoordinate2D) -> String {
        return apiBaseUrl + "?lat=\(coordinates.latitude)&lng=\(coordinates.longitude)"
    }
    
    private func createTimeZoneUrl(for coordinates: CLLocationCoordinate2D) -> String {
        return timeZoneUrl + "?location=\(coordinates.latitude),\(coordinates.longitude)&timestamp=\(Date().timeIntervalSinceNow)&key=" + NetworkService.googleTimeZonesApiKey
    }
    
}
