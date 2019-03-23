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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationView.currentLocation = "Lviv"
    }


}

