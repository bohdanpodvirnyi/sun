//
//  LocationView.swift
//  sun
//
//  Created by Bohdan on 3/23/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import UIKit
import GooglePlaces

final class LocationView: UIView {
    
    @IBOutlet private var locationView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationTextField: UITextField!
    @IBOutlet private weak var autocompleteTableView: UITableView!
    
    static let minimumHeight: CGFloat = 140.0
    
    private var searchTimer: Timer?
    private var autocompleteList: [GMSAutocompletePrediction] = [] {
        didSet {
            autocompleteTableView.reloadData()
            autocompleteTableView.isHidden = autocompleteList.isEmpty
        }
    }
    
    var currentLocationName: String? {
        didSet {
            activityIndicator.stopAnimating()
            locationTextField.text = currentLocationName
            
            if LocationService.shared().preferredLocation != nil {
                titleLabel.text = "chosen location"
            } else {
                titleLabel.text = "current location"
            }
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
        
        locationTextField.addTarget(self, action: #selector(textFieldDidChangeEditing(_:)), for: .editingChanged)
        
        activityIndicator.startAnimating()
        
        autocompleteTableView.tableFooterView = UIView()
        autocompleteTableView.keyboardDismissMode = .onDrag
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
    
    private func openView() {
        changeHeight(to: self.superview?.frame.height ?? 0.0)
        
        titleLabel.text = "enter location:"
        editButton.setTitle("Done", for: .normal)
        locationTextField.isUserInteractionEnabled = true
        locationTextField.becomeFirstResponder()
        
        locationTextField.text = ""
    }
    
    private func closeView() {
        changeHeight(to: LocationView.minimumHeight)
        
        autocompleteList = []
        
        editButton.setTitle("Edit", for: .normal)
        locationTextField.isUserInteractionEnabled = false
        locationTextField.resignFirstResponder()
        
        locationTextField.text = currentLocationName
    }
    
    @IBAction private func refreshAction(_ sender: Any) {
        LocationService.shared().preferredLocation = nil
        activityIndicator.startAnimating()
        LocationService.shared().refreshLocation()
    }
    
    @IBAction private func editAction(_ sender: UIButton) {
        if self.frame.height == LocationView.minimumHeight {
            openView()
        } else {
            closeView()
        }
    }
}

extension LocationView {
    
    @objc private func textFieldDidChangeEditing(_ textField: UITextField) {
        searchTimer?.invalidate()
        
        let searchText = textField.text ?? ""
        if searchText.count >= 2 {
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                NetworkService.shared().findAutocompletePrediction(for: searchText) { [weak self] (result) in
                    guard let weakSelf = self else { return }
                    result
//                        .withError(show error)
                        .withValue({ (list) in
                            weakSelf.autocompleteList = list.filter({ $0.types.contains("locality") })
                        })
                }
            })
        }
    }
}

extension LocationView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        cell.selectionStyle = .none
        cell.textLabel?.text = autocompleteList[indexPath.row].attributedFullText.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPredictionItem = autocompleteList[indexPath.row]
        NetworkService.shared().getPlaceLocation(by: selectedPredictionItem.placeID) { [weak self] (result) in
            guard let weakSelf = self else { return }
            result
//                .withError(show error)
                .withValue({ (location) in
                    LocationService.shared().currentLocationName = selectedPredictionItem.attributedFullText.string
                    LocationService.shared().preferredLocation = location
                    LocationService.shared().refreshLocation()
                    weakSelf.closeView()
                })
        }
    }
    
}

extension LocationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        locationTextField.resignFirstResponder()
    }
}
