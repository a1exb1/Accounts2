//
//  TransactionsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyJSON

private let kPurchaseImage = AppTools.iconAssetNamed("1007-price-tag-toolbar.png")
private let kTransactionImage = AppTools.iconAssetNamed("922-suitcase-toolbar.png")
private let kPopoverContentSize = CGSize(width: 390, height: 440)

class TransactionsViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    var friend = User()
    var transactions:Array<Transaction> = []
    var noDataView: UILabel?
    var addBarButtonItem: UIBarButtonItem?
    
    var loadMoreView = UIView()
    var loadMoreViewHeightConstraint: NSLayoutConstraint?
    var hasLoadedFirstTime = false
    var loadMoreRequest: JsonRequest?
    var isLoadingMore = false
    var canLoadMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            tableView = UITableView(frame: CGRectZero, style: .Grouped)
        }
        
        setupTableView(tableView, delegate: self, dataSource: self)
        title = "Transactions with \(friend.Username)"
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        gradient = setBackgroundGradient()
        setTableViewAppearanceForBackgroundGradient(tableView)
        
        setupLoadMoreView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(nil)
    }
    
    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        setupTableViewRefreshControl(tableView)
    }
    
    func showOrHideNoDataView() {
        
        if noDataView == nil {
            
            noDataView = UILabel()
            noDataView?.text = "Nothing to see here!"
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
            
            self.noDataView?.layer.opacity = self.transactions.count > 0 ? 0 : 1
            self.tableView.layer.opacity = self.transactions.count > 0 ? 1 : 0
        })
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        view.showLoader()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.tableView.layer.opacity = 0
            self.noDataView?.layer.opacity = 0
        })
        
        refreshRequest?.cancel()
        refreshRequest = kActiveUser.getTransactionsBetweenFriend(friend, skip: 0, completion: { (transactions) -> () in
            
            self.transactions = transactions
            self.hasLoadedFirstTime = true
            
        }).onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
            self.view.hideLoader()
            self.showOrHideNoDataView()
            
            //just in case
            self.loadMoreView.hideLoader()
        })
    }
    
    func animateTableFooterViewHeight(height: Int, completion: (() -> ())?) {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.loadMoreView.frame = CGRect(x: 0, y: 0, width: 0, height: height)
            self.tableView.tableFooterView = self.loadMoreView
            
        }) { (sucess) -> Void in
            
            
            completion?()
        }
    }
    
    func loadMore() {
        
        if !isLoadingMore && canLoadMore {
            
            isLoadingMore = true
            canLoadMore = false
            
            animateTableFooterViewHeight(50, completion: nil)
            
            loadMoreView.showLoader()
            
            loadMoreRequest = kActiveUser.getTransactionsBetweenFriend(friend, skip: transactions.count, completion: { (transactions) -> () in
                
                for transaction in transactions {
                    
                    self.transactions.append(transaction)
                }
                
            }).onDownloadFinished({ () -> () in
                
                self.tableView.reloadData()
                self.isLoadingMore = false
                self.loadMoreView.hideLoader()
                
                NSTimer.schedule(delay: 0.2, handler: { timer in
                    
                    self.animateTableFooterViewHeight(0, completion: { () -> () in
                    })
                })
            })
        }
    }
    
    func add() {
        
        let view = SelectPurchaseOrTransactionViewController()
        view.contextualFriend = friend
        let v = UINavigationController(rootViewController: view)
        
        v.modalPresentationStyle = .Popover
        v.preferredContentSize = kPopoverContentSize
        v.popoverPresentationController?.barButtonItem = addBarButtonItem
        v.popoverPresentationController?.delegate = self
        
        presentViewController(v, animated: true, completion: nil)
    }
    
    override func setupTableViewConstraints(tableView: UITableView) {
        
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        tableView.addLeftConstraint(toView: view, attribute: NSLayoutAttribute.Left, relation: NSLayoutRelation.GreaterThanOrEqual, constant: -0)
        tableView.addRightConstraint(toView: view, attribute: NSLayoutAttribute.Right, relation: NSLayoutRelation.GreaterThanOrEqual, constant: -0)
        
        tableView.addWidthConstraint(relation: NSLayoutRelation.LessThanOrEqual, constant: kTableViewMaxWidth)
        
        tableView.addTopConstraint(toView: view, relation: .Equal, constant: 0)
        tableView.addBottomConstraint(toView: view, relation: .Equal, constant: 0)
        
        tableView.addCenterXConstraint(toView: view)
    }
    
    func setupLoadMoreView() {
        
        loadMoreView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        tableView.tableFooterView = loadMoreView
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        loadMoreRequest?.cancel()
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
        
        setTableViewCellAppearanceForBackgroundGradient(cell)
        
        let transaction = transactions[indexPath.row]
        
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
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if transaction.purchase.PurchaseID > 0 {
            
            let v = SavePurchaseViewController()
            v.purchase = transaction.purchase
            
            openView(v, sourceView: cell.contentView)
        }
        else {
            
            let v = SaveTransactionViewController()
            v.transaction = transaction
            
            openView(v, sourceView: cell.contentView)
        }
    }
    
    func openView(view: UIViewController, sourceView: UIView?) {
        
        let v = UINavigationController(rootViewController: view)
        
        v.modalPresentationStyle = .Popover
        v.preferredContentSize = kPopoverContentSize
        v.popoverPresentationController?.sourceRect = sourceView!.bounds
        v.popoverPresentationController?.sourceView = sourceView
        v.popoverPresentationController?.delegate = self
        
        presentViewController(v, animated: true, completion: nil)
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

extension TransactionsViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        
        deselectSelectedCell(tableView)
        refresh(nil)
    }
}

extension TransactionsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        //NSInteger result = maximumOffset - currentOffset;
        
        //if not at top
        let isAboveTop = scrollView.contentOffset.y + 64 <= 0
        println(scrollView.contentOffset.y + 64)
        println(isAboveTop)
        //
        
        // Change 10.0 to adjust the distance from bottom
        if (maximumOffset - currentOffset <= 00.0 && !isAboveTop) {
            
            if hasLoadedFirstTime { loadMore() }
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.canLoadMore = true // necessary?
    }
}