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
        
        showOrHideRegisterButton()
    }
    
    override func setupView() {
        super.setupView()
        
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func showOrHideRegisterButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .Plain, target: self, action: "register")
        navigationItem.rightBarButtonItem?.tintColor = kNavigationBarPositiveActionColor
        
        navigationItem.rightBarButtonItem?.enabled = user.modelIsValid()
    }
    
    func register() {
        
        user.register()?.onContextSuccess({ () -> () in
            
            var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
            self.presentViewController(v, animated: true, completion: nil)
        })
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
    
    func formViewElementDidChange(identifier: String, value: AnyObject?) {

        showOrHideRegisterButton()
    }
    
    func formViewTextFieldEditingChanged(identifier: String, text: String) {
        
        switch identifier {
            
        case "Username":
            user.Username = text
            break
            
        case "Password":
            user.Password = text
            break;
            
        case "Email":
            user.Email = text
            break
            
            
        default: break;
        }
    }
}

extension RegisterViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FormViewTextFieldCell
        
        if indexPath.row == 2 {
            
            cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
            cell.textField.secureTextEntry = true
        }
        
        return cell
    }
}