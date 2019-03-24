//
//  ViewController.swift
//  sun
//
//  Created by Bohdan on 3/22/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var locationView: LocationView!
    @IBOutlet private weak var sunriseLabel: UILabel!
    @IBOutlet private weak var sunsetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSunInfo), name: NSNotification.Name.SunInfoIsUpdated, object: nil)
        locationView.currentLocationName = "Lviv"
    }
    
    @objc private func updateSunInfo() {
        guard let info = LocationService.shared().currentSunInfo else { return }
        DispatchQueue.main.async {
            self.view.subviews.filter({
                $0 is UIActivityIndicatorView
            }).forEach({
                ($0 as? UIActivityIndicatorView)?.stopAnimating()
            })
            self.sunriseLabel.text = info.sunriseTime
            self.sunriseLabel.isHidden = false
            self.sunsetLabel.text = info.sunsetTime
            self.sunsetLabel.isHidden = false
        }
    }

}

