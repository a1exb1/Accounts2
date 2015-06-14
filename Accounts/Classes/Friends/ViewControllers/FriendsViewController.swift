//
//  FriendsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

private let kPlusImage = AppTools.iconAssetNamed("746-plus-circle-selected.png")
private let kMinusImage = AppTools.iconAssetNamed("34-circle.minus.png")
private let kMenuIcon = AppTools.iconAssetNamed("740-gear-toolbar-selected.png")

class FriendsViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: kMenuIcon, style: .Plain, target: self, action: "openMenu")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
        title = "Friends"
        
        view.showLoader()
    }
    
    func data() -> Array<Array<User>> {
        
        var rc = Array<Array<User>>()
        
        var friendsWhoOweMoney = Array<User>()
        var friendsWhoYouOweMoney = Array<User>()
        
        //owes you money
        for friend in kActiveUser.friends {
            
            if friend.localeDifferenceBetweenActiveUser < 0 {
                
                friendsWhoOweMoney.append(friend)
            }
        }
        
        for friend in kActiveUser.friends {
            
            if friend.localeDifferenceBetweenActiveUser >= 0 {
                
                friendsWhoYouOweMoney.append(friend)
            }
        }
        
        return [friendsWhoOweMoney, friendsWhoYouOweMoney]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh(nil)
    }
    
    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        setupTableViewRefreshControl(tableView)
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {

        kActiveUser.getFriends().onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.view.hideLoader()
            
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
        
        return data().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data()[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        })
        
        let friend = data()[indexPath.section][indexPath.row]
        
        setupTableViewCellAppearance(cell)
        
        cell.textLabel?.text = friend.Username
        let amount = abs(friend.localeDifferenceBetweenActiveUser)
        
        let readableText = friend.localeDifferenceBetweenActiveUser < 0 ? "You owe" : "Owes you"
        let tintColor = friend.localeDifferenceBetweenActiveUser < 0 ? AccountColor.negativeColor() : AccountColor.positiveColor()
        
        cell.imageView?.image = friend.localeDifferenceBetweenActiveUser < 0 ? kMinusImage : kPlusImage
        cell.imageView?.tintWithColor(tintColor)
        
        cell.detailTextLabel?.text = Formatter.formatCurrencyAsString(amount)
        cell.detailTextLabel?.textColor = tintColor
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let friend = data()[indexPath.section][indexPath.row]
        
        var v = TransactionsViewController()
        v.friend = friend
        navigationController?.pushViewController(v, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if data()[section].count > 0 {
            
            if section == 0 {
                
                return "People you owe"
            }
            if section == 1 {
                
                return "People who owe you"
            }
        }
        
        return ""
    }
}