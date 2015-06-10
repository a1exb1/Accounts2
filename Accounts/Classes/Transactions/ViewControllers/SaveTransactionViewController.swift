//
//  SaveTransactionViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SaveTransactionViewController: ACFormViewController {

    var transaction = Transaction()
    var allowEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if transaction.TransactionID == 0 {

            transaction.user = kActiveUser
        }

        allowEditing = true // transaction.TransactionID == 0 || transaction.user.UserID == kActiveUser.UserID
        
        if allowEditing && transaction.TransactionID == 0 {
            
            title = "New transaction"
            transaction.user = kActiveUser
        }
        else if allowEditing && transaction.TransactionID > 0 {
            
            title = "Edit transaction"
        }
        else {
            
            title = "Transaction"
        }
        
        showOrHideSaveButton()
    }
    
    func save() {

        transaction.save()?.onContextSuccess({ () -> () in

            self.dismissViewControllerFromCurrentContextAnimated(true)

        }).onContextFailure({ () -> () in
            
            UIAlertView(title: "Error", message: "Transaction not saved!", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    override func close (){
        
        if transaction.TransactionID == 0 {
            
            UIAlertController.showAlertControllerWithButtonTitle("Close", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Closing will not save this transaction") { (response) -> () in
                
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
        
        navigationItem.rightBarButtonItem?.enabled = allowEditing && transaction.modelIsValid()
    }
}

extension SaveTransactionViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Description", value: transaction.Description, identifier: "Description"),
            FormViewConfiguration.textFieldCurrency("Amount", value: Formatter.formatCurrencyAsString(transaction.localeAmount), identifier: "Amount")
        ])
        
        sections.append([
            FormViewConfiguration.normalCell("User"),
            FormViewConfiguration.normalCell("Friend"),
            FormViewConfiguration.textField("Transaction date", value: transaction.TransactionDate.toString(DateFormat.DateTime.rawValue), identifier: "TransactionDate")
        ])
        
        if transaction.TransactionID > 0 {
            
            sections.append([
                FormViewConfiguration.button("Delete", buttonTextColor: UIColor.redColor(), identifier: "Delete")
            ])
        }
        
        return sections
    }
    
    func formViewManuallySetCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, identifier: String) -> UITableViewCell {
        
        if identifier == "Friend" {
            
            let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = "Transfer to"
            cell.detailTextLabel?.text = "\(transaction.friend.Username)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        if identifier == "User" {
            
            let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = "Transfer from"
            cell.detailTextLabel?.text = "\(transaction.user.Username)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func formViewTextFieldEditingChanged(identifier: String, text: String) {
        
        if identifier == "Description" {

            transaction.Description = text
        }
    }
    
    func formViewTextFieldCurrencyEditingChanged(identifier: String, value: Double) {
        
        if identifier == "Amount" {

            transaction.localeAmount = value
        }
    }
    
    func formViewButtonTapped(identifier: String) {
        
        if identifier == "Delete" {

            UIAlertController.showAlertControllerWithButtonTitle("Delete?", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Delete transaction for \(Formatter.formatCurrencyAsString(transaction.localeAmount))?", completion: { (response) -> () in
                
                if response == AlertResponse.Confirm {
                    
                    self.transaction.webApiDelete()?.onDownloadFinished({ () -> () in
                        
                        navigationController?.popViewControllerAnimated(true)
                    })
                }
            })
        }
    }
    
    func formViewDidSelectRow(identifier: String) {
        
        if identifier == "Friend" {

            let usersToChooseFrom = User.userListExcludingID(transaction.user.UserID)
            
            let v = SelectUsersViewController(identifier: identifier, user: transaction.friend, selectUserDelegate: self, allowEditing: allowEditing, usersToChooseFrom: usersToChooseFrom)
            navigationController?.pushViewController(v, animated: true)
        }
        
        if identifier == "User" {
            
            let usersToChooseFrom = User.userListExcludingID(nil)
            
            let v = SelectUsersViewController(identifier: identifier, user: transaction.user, selectUserDelegate: self, allowEditing: allowEditing, usersToChooseFrom: usersToChooseFrom)
            navigationController?.pushViewController(v, animated: true)
        }
    }
    
    override func formViewElementIsEditable(identifier: String) -> Bool {
        
        if identifier == "TransactionDate" {
            
            return false
        }
        
        return allowEditing
    }
    
    func formViewElementDidChange(identifier: String, value: AnyObject?) {
        
        showOrHideSaveButton()
    }
}

extension SaveTransactionViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        setupTableViewCellAppearance(cell)
        
        return cell
    }
}

extension SaveTransactionViewController: SelectUserDelegate {
    
    func didSelectUser(user: User, identifier: String) {
        
        if identifier == "Friend" {
            
            transaction.friend = user
        }
        if identifier == "User" {
        
            transaction.user = user
            transaction.friend = User()
        }
        
        showOrHideSaveButton()
        reloadForm()
    }
}