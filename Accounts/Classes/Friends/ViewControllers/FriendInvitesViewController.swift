//
//  FriendInvitesViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class FriendInvitesViewController: ACBaseViewController {

    var tableView = UITableView()
    var invites:Array<Array<User>> = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Friend invites"
        
        setupTableView(tableView, delegate: self, dataSource: self)
        setupTableViewRefreshControl(tableView)
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        addCloseButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "findFriends")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh(nil)
    }

    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getUnconfirmedInvites { (invites) -> () in
            
            self.invites[0] = invites
            
        }.onDownloadFinished { () -> () in
            
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    func findFriends() {
        
        navigationController?.pushViewController(FindFriendsViewController(), animated: true)
    }
}

extension FriendInvitesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return invites.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return invites[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: .Value1, reuseIdentifier: identifier)
        })
        
        let user = invites[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = user.Username
        cell.detailTextLabel?.text = "Accept invite"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = invites[indexPath.section][indexPath.row]
        
        kActiveUser.addFriend(user.UserID, completion: { (success) -> () in
            
            self.refresh(nil)
        })
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
//        if section == 0 {
//            
//            return "Pending invites sent"
//        }
//        if section == 1 {
//            
//            return "Pending invites received"
//        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.Insert
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = invites[indexPath.section][indexPath.row]
        
        kActiveUser.addFriend(user.UserID, completion: { (success) -> () in
            
            self.refresh(nil)
        })
    }
}