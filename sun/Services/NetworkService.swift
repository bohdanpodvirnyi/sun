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

final class NetworkService {
    
    // MARK: - Properties
    
    private static var sharedNetworkService: NetworkService = {
        return NetworkService()
    }()
    
    private let apiBaseUrl: String = "https://api.sunrise-sunset.org/json"
    private let googleApiKey: String = "AIzaSyAB12oBtV1KJcMiYiGUfy9VoTQYnzzuo14"
    
    // MARK: - Accessors
    
    class func shared() -> NetworkService {
        return sharedNetworkService
    }
    
    func getTiming(for coordinates: CLLocationCoordinate2D, _ completion: @escaping (Result<SunInfo>) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = createUrl(for: coordinates)
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
    
    private func createUrl(for coordinates: CLLocationCoordinate2D) -> String {
        return apiBaseUrl + "?lat=\(coordinates.latitude)&lng=\(coordinates.longitude)"
    }
    
}
