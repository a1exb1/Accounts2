//
//  RegisterViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class RegisterViewController: ACFormViewController {
    
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
    }
    
    override func setupView() {
        super.setupView()
        
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    override func setupTableViewConstraints(tableView: UITableView) {
        
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        tableView.addLeftConstraint(toView: view, attribute: NSLayoutAttribute.Left, relation: NSLayoutRelation.GreaterThanOrEqual, constant: -0)
        tableView.addRightConstraint(toView: view, attribute: NSLayoutAttribute.Right, relation: NSLayoutRelation.GreaterThanOrEqual, constant: -0)
        
        tableView.addWidthConstraint(relation: NSLayoutRelation.LessThanOrEqual, constant: kTableViewMaxWidth)
        
        tableView.addTopConstraint(toView: view, relation: .Equal, constant: 0)
        tableView.addBottomConstraint(toView: view, relation: .Equal, constant: 0)
        
        tableView.addCenterXConstraint(toView: view)
    }
}

extension RegisterViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Username", value: user.Username, identifier: "Username"),
            FormViewConfiguration.textField("Email", value: user.Username, identifier: "Email"),
            FormViewConfiguration.textField("Password", value: user.Password, identifier: "Password")
        ])
        return sections
    }
}

extension RegisterViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FormViewTextFieldCell
        
        if indexPath.row == 1 {
            
            cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
            cell.textField.secureTextEntry = true
        }
        
        return cell
    }
}