//
//  TransactionsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class TransactionsViewController: BaseViewController {

    var tableView = UITableView()
    var friend = User()
    var transactions:Array<Transaction> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        title = "Transactions with \(friend.Username)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(nil)
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getTransactionsBetweenFriend(friend, completion: { (transactions) -> () in
            
            self.transactions = transactions
            
        }).onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }).onDownloadFailure({ (error, alert) -> () in
            
            alert.show()
        })
    }
}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let transaction = transactions[indexPath.row]
        
        var amount = transaction.Amount
        
        if transaction.purchase.PurchaseID > 0 {

            let dateString:String = transaction.purchase.DatePurchased.toString(DateFormat.Date.rawValue)
            cell.detailTextLabel?.text = transaction.purchase.Description
        }
        else {
            
            let dateString:String = transaction.TransactionDate.toString(DateFormat.Date.rawValue)
            cell.detailTextLabel?.text = transaction.Description
        }
        
        if transaction.user.UserID == kActiveUser.UserID {

            //moneyIsOwedToActiveUser
            amount = -amount
            cell.textLabel?.textColor = UIColor(hex: "B0321E")
        }
        else {
            
            //activeUserOwes
            cell.textLabel?.textColor = UIColor(hex: "53B01E")
        }
        
        cell.textLabel?.text = "£\(amount.toStringWithDecimalPlaces(2))"
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let transaction = transactions[indexPath.row]
        
        if transaction.purchase.PurchaseID > 0 {
            
            let v = SavePurchaseViewController()
            v.purchase = transaction.purchase
            navigationController?.pushViewController(v, animated: true)
        }
        
        else {
            
            let v = SaveTransactionViewController()
            v.transaction = transaction
            navigationController?.pushViewController(v, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        let transaction = transactions[indexPath.row]
        
        if canDeleteTransactionAtIndexPath(indexPath) {
         
            return UITableViewCellEditingStyle.Delete
        }
        
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let transaction = transactions[indexPath.row]
        
        if editingStyle == .Delete {
            
            if canDeleteTransactionAtIndexPath(indexPath) {
                
                transaction.webApiDelete()?.onDownloadFinished({ () -> () in
                    
                    self.refresh(nil)
                })
            }
        }
    }
    
    func canDeleteTransactionAtIndexPath(indexPath:NSIndexPath) -> Bool {
        
        let transaction = transactions[indexPath.row]
        
        if transaction.user.UserID == kActiveUser.UserID && transaction.purchase.PurchaseID == 0 {
            
            return true
        }
        
        return false
    }
}