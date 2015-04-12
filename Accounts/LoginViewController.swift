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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Bordered, target: self, action: "login")
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
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.scrollEnabled = false
        self.tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
    }
    
    func login() {

        var usernameTextField = self.textFields[0]
        var passwordTextField = self.textFields[1]
        
        Session.sharedInstance().login(usernameTextField.text, password: passwordTextField.text) { (success) -> () in
            
            if success {
                
                User.getObjectFromJsonAsync(Session.sharedInstance().activeUser.UserID, completion: { (object) -> () in
                    
                    Session.sharedInstance().activeUser = object! as User
                    
                    var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
                    self.presentViewController(v, animated: true, completion: nil)
                })
                
                
            }
            else{
                
                UIAlertView(title: "Login Failed", message: "Incorrect username or password!", delegate: nil, cancelButtonTitle: "OK").show()
            }
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.contentView.addSubview(label)
        
        label.text = indexPath.row == 0 ? "Username" : "Password"
        
        label.addTopConstraint(toView: cell.contentView, relation: .Equal, constant: 0)
        label.addLeftConstraint(toView: cell.contentView, relation: .Equal, constant: 15)
        label.addBottomConstraint(toView: cell.contentView, relation: .Equal, constant: 0)
        label.addWidthConstraint(relation: .Equal, constant: 100)
        
        var textField = UITextField()
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.contentView.addSubview(textField)
        
        textField.addTopConstraint(toView: cell.contentView, relation: .Equal, constant: 0)
        textField.addLeftConstraint(toView: label, attribute: .Right, relation: .Equal, constant: 15)
        textField.addRightConstraint(toView: cell.contentView, relation: .Equal, constant: -15)
        textField.addBottomConstraint(toView: cell.contentView, relation: .Equal, constant: 0)
        
        self.textFields.append(textField)
        
        textField.text = indexPath.row == 0 ? "Alex" : "pass"
        
        if indexPath.row == 1 {
            
            textField.secureTextEntry = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return kCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        textFields[indexPath.row].becomeFirstResponder()
    }
    
}
