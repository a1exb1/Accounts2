//
//  SaveTransactionViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class SaveTransactionViewController: FormViewController {

    var transaction = Transaction()
    var allowEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if transaction.TransactionID == 0 {

            transaction.user = kActiveUser
        }

        allowEditing = transaction.TransactionID == 0 || transaction.user.UserID == kActiveUser.UserID
        
        if allowEditing && transaction.TransactionID == 0 {
            
            title = "New transaction"
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
    
    func showOrHideSaveButton() {
        
        if allowEditing && transaction.modelIsValid() {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}

extension SaveTransactionViewController: FormViewDelegate {
    
    override func formViewElements() -> Array<Array<FormViewConfiguration>> {
        
        var sections = Array<Array<FormViewConfiguration>>()
        sections.append([
            FormViewConfiguration.textField("Description", value: transaction.Description, identifier: "Description"),
            FormViewConfiguration.textFieldCurrency("Amount", value: "£\(transaction.Amount.toStringWithDecimalPlaces(2))", identifier: "Amount"),
            FormViewConfiguration.normalCell("Friend")
        ])
        
        if transaction.TransactionID > 0 && transaction.user.UserID == kActiveUser.UserID {
            
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
            
            cell.textLabel?.text = "Transfer to:"
            cell.detailTextLabel?.text = "\(transaction.friend.Username)"
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

            transaction.Amount = value
        }
    }
    
    func formViewButtonTapped(identifier: String) {
        
        if identifier == "Delete" {

            transaction.webApiDelete()?.onDownloadFinished({ () -> () in

                navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func formViewDidSelectRow(identifier: String) {
        
        if identifier == "Friend" {

            let v = SelectFriendsViewController()
            v.selectFriendDelegate = self
            v.setSelectedFriend(transaction.friend)
            v.allowEditing = allowEditing
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

extension SaveTransactionViewController: SelectFriendDelegate {
    
    func didSelectFriend(friend: User) {
        
        transaction.friend = friend
        showOrHideSaveButton()
        reloadForm()
    }
}