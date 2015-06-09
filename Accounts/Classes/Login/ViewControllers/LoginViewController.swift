//
//  LoginViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class LoginViewController: FormViewController {

    var user = User()
    
    override func viewDidLoad() {
        formViewDelegate = self
        
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "login")
    }
    
    func login() {
        
        User.login(user.Username, password: user.Password).onContextSuccess { () -> () in
            
            var v = UIStoryboard.initialViewControllerFromStoryboardNamed("Main")
            self.presentViewController(v, animated: true, completion: nil)
            
        }.onContextFailure { () -> () in
            
            UIAlertView(title: "Login failed!", message: "Incorrect username or password!", delegate: nil, cancelButtonTitle: "OK").show()
        }
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