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
    
//    func setupTableViewCellAppearance(originalCell: UITableViewCell) {
//        
//        if isInsidePopover() {
//            
//            originalCell.textLabel?.textColor = UIColor.blackColor()
//            originalCell.detailTextLabel?.textColor = UIColor.lightGrayColor()
//            originalCell.backgroundColor = UIColor.whiteColor()
//            originalCell.tintColor = AccountColor.positiveColor() 
//        }
//            
//        else {
//            
//            originalCell.textLabel?.textColor = kTableViewCellTextColor
//            originalCell.detailTextLabel?.textColor = kTableViewCellDetailTextColor
//        }
//        
//        if let cell = originalCell as? FormViewTextFieldCell {
//            
//            if isInsidePopover() {
//                
//                cell.label.textColor = UIColor.blackColor()
//                cell.textField.textColor = UIColor.lightGrayColor()
//            }
//            else {
//                
//                cell.label.textColor = kTableViewCellTextColor
//                cell.textField.textColor = kTableViewCellDetailTextColor
//            }
//            
//        }
//    }
    
    func setBackgroundGradient() {
        
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [kViewBackgroundGradientTop.CGColor, kViewBackgroundGradientBottom.CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func setTableViewAppearanceForBackgroundGradient(tableView: UITableView) {
        
        tableView.separatorStyle = kTableViewCellSeperatorStyle
        tableView.separatorColor = kTableViewCellSeperatorColor
        tableView.backgroundColor = kTableViewBackgroundColor
    }
    
    func setTableViewCellAppearanceForBackgroundGradient(cell:UITableViewCell) {
    
        cell.backgroundColor = kTableViewCellBackgroundColor
        cell.textLabel?.textColor = kTableViewCellTextColor
        cell.tintColor = kTableViewCellTintColor
    }
    
    func isInsidePopover() -> Bool {

        return view.frame != UIScreen.mainScreen().bounds
    }
}