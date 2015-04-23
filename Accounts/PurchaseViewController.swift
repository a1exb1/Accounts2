//
//  PurchaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {

    var tableView = UITableView(frame: CGRectZero, style: .Grouped)
    var paymentAmountTextField = UITextField()
    var descriptionTextView = KMPlaceholderTextView()
    var purchase = Purchase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.paymentAmountTextField.becomeFirstResponder()
    }
    
    func setupTableView() {
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsetsZero)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(TextFieldWithLabelTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func showOrHideSaveButton() {
        
        if self.paymentAmountTextField.text.charCount() > 0 {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    func save() {
        
        self.purchase.Description = self.descriptionTextView.text
        self.purchase.Amount = (self.paymentAmountTextField.text as NSString).doubleValue
        self.purchase.splitTheBill()
        self.view.showLoader()
        
        self.purchase.save().onContextSuccess { () -> () in
            
            self.navigationController?.popViewControllerAnimated(true)
            
        }.onDownloadFinished { () -> () in
            
            self.view.hideLoader()
        }
    }
    
}

extension PurchaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TextFieldWithLabelTableViewCell
            
            cell.label.text = "Pay: (£) "
            cell.textField.keyboardType = UIKeyboardType.DecimalPad
            cell.textField.textAlignment = NSTextAlignment.Right
            cell.textField.addTarget(self, action: "showOrHideSaveButton", forControlEvents: UIControlEvents.EditingChanged)
            
            self.paymentAmountTextField = cell.textField
            
            return cell
        }
        else if indexPath.row == 1 {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "StandardCell")
            
            cell.textLabel?.text = "Friends"
            cell.detailTextLabel?.text = "\(self.purchase.friends.count)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "StandardCell")
            
            self.descriptionTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
            cell.addSubview(self.descriptionTextView)
            self.descriptionTextView.fillSuperView(UIEdgeInsets(top: 5, left: 10, bottom: -5, right: -5))
            self.descriptionTextView.placeholder = "Description"
            self.descriptionTextView.placeholderColor = UIColor.grayColor()
            self.descriptionTextView.font = self.descriptionTextView.placeholderLabel.font
        
            return cell
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            
            self.paymentAmountTextField.becomeFirstResponder()
        }
        else if indexPath.row == 1 {
            
            var v = FriendsListViewController()
            v.delegate = self
            v.selectedFriends = self.purchase.friends
            self.navigationController?.pushViewController(v, animated: true)
            
            self.paymentAmountTextField.resignFirstResponder()
        }
        else {
            
            self.descriptionTextView.becomeFirstResponder()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 2 ? 160 : 44
    }
    
}

extension PurchaseViewController: FriendsListViewControllerDelegate {
    
    func didSelectFriends(friends: [User]) {
    
        self.purchase.friends = friends
        self.tableView.reloadData()
    }
}
