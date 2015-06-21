//
//  LoginViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

//class LoginViewController: ACFormViewController {
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupTableView(tableView, delegate: self, dataSource: self)
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        return UITableViewCell()
//    }
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        println("hi")
//    }
//}


class LoginViewController: ACFormViewController {

    var user = User()
    
    override func viewDidLoad() {
        formViewDelegate = self
        
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "login")
        navigationItem.rightBarButtonItem?.tintColor = kNavigationBarPositiveActionColor
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        title = "Login"
    }
    
    override func setupView() {
        super.setupView()
        
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func login() {
        
        var showAlert: () -> () = {
            
            UIAlertView(title: "Login failed!", message: "Incorrect username or password!", delegate: nil, cancelButtonTitle: "OK").show()
        }
        
        if user.Username.length() > 0 && user.Password.length() > 0 {
            
            User.login(user.Username, password: user.Password).onContextSuccess { () -> () in
                
                var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
                self.presentViewController(v, animated: true, completion: nil)
                
            }.onContextFailure { () -> () in
                    
                showAlert()
            }
        }
        else {
            
            showAlert()
        }
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


extension LoginViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Username", value: "", identifier: "Username"),
            FormViewConfiguration.textField("Password", value: "", identifier: "Password")
        ])
        return sections
    }
    
    func formViewTextFieldEditingChanged(identifier: String, text: String) {
        
        switch identifier {
            
        case "Username":
        user.Username = text
        break
            
        case "Password":
        user.Password = text
        break;
            
        default: break;
        }
    }
}

extension LoginViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FormViewTextFieldCell
        
        if indexPath.row == 1 {
            
            cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
            cell.textField.secureTextEntry = true
        }
        
        cell.label.textColor = UIColor.blackColor()
        cell.textField.textColor = UIColor.lightGrayColor()
        
        return cell
    }
}