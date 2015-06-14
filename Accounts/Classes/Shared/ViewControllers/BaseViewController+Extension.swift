//
//  BaseViewController+Extension.swift
//  Accounts
//
//  Created by Alex Bechmann on 10/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

extension BaseViewController {
    
    func setupView() {
        
        view.backgroundColor = kViewBackgroundColor
    }
    
    func addCloseButton() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
    }
    
    func close() {
        
        dismissViewControllerFromCurrentContextAnimated(true)
    }
    
    func setupTableViewCellAppearance(originalCell: UITableViewCell) {
        
        if let cell = originalCell as? FormViewTextFieldCell {
            
            cell.label.textColor = kTableViewCellTextColor
            cell.textField.textColor = kTableViewCellDetailTextColor
        }
        
        originalCell.textLabel?.textColor = kTableViewCellTextColor
        originalCell.detailTextLabel?.textColor = kTableViewCellDetailTextColor
    }
    
    func setBackgroundGradient() {
        
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [kViewBackgroundGradientTop.CGColor, kViewBackgroundGradientBottom.CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
}