//
//  PaymentViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 16/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController {
    
    var paymentAmountTextField = UITextField()
    var transaction = Transaction()
    
    var keyboardToolbar = UIToolbar()
    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.tableView.registerClass(TextFieldWithLabelTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.showOrHideSaveButton(transaction.Amount > 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.paymentAmountTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsetsZero)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupKeyboardToolbar() {
        
        self.keyboardToolbar.items = [
            UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clear")
        ]
        
        self.paymentAmountTextField.inputAccessoryView = self.keyboardToolbar
        self.keyboardToolbar.sizeToFit()
    }
    
    func clear() {
        
        self.paymentAmountTextField.text = ""
    }
    
    func save() {
        
        self.transaction.Amount = (self.paymentAmountTextField.text as NSString).doubleValue
        
        Session.sharedInstance().activeUser.addTransaction(self.transaction).onDownloadSuccess { (json, request) -> () in
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func showOrHideSaveButton(show: Bool) {
        
        if show {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        self.showOrHideSaveButton(textField.text.charCount() > 0)
    }
    
}

extension TransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TextFieldWithLabelTableViewCell
        
        cell.label.text = "Pay: (£) "
        cell.textField.keyboardType = UIKeyboardType.DecimalPad
        cell.textField.textAlignment = NSTextAlignment.Right
        cell.textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.paymentAmountTextField = cell.textField
        
        self.setupKeyboardToolbar()
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
}

