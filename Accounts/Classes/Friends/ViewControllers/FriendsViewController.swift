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
//private let kFriendInvitesIcon = AppTools.iconAssetNamed("779-users-selected.png")

private let kPopoverContentSize = CGSize(width: 320, height: 360)

class FriendsViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    
    var addBarButtonItem: UIBarButtonItem?
    var friendInvitesBarButtonItem: UIBarButtonItem?
    var openMenuBarButtonItem: UIBarButtonItem?
    
    var toolbar = UIToolbar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(tableView, delegate: self, dataSource: self)
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        addBarButtonItem?.width = 44
        
        setBarButtonItems()
        
        title = "Friends"
        view.showLoader()
        gradient = setBackgroundGradient()
        setTableViewAppearanceForBackgroundGradient(tableView)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    
    func setBarButtonItems() {
        
        friendInvitesBarButtonItem = UIBarButtonItem(title: "Invites", style: .Plain, target: self, action: "friendInvites")
        openMenuBarButtonItem = UIBarButtonItem(image: kMenuIcon, style: .Plain, target: self, action: "openMenu")
        
        
        navigationItem.leftBarButtonItems = [
            openMenuBarButtonItem!,
            editButtonItem()
        ]
        
        navigationItem.rightBarButtonItems = [
            addBarButtonItem!,
            friendInvitesBarButtonItem!
        ]
    }
    
    func friendInvites() {
        
        let view = FriendInvitesViewController()
        view.delegate = self
        let v = UINavigationController(rootViewController: view)
        
        v.modalPresentationStyle = .Popover
        v.preferredContentSize = kPopoverContentSize
        v.popoverPresentationController?.barButtonItem = friendInvitesBarButtonItem
        v.popoverPresentationController?.delegate = self
        
        presentViewController(v, animated: true, completion: nil)
    }
    
    func data() -> Array<Array<User>> {
        
        var rc = Array<Array<User>>()
        
        var friendsWhoOweMoney = Array<User>()
        var friendsWhoYouOweMoney = Array<User>()
        var friendsWhoAreEven = Array<User>()
        
        //owes you money
        for friend in kActiveUser.friends {
            
            if friend.localeDifferenceBetweenActiveUser < 0 {
                
                friendsWhoOweMoney.append(friend)
            }
        }
        
        for friend in kActiveUser.friends {
            
            if friend.localeDifferenceBetweenActiveUser > 0 {
                
                friendsWhoYouOweMoney.append(friend)
            }
        }
        
        for friend in kActiveUser.friends {
            
            if friend.localeDifferenceBetweenActiveUser == 0 {
                
                friendsWhoAreEven.append(friend)
            }
        }
        
        return [friendsWhoOweMoney, friendsWhoYouOweMoney, friendsWhoAreEven]
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
        
        refreshRequest?.cancel()
        refreshRequest = kActiveUser.getFriends().onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.view.hideLoader()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.tableView.layer.opacity = 1
            })
            
            self.addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
            self.setBarButtonItems()
        })
    }
    
    func openMenu() {
        
        let v = UINavigationController(rootViewController:MenuViewController())
        v.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        presentViewController(v, animated: true, completion: nil)
    }
    
    func add() {
        
        let view = SelectPurchaseOrTransactionViewController()
        let v = UINavigationController(rootViewController: view)

        v.modalPresentationStyle = .Popover
        v.preferredContentSize = kPopoverContentSize
        v.popoverPresentationController?.barButtonItem = addBarButtonItem
        v.popoverPresentationController?.delegate = self
        
        presentViewController(v, animated: true, completion: nil)
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
        
        setTableViewCellAppearanceForBackgroundGradient(cell)
        
        let friend = data()[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = friend.Username
        let amount = friend.localeDifferenceBetweenActiveUser //abs()
        
        var tintColor = UIColor.lightGrayColor()
        
        if friend.localeDifferenceBetweenActiveUser < 0 {
            
            tintColor = AccountColor.negativeColor()
        }
        else if friend.localeDifferenceBetweenActiveUser > 0 {
            
            tintColor = AccountColor.positiveColor()
        }
        
        //cell.imageView?.image = friend.localeDifferenceBetweenActiveUser < 0 ? kMinusImage : kPlusImage
        //cell.imageView?.tintWithColor(tintColor)
        
        cell.detailTextLabel?.text = Formatter.formatCurrencyAsString(amount)
        cell.detailTextLabel?.textColor = tintColor
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
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
                
                return "People I owe money"
            }
            else if section == 1 {
                
                return "People who owe me money"
            }
            else if section == 2 {
                
                return "People I'm even with"
            }
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //let header = view as! UITableViewHeaderFooterView
        
        //header.textLabel.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return tableView.editing ? .Delete : .None
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let friend = data()[indexPath.section][indexPath.row]
        
        UIAlertController.showAlertControllerWithButtonTitle("Delete", confirmBtnStyle: .Destructive, message: "Are you sure you want to remove \(friend.Username) as a friend?") { (response) -> () in
            
            if response == .Confirm {
                
                let index = find(kActiveUser.friends, friend)!
                
                tableView.beginUpdates()
                kActiveUser.friends.removeAtIndex(index)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                tableView.endUpdates()
                
                kActiveUser.removeFriend(friend.UserID, completion: { (success) -> () in

                    self.refresh(nil)
                })
            }
            else {
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
    }
}

extension FriendsViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        
        refresh(nil)
    }
}

extension FriendsViewController: FriendInvitesDelegate {
    
    func friendsChanged() {
        
        refresh(nil)
    }
}