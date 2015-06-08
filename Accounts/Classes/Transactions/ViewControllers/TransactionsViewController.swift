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
        
        let amount = String(format: "%.2f", transaction.Amount)
        cell.textLabel?.text = "£\(amount)"
        cell.textLabel?.textColor = friend.DifferenceBetweenActiveUser > 0 ? UIColor(hex: "53B01E") : UIColor(hex: "B0321E")
        
        if transaction.purchase.PurchaseID > 0 {
         
            cell.detailTextLabel?.text = "Purchase by \(transaction.user.Username) (£\(transaction.purchase.Amount))"
        }
        else {
            
            cell.detailTextLabel?.text = "Transfer"
        }
        
        
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
}