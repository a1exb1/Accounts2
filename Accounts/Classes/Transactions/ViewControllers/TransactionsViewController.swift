//
//  TransactionsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

private let kPurchaseImage = AppTools.iconAssetNamed("1007-price-tag-toolbar.png")
private let kTransactionImage = AppTools.iconAssetNamed("922-suitcase-toolbar.png")

class TransactionsViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    var friend = User()
    var transactions:Array<Transaction> = []
    var noDataView: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        title = "Transactions with \(friend.Username)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        
        view.showLoader()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh(nil)
    }
    
    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        setupTableViewRefreshControl(tableView)
    }
    
    func showOrHideNoDataView() {
        
        if noDataView == nil {
            
            noDataView = UILabel()
            noDataView!.text = "Nothing to see here!"
            noDataView?.font = UIFont.systemFontOfSize(40)
            noDataView?.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            noDataView?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            noDataView?.numberOfLines = 0
            noDataView?.textAlignment = NSTextAlignment.Center
            
            noDataView?.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.addSubview(noDataView!)
            noDataView?.fillSuperView(UIEdgeInsets(top: 40, left: 40, bottom: -40, right: -40))
            noDataView?.layer.opacity = 0
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.noDataView?.layer.opacity = transactions.count > 0 ? 0 : 1
        })
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getTransactionsBetweenFriend(friend, completion: { (transactions) -> () in
            
            self.transactions = transactions
            
        }).onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.view.hideLoader()
            self.showOrHideNoDataView()
            
        }).onDownloadFailure({ (error, alert) -> () in
            
            alert.show()
            
        }).onDownloadSuccess { (json, request) -> () in
            
            request.alamofireRequest?.responseString(encoding: nil, completionHandler: { (request, response, str, error) -> Void in
                
                let contentLength: AnyObject = response!.allHeaderFields["Content-Length"]!
                var length: CGFloat = CGFloat("\(contentLength)".toInt()!) / 1024
                let l = NSString(format: "%.02f", length)
                println("Content-Length: \(l)kb")
            })
        }
    }
    
    func add() {
        
        var alert = UIAlertController(title: "Add new", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let purchaseAction = UIAlertAction(title: "Purchase", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let v = SavePurchaseViewController()
            v.addCloseButton()
            v.purchase.friends.append(self.friend)
            self.presentViewController(UINavigationController(rootViewController: v), animated: true, completion: nil)
        }
        
        let transactionAction = UIAlertAction(title: "Transaction", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let v = SaveTransactionViewController()
            v.addCloseButton()
            v.transaction.friend = self.friend
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

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        })
        
        let transaction = transactions[indexPath.row]
        
        setupTableViewCellAppearance(cell)
        
        var amount = transaction.localeAmount
        
        if transaction.purchase.PurchaseID > 0 {

            amount = transaction.purchase.localeAmount
            
            let dateString:String = transaction.purchase.DatePurchased.toString(DateFormat.Date.rawValue)
            cell.textLabel?.text = "\(transaction.purchase.Description)"
            
            if transaction.purchase.user.UserID == kActiveUser.UserID {
                
                //moneyIsOwedToActiveUser
                amount = -amount
                cell.detailTextLabel?.textColor = AccountColor.negativeColor()
            }
            else {
                
                //activeUserOwes
                cell.detailTextLabel?.textColor = AccountColor.positiveColor()
            }
        
            cell.imageView?.image = kPurchaseImage
        }
        else {
            
            let dateString:String = transaction.TransactionDate.toString(DateFormat.Date.rawValue)
            cell.textLabel?.text = "\(transaction.Description)"
            
            if transaction.user.UserID == kActiveUser.UserID {
                
                //moneyIsOwedToActiveUser
                amount = -amount
                cell.detailTextLabel?.textColor = AccountColor.negativeColor()
            }
            else {
                
                //activeUserOwes
                cell.detailTextLabel?.textColor = AccountColor.positiveColor()
            }
            
            cell.imageView?.image = kTransactionImage
        }
        
        cell.detailTextLabel?.text = Formatter.formatCurrencyAsString(amount)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.imageView?.tintWithColor(UIColor.whiteColor())
        
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