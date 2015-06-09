//
//  FriendsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class FriendsViewController: BaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "openMenu")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        title = "Friends"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(nil)
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {

        kActiveUser.getFriends().onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }).onDownloadFailure({ (error, alert) -> () in
            
            alert.show()
        })
    }
    
    func openMenu() {
        
        presentViewController(UINavigationController(rootViewController:MenuViewController()), animated: true, completion: nil)
    }
    
    func add() {
        
        var alert = UIAlertController(title: "Add new", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let v = SavePurchaseViewController()
            v.addCloseButton()
            self.presentViewController(UINavigationController(rootViewController: v), animated: true, completion: nil)
        }
        
        let transactionAction = UIAlertAction(title: "Transaction", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let v = SaveTransactionViewController()
            v.addCloseButton()
            self.presentViewController(UINavigationController(rootViewController: v), animated: true, completion: nil)
        }
        
        let closeAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(purchaseAction)
        alert.addAction(transactionAction)
        alert.addAction(closeAction)
        alert.show()
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return kActiveUser.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        let cell = dequeuedCell != nil ? dequeuedCell! : UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        let friend = kActiveUser.friends[indexPath.row]
        
        cell.textLabel?.text = friend.Username
        let amount = abs(friend.DifferenceBetweenActiveUser).toStringWithDecimalPlaces(2)
        let readableText = friend.DifferenceBetweenActiveUser < 0 ? "You owe" : "Owes you"
        
        cell.detailTextLabel?.text = "\(readableText) £\(amount)"
        cell.detailTextLabel?.textColor = friend.DifferenceBetweenActiveUser < 0 ? UIColor(hex: "B0321E") : UIColor(hex: "53B01E")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let friend = kActiveUser.friends[indexPath.row]
        
        var v = TransactionsViewController()
        v.friend = friend
        navigationController?.pushViewController(v, animated: true)
    }
}