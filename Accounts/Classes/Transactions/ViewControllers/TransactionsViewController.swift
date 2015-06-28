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
private let kLoaderTableFooterViewHeight = 70
private let kAnimationDuration:NSTimeInterval = 0.5

protocol SaveItemDelegate {
    
    func itemDidGetDeleted()
    func itemDidChange()
    func purchaseDidChange(purchase: Purchase)
    func transactionDidChange(transaction: Transaction)
}

class TransactionsViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    var friend = User()
    var transactions:Array<Transaction> = []
    var noDataView = UILabel()
    var addBarButtonItem: UIBarButtonItem?
    
    var loadMoreView = UIView()
    var loadMoreViewHeightConstraint: NSLayoutConstraint?
    var hasLoadedFirstTime = false
    var loadMoreRequest: JsonRequest?
    var isLoadingMore = false
    var canLoadMore = true
    
    var selectedRow: NSIndexPath?
    
    var selectedPurchaseID: Int?
    var selectedTransactionID: Int?
    var didJustDelete: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if kDevice == .Pad {
        
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        setupTableView(tableView, delegate: self, dataSource: self)
        title = "Transactions with \(friend.Username)"
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        navigationItem.rightBarButtonItem = addBarButtonItem

        setupLoadMoreView()
        setupNoDataLabel(noDataView, text: "Tap plus to add a purchase or transfer")
        
        executeActualRefreshByHiding(true, refreshControl: nil, take: nil, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedPurchaseID == nil && selectedTransactionID == nil && !didJustDelete {
            
            findAndScrollToCalculatedSelectedCellAtIndexPath()
        }
        
        getDifference(nil)
    }
    
    func getDifference(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getDifferenceBetweenFriend(friend, completion: { (difference, count) -> () in
         
            let previousDifference = self.friend.DifferenceBetweenActiveUser
            self.friend.DifferenceBetweenActiveUser = difference
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            if previousDifference != difference {
                
                self.executeActualRefreshByHiding(true, refreshControl: nil, take: nil, completion: nil)
            }
            else {
                
                refreshControl?.endRefreshing()
            }
        })
    }
    
    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        setupTableViewRefreshControl(tableView)
    }
    
    func showOrHideTableOrNoDataView() {
        
        UIView.animateWithDuration(kAnimationDuration, animations: { () -> Void in
            
            self.noDataView.layer.opacity = self.transactions.count > 0 ? 0 : 1
            self.tableView.layer.opacity = self.transactions.count > 0 ? 1 : 1
        })
    }
    
    func executeActualRefreshByHiding(hiding: Bool, refreshControl: UIRefreshControl?, take:Int?, completion: ( ()-> ())?) {
        
        if hiding {
            
            view.showLoader()
            tableView.layer.opacity = 0
            noDataView.layer.opacity = 0
        }
        
        refreshRequest?.cancel()
        refreshRequest = kActiveUser.getTransactionsBetweenFriend(friend, skip: 0, take: take, completion: { (transactions) -> () in
            
            self.transactions = transactions
            self.hasLoadedFirstTime = true
            
        }).onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
            self.view.hideLoader()
            self.showOrHideTableOrNoDataView()
            
            //just in case
            self.loadMoreView.hideLoader()
            
            self.findAndScrollToCalculatedSelectedCellAtIndexPath()
            
            completion?()
        })

    }
    
    func findAndScrollToCalculatedSelectedCellAtIndexPath() {
        
        if !didJustDelete {
            
            var calculatedIndexPath: NSIndexPath?
            
            for transaction in transactions {
                
                let row = find(transactions, transaction)!
                
                if let purchaseID = selectedPurchaseID {
                    
                    if transaction.purchase.PurchaseID == purchaseID && purchaseID > 0 {
                        
                        calculatedIndexPath = NSIndexPath(forRow: row, inSection: 0)
                        break
                    }
                }
                else if let transactionID = selectedTransactionID {
                    
                    if transaction.TransactionID == transactionID && transactionID > 0 {
                        
                        calculatedIndexPath = NSIndexPath(forRow: row, inSection: 0)
                        break
                    }
                }
            }
            
            var rowToDeselect: NSIndexPath?
            
            if let indexPath = calculatedIndexPath {
                
                rowToDeselect = indexPath
            }
            else if selectedPurchaseID == 0 && selectedTransactionID == 0 {
                
                rowToDeselect = nil // NSIndexPath(forRow: 0, inSection: 0)
            }
            else if let indexPath = selectedRow {
                
                rowToDeselect = indexPath
            }
            
            if let indexPath = rowToDeselect {
                
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                
                NSTimer.schedule(delay: kAnimationDuration, handler: { timer in

                    var cellRect = self.tableView.rectForRowAtIndexPath(indexPath)
                    var completelyVisible = CGRectContainsRect(self.tableView.bounds, cellRect)
                    
                    if !completelyVisible {
                        
                        CATransaction.begin()
                        CATransaction.setCompletionBlock({ () -> Void in
                            
                            self.deselectSelectedCell(self.tableView)
                        })
                        
                        self.tableView.beginUpdates()
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                        self.tableView.endUpdates()
                        
                        CATransaction.commit()
                    }
                    else {
                        
                        self.deselectSelectedCell(self.tableView)
                    }
                })
            }
        }
        
        selectedTransactionID = nil
        selectedPurchaseID = nil
        selectedRow = nil
        didJustDelete = false
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        selectedTransactionID = nil
        selectedPurchaseID = nil
        selectedRow = nil
        didJustDelete = false
        
        getDifference(refreshControl)
        
        //executeActualRefreshByHiding(false, refreshControl: refreshControl, take: nil, completion: nil)
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
        
        if !isLoadingMore && canLoadMore && hasLoadedFirstTime {
            
            isLoadingMore = true
            canLoadMore = false
            
            animateTableFooterViewHeight(kLoaderTableFooterViewHeight, completion: nil)
            
            loadMoreView.showLoader()
            
            loadMoreRequest = kActiveUser.getTransactionsBetweenFriend(friend, skip: transactions.count, take: nil, completion: { (transactions) -> () in
                
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
        view.saveItemDelegate = self
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
        
        loadMoreView.frame = CGRect(x: 0, y: 0, width: 50, height: kLoaderTableFooterViewHeight)
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
        cell.imageView?.tintWithColor(AccountColor.blueColor())
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let transaction = transactions[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if transaction.purchase.PurchaseID > 0 {
            
            let v = SavePurchaseViewController()
            v.purchase = transaction.purchase
            v.delegate = self
            openView(v, sourceView: cell.contentView)
        }
        else {
            
            let v = SaveTransactionViewController()
            v.transaction = transaction
            v.delegate = self
            openView(v, sourceView: cell.contentView)
        }
        
        selectedRow = indexPath
    }
    
    func openView(view: UIViewController, sourceView: UIView?) {
        
        let v = UINavigationController(rootViewController: view)
        
        v.modalPresentationStyle = .Popover
        v.preferredContentSize = kPopoverContentSize
        v.popoverPresentationController?.sourceRect = sourceView!.bounds
        v.popoverPresentationController?.sourceView = sourceView
        v.popoverPresentationController?.delegate = self
        v.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Left
        
        presentViewController(v, animated: true, completion: nil)
    }
    
//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        
//        let transaction = transactions[indexPath.row]
//        
//        if canDeleteTransactionAtIndexPath(indexPath) {
//         
//            return UITableViewCellEditingStyle.Delete
//        }
//        
//        return UITableViewCellEditingStyle.None
//    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        let transaction = transactions[indexPath.row]
//        
//        if editingStyle == .Delete {
//            
//            if canDeleteTransactionAtIndexPath(indexPath) {
//                
//                transaction.webApiDelete()?.onDownloadFinished({ () -> () in
//                    
//                    self.refresh(nil)
//                })
//            }
//        }
//    }
    
    func canDeleteTransactionAtIndexPath(indexPath:NSIndexPath) -> Bool {
        
        let transaction = transactions[indexPath.row]
        
        if transaction.user.UserID == kActiveUser.UserID && transaction.purchase.PurchaseID == 0 {
            
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if friend.DifferenceBetweenActiveUser > 0 {
            
            return "\(friend.Username) owes you: \(Formatter.formatCurrencyAsString(abs(friend.DifferenceBetweenActiveUser)))"
        }
        else if friend.DifferenceBetweenActiveUser < 0 {
            
            return "You owe \(friend.Username): \(Formatter.formatCurrencyAsString(abs(friend.DifferenceBetweenActiveUser)))"
        }
        
        return ""
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        return CGFloat.min
//    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.min + (kDevice == .Pad ? 40 : 0)
    }
}

extension TransactionsViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        
        deselectSelectedCell(tableView)
        getDifference(nil)
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
        
        // Change 10.0 to adjust the distance from bottom
        if (maximumOffset - currentOffset <= 00.0 && !isAboveTop) {
            
            loadMore()
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.canLoadMore = true
    }
}

extension TransactionsViewController: SaveItemDelegate {
    
    func itemDidGetDeleted() {
        
//        if let indexPath = selectedRow {
//            
//            let numberOfRows = tableView.numberOfRowsInSection(indexPath.section)
//            
//            let wasLastRow = indexPath.row + 1 == numberOfRows
//            
//            tableView.beginUpdates()
//            transactions.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
//            tableView.endUpdates()
//
//            getDifference(nil)
//            
//            if wasLastRow {
//                
//                //new last row 
//                let newLastRowIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
//                tableView.reloadRowsAtIndexPaths([newLastRowIndexPath], withRowAnimation: UITableViewRowAnimation.None)
//            }
//        }
        
        didJustDelete = true
        itemDidChange()
    }
    
    func itemDidChange() {
        
        executeActualRefreshByHiding(true, refreshControl: nil, take: transactions.count, completion: nil)
    }
    
    func transactionDidChange(transaction: Transaction) {
        
        selectedPurchaseID = 0
        selectedTransactionID = transaction.TransactionID
    }
    
    func purchaseDidChange(purchase: Purchase) {
        
        selectedTransactionID = 0
        selectedPurchaseID = purchase.PurchaseID
    }
}