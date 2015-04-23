//
//  LoginViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 11/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

let kTableViewTopMargin: CGFloat = 64
let kTableViewPadding: CGFloat = 0
let kCellHeight: CGFloat = 50

class LoginViewController: BaseViewController {

    var tableView = UITableView()
    var textFields: Array<UITextField> = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.setupTableView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "login")
    }
    
    func setupTableView(){
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        
        self.tableView.addTopConstraint(toView: self.view, relation: .Equal, constant: kTableViewTopMargin)
        self.tableView.addLeftConstraint(toView: self.view, relation: .Equal, constant: kTableViewPadding)
        self.tableView.addRightConstraint(toView: self.view, relation: .Equal, constant: -kTableViewPadding)
        self.tableView.addHeightConstraint(relation: .Equal, constant: (2 * kCellHeight))
        
        self.tableView.registerClass(TextFieldWithLabelTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.scrollEnabled = false
        self.tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
    }
    
    func login() {

        var usernameTextField = self.textFields[0]
        var passwordTextField = self.textFields[1]
        
        Session.sharedInstance().login(usernameTextField.text, password: passwordTextField.text).onContextSuccess { () -> () in
            
            User.getObjectFromJsonAsync(Session.sharedInstance().activeUser.UserID, completion: { (object:User) -> () in
                
                Session.sharedInstance().activeUser = object
                
                var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
                self.presentViewController(v, animated: true, completion: nil)
            })
            
        }.onContextFailure { () -> () in
            
            UIAlertView(title: "Login Failed", message: "Incorrect username or password!", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
}

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TextFieldWithLabelTableViewCell
        
        cell.label.text = indexPath.row == 0 ? "Username" : "Password"
        cell.textField.text = indexPath.row == 0 ? "Alex" : "pass"
        
        if indexPath.row == 1 {
            
            cell.textField.secureTextEntry = true
        }
        
        self.textFields.append(cell.textField)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        textFields[indexPath.row].becomeFirstResponder()
    }
    
}
