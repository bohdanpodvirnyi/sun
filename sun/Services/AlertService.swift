//
//  AlertService.swift
//  sun
//
//  Created by Bohdan on 3/25/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import UIKit

final class AlertService: NSObject {
    
    // MARK: - Properties
    
    private static var sharedAlertService: AlertService = {
        return AlertService()
    }()
    
    // MARK: - Accessors
    
    class func shared() -> AlertService {
        return sharedAlertService
    }
    
    func showError(_ error: Error) {
        AlertService.shared().showError(with: error.localizedDescription)
    }
    
    func showError(with message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        viewController.present(alert, animated: true, completion: nil)
    }
}
