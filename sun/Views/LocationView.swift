//
//  LocationView.swift
//  sun
//
//  Created by Bohdan on 3/23/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import UIKit

final class LocationView: UIView {
    
    @IBOutlet private var locationView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var locationTextField: UITextField!
    
    static let minimumHeight: CGFloat = 140.0
    
    var currentLocationName: String? {
        didSet {
            activityIndicator.stopAnimating()
            locationTextField.text = currentLocationName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LocationView", owner: self, options: nil)
        
        self.addSubview(locationView)
        
        locationView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        locationView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        locationView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        locationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        locationTextField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        locationTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        
        activityIndicator.startAnimating()
    }
    
    private func changeHeight(to newHeight: CGFloat) {
        guard
            let heightConstraint = self.constraintsAffectingLayout(for: .vertical).first(
                where: { $0.firstAttribute == .height }
            )
        else { return }
        
        heightConstraint.constant = newHeight
        
        animateLayout()
    }
    
    private func animateLayout() {
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
    
    @IBAction private func refreshAction(_ sender: Any) {
        activityIndicator.startAnimating()
        LocationService.shared().refreshLocation()
    }
    
    @IBAction private func editAction(_ sender: UIButton) {
        if self.frame.height == LocationView.minimumHeight {
            changeHeight(to: self.superview?.frame.height ?? 0.0)
            
            sender.setTitle("Done", for: .normal)
            locationTextField.isUserInteractionEnabled = true
            locationTextField.becomeFirstResponder()
        } else {
            changeHeight(to: LocationView.minimumHeight)
            
            sender.setTitle("Edit", for: .normal)
            locationTextField.isUserInteractionEnabled = false
            locationTextField.resignFirstResponder()
        }
    }
}

extension LocationView {
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = currentLocationName
        }
    }
}
