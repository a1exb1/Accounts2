//
//  SavePurchaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SavePurchaseViewController: ACFormViewController {

    var purchase = Purchase()
    var allowEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        allowEditing = true //purchase.user.UserID == kActiveUser.UserID || purchase.PurchaseID == 0

        if allowEditing && purchase.PurchaseID == 0 {

            title = "New purchase"
            purchase.user = kActiveUser
        }
        else if allowEditing && purchase.PurchaseID > 0 {

            title = "Edit purchase"
        }
        else {
            
            title = "Purchase"
        }
        
        showOrHideSaveButton()
    }
    
    func save() {

        purchase.save()?.onContextSuccess({ () -> () in

            self.dismissViewControllerFromCurrentContextAnimated(true)

        }).onContextFailure({ () -> () in

            UIAlertView(title: "Error", message: "Purchase not saved!", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    override func close (){
    
        if purchase.PurchaseID == 0 {
            
            UIAlertController.showAlertControllerWithButtonTitle("Close", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Closing will not save this purchase") { (response) -> () in
                
                super.close()
            }
        }
        else {
            
            super.close()
        }
    }
    
    func showOrHideSaveButton() {
        
        if allowEditing {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
            navigationItem.rightBarButtonItem?.tintColor = kNavigationBarPositiveActionColor
        }
        
        navigationItem.rightBarButtonItem?.enabled = allowEditing && purchase.modelIsValid()
    }
}

extension SavePurchaseViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Description", value: purchase.Description, identifier: "Description"),
            FormViewConfiguration.textFieldCurrency("Amount", value: Formatter.formatCurrencyAsString(purchase.Amount), identifier: "Amount"),
        ])
        sections.append([
            FormViewConfiguration.normalCell("User"),
            FormViewConfiguration.normalCell("Friends"),
            FormViewConfiguration.textField("Date Purchased", value: purchase.DatePurchased.toString(DateFormat.DateTime.rawValue), identifier: "DatePurchased")
        ])
        
        if purchase.PurchaseID > 0 {
         
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
        
        if identifier == "Delete" {
            
            UIAlertController.showAlertControllerWithButtonTitle("Delete?", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Delete purchase: \(purchase.Description) for \(Formatter.formatCurrencyAsString(purchase.Amount))?", completion: { (response) -> () in
                
                if response == AlertResponse.Confirm {
                    
                    self.purchase.webApiDelete()?.onDownloadFinished({ () -> () in
                        
                        self.close()
                    })
                }
            })
        }
    }
    
    func formViewDidSelectRow(identifier: String) {
        
        if identifier == "Friends" {
            
            let usersToChooseFrom = User.userListExcludingID(purchase.user.UserID)
            
            let v = SelectUsersViewController(identifier: identifier, users: purchase.friends, selectUsersDelegate: self, allowEditing: allowEditing, usersToChooseFrom: usersToChooseFrom)
            navigationController?.pushViewController(v, animated: true)
        }
        
        if identifier == "User" {
            
            let usersToChooseFrom = User.userListExcludingID(nil)
            
            let v = SelectUsersViewController(identifier: identifier, user: purchase.user, selectUserDelegate: self, allowEditing: allowEditing, usersToChooseFrom: usersToChooseFrom)
            navigationController?.pushViewController(v, animated: true)
        }
    }
    
    func formViewDateChanged(identifier: String, date: NSDate) {
        
        
    }
    
    func formViewManuallySetCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, identifier: String) -> UITableViewCell {
        
        if identifier == "Friends" {

            let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")

            cell.textLabel?.text = "Split between"
            
            var friendCount = purchase.friends.count
            
            for friend in purchase.friends {
                
                if friend.UserID == purchase.user.UserID {
                    
                    friendCount--
                }
            }
            
            cell.detailTextLabel?.text = "\(friendCount)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        if identifier == "User" {
            
            let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = "Purchase by "
            cell.detailTextLabel?.text = "\(purchase.user.Username)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func formViewElementIsEditable(identifier: String) -> Bool {
        
        if identifier == "DatePurchased" {
            
            return false
        }
        
        return allowEditing
    }
    
    func formViewElementDidChange(identifier: String, value: AnyObject?) {
        
        showOrHideSaveButton()
    }
}

extension SavePurchaseViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        setupTableViewCellAppearance(cell)
        
        return cell
    }
}

extension SavePurchaseViewController: SelectUsersDelegate {

    func didSelectUsers(users: Array<User>, identifier: String) {

        if identifier == "Friends" {
            
            purchase.friends = users
        }

        showOrHideSaveButton()
        reloadForm()
    }
}

extension SavePurchaseViewController: SelectUserDelegate {
    
    func didSelectUser(user: User, identifier: String) {
        
        if identifier == "User" {
            
            purchase.user = user
            purchase.friends = []
        }
        
        showOrHideSaveButton()
        reloadForm()
    }
}