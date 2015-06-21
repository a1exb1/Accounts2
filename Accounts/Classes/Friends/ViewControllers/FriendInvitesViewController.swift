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
    var invites:Array<User> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        setupTableViewRefreshControl(tableView)
    }

    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getUnconfirmedInvites { (invites) -> () in
            
            self.invites = invites
            
        }.onDownloadFinished { () -> () in
            
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
}

extension FriendInvitesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return invites.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let user = invites[indexPath.row]
        
        cell.textLabel?.text = user.Username
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = invites[indexPath.row]
        
        user.addFriend(kActiveUser.UserID, completion: { () -> () in
            
            self.refresh(nil)
        })
    }
}