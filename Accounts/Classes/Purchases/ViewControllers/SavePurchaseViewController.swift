//
//  SavePurchaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SavePurchaseViewController: FormViewController {

    var purchase = Purchase()
    var allowEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        allowEditing = purchase.user.UserID == kActiveUser.UserID || purchase.PurchaseID == 0

        if allowEditing && purchase.PurchaseID == 0 {

            title = "New purchase"
        }
        else if allowEditing && purchase.PurchaseID > 0 {

            title = "Edit purchase"
        }
        else {
            
            title = "Purchase"
        }
    }
    
    func save() {

        purchase.save()?.onContextSuccess({ () -> () in

            self.dismissViewControllerFromCurrentContextAnimated(true)

        }).onContextFailure({ () -> () in

            UIAlertView(title: "Error", message: "Purchase not saved!", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func showOrHideSaveButton() {
        
        if allowEditing && purchase.modelIsValid() {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}

extension SavePurchaseViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Description", value: purchase.Description, identifier: "Description"),
            FormViewConfiguration.textFieldCurrency("Amount", value: "£\(purchase.Amount.toStringWithDecimalPlaces(2))", identifier: "Amount"),
            FormViewConfiguration.normalCell("Friends")
            ])
        
        if purchase.PurchaseID > 0 && purchase.user.UserID == kActiveUser.UserID {
         
            sections.append([
                FormViewConfiguration.button("Delete", buttonTextColor: UIColor.redColor(), identifier: "Delete")
            ])
        }
        
        return sections
    }
    
    func formViewTextFieldEditingChanged(identifier: String, text: String) {
        
        if identifier == "Description" {
            
            purchase.Description = text
        }
    }
    
    func formViewTextFieldCurrencyEditingChanged(identifier: String, value: Double) {
        
        if identifier == "Amount" {
            
            purchase.Amount = value
        }
    }
    
    func formViewButtonTapped(identifier: String) {
        
        
    }
    
    func formViewDidSelectRow(identifier: String) {
        
        if identifier == "Friends" {
            
            let v = SelectFriendsViewController()
            v.selectMultipleFriendsDelegate = self
            v.setSelectedFriends(purchase.friends)
            v.allowEditing = allowEditing
            v.allowMultipleSelection = true
            navigationController?.pushViewController(v, animated: true)
        }
    }
    
    func formViewDateChanged(identifier: String, date: NSDate) {
        
        if identifier == "Delete" {
            
            purchase.webApiDelete()?.onDownloadFinished({ () -> () in
                
                navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func formViewManuallySetCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, identifier: String) -> UITableViewCell {
        
        if identifier == "Friends" {

            let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")

            cell.textLabel?.text = "Split between:"
            cell.detailTextLabel?.text = "\(purchase.friends.count)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func formViewElementIsEditable(identifier: String) -> Bool {
        
        return allowEditing
    }
    
    func formViewElementDidChange(identifier: String, value: AnyObject?) {
        
        showOrHideSaveButton()
    }
}

extension SavePurchaseViewController: SelectFriendsDelegate {

    func didSelectFriends(friends: Array<User>) {

        purchase.friends = friends
        showOrHideSaveButton()
        reloadForm()
    }
}