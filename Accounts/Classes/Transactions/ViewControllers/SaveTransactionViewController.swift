//
//  SaveTransactionViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit
import SwiftyUserDefaults

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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "pop")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInsidePopover() {
            
//            navigationController?.view.backgroundColor = UIColor.clearColor()
//            view.backgroundColor = UIColor.clearColor()
//            tableView.backgroundColor = UIColor.clearColor()
        }
    }
    
    func save() {

        transaction.save()?.onContextSuccess({ () -> () in

            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(self.navigationController!.popoverPresentationController!)

        }).onContextFailure({ () -> () in
            
            UIAlertView(title: "Error", message: "Transaction not saved!", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func pop() {
        
        if transaction.TransactionID == 0 {
            
            UIAlertController.showAlertControllerWithButtonTitle("Go back", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Going back will delete this transaction! Are you sure?") { (response) -> () in
                
                if response == AlertResponse.Confirm {
                    
                    self.dismissViewControllerFromCurrentContextAnimated(true)
                }
            }
        }
        else {
            
            self.dismissViewControllerFromCurrentContextAnimated(true)
        }
        
        navigationController?.popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(navigationController!.popoverPresentationController!)
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
        
        let locale = Settings.getCurrencyLocaleWithIdentifier().locale
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Description", value: transaction.Description, identifier: "Description"),
            FormViewConfiguration.textFieldCurrency("Amount", value: Formatter.formatCurrencyAsString(transaction.localeAmount), identifier: "Amount", locale: locale)
        ])
        
        sections.append([
            FormViewConfiguration.normalCell("User"),
            FormViewConfiguration.normalCell("Friend"),
            FormViewConfiguration.datePicker("Transaction date", date: transaction.TransactionDate, identifier: "TransactionDate", format: nil)
        ])
        
        if transaction.TransactionID > 0 {
            
            sections.append([
                FormViewConfiguration.button("Delete", buttonTextColor: kFormDeleteButtonTextColor, identifier: "Delete")
            ])
        }
        
        return sections
    }
    
    func formViewManuallySetCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, identifier: String) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        })
        
        if identifier == "Friend" {
            
            cell.textLabel?.text = "Transfer to"
            cell.detailTextLabel?.text = "\(transaction.friend.Username)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        if identifier == "User" {
            
            cell.textLabel?.text = "Transfer from"
            cell.detailTextLabel?.text = "\(transaction.user.Username)"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func formViewDateChanged(identifier: String, date: NSDate) {
        
        if identifier == "TransactionDate" {
            
            transaction.TransactionDate = date
        }
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
                        
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        self.navigationController?.popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(self.navigationController!.popoverPresentationController!)
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
        
        return allowEditing
    }
    
    func formViewElementDidChange(identifier: String, value: AnyObject?) {
        
        showOrHideSaveButton()
    }
}

extension SaveTransactionViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if let c = cell as? FormViewTextFieldCell {
            
            c.label.textColor = UIColor.blackColor()
            c.textField.textColor = UIColor.lightGrayColor()
        }
        
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