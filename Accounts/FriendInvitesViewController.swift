//
//  FriendInvitesViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 12/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class FriendInvitesViewController: BaseViewController {
   
    var tableView = UITableView()
    var invites = Array<Relation>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupTableView()
        
        self.title = "Invites"
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.refreshData(nil)
    }
    
    func setupTableView() {
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
    }
    
    func refreshData(refreshControl: UIRefreshControl?) {
        
        Session.sharedInstance().activeUser.getUnconfirmedInvites { (invites) -> () in
            
            self.invites = invites
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
}

extension FriendInvitesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.invites.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        cell.textLabel?.text = "\(self.invites[indexPath.row].user.Username)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var relation: Relation = self.invites[indexPath.row]
        
        Session.sharedInstance().activeUser.addFriend(relation.user.UserID, completion: { () -> () in
            
            self.refreshData(nil)
        })
    }
    
}