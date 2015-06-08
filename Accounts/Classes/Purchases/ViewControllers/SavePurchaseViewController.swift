//
//  SavePurchaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SavePurchaseViewController: BaseViewController {

    var tableView = UITableView()
    var purchase = Purchase()
    var data = []
    var textFields = Array<UITextField>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
    }

    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(FormViewTableViewCell.self, forCellReuseIdentifier: "FormCell")
    }
    
    func save() {
        
        
        
        purchase.save()?.onContextSuccess({ () -> () in
            
            navigationController?.popViewControllerAnimated(true)
            
        }).onContextFailure({ () -> () in
            
            UIAlertView(title: "Error", message: "Purchase not saved!", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        if textField == textFields[0] {
            
            purchase.Amount = (textField.text as NSString).doubleValue
        }
    }
}

extension SavePurchaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FormCell") as! FormViewTableViewCell
            
            cell.label.text = "Amount"
            cell.textField.text = "\(purchase.Amount)"
            cell.textField.keyboardType = UIKeyboardType.DecimalPad
            cell.textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.AllEvents)
            textFields.append(cell.textField)
            
            return cell
        }
        
        let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = "Split between:"
        cell.detailTextLabel?.text = "\(purchase.friends.count)"
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            
            let v = SelectFriendsViewController()
            v.delegate = self
            v.setSelectedFriends(purchase.friends)
            navigationController?.pushViewController(v, animated: true)
        }
    }
}

extension SavePurchaseViewController: SelectFriendsDelegate {
    
    func didSelectFriends(friends: Array<User>) {
        
        purchase.friends = friends
        tableView.reloadData()
    }
}