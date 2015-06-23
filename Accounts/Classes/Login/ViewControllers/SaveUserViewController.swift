//
//  RegisterViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SaveUserViewController: ACFormViewController {
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user.UserID == 0 {
            
            title = "Register"
        }
        else {
            
            title = "Edit profile"
        }
        
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
        
        let saveButton = user.UserID == 0 ? UIBarButtonItem(title: "Register", style: .Plain, target: self, action: "save") : UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem?.tintColor = kNavigationBarPositiveActionColor
        
        navigationItem.rightBarButtonItem?.enabled = user.modelIsValid()
    }
    
    func save() {
        
        if user.UserID == 0 {
            
            user.webApiUpdate()?.onDownloadSuccessWithRequestInfo({ (json, request, httpUrlRequest, httpUrlResponse) -> () in
                
                let success = httpUrlResponse!.statusCode == 204
                
                if success {
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    
                    UIAlertView(title: "Oops!", message: "Something went wrong!", delegate: nil, cancelButtonTitle: "OK")
                }
            })
        }
        else {
            
            user.register()?.onContextSuccess({ () -> () in
                
                var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
                self.presentViewController(v, animated: true, completion: nil)
            })
        }
    }
}

extension SaveUserViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Username", value: user.Username, identifier: "Username"),
            FormViewConfiguration.textField("Email", value: user.Email, identifier: "Email"),
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

extension SaveUserViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FormViewTextFieldCell
        
        if indexPath.row == 2 {
            
            cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
            cell.textField.secureTextEntry = true
        }
        
        return cell
    }
}