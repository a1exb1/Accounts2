//
//  ViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

let kSearchBarMargin: CGFloat = 5

class FriendsViewController: BaseViewController, UISearchControllerDelegate {
    
    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    var usersMatchingSearch: Array<User> = []
    var searchController: UISearchController? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupTableView()
        self.setupSearchBar()
        
        self.title = "Contacts"
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.refreshData(nil)
    }
    
    func setupTableView() {
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.view.addSubview(self.tableView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.tableView.addTopConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addLeftConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addRightConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addBottomConstraint(toView: self.view, relation: .Equal, constant: 0)
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func setupSearchBar() {
    
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        
        self.searchController?.searchBar.placeholder = "Search existing or new friends"
        self.searchController?.dimsBackgroundDuringPresentation = false
    }
    
    func updateSearchBarViewFrame() {
        
        self.searchController?.searchBar.frame = navigationController!.navigationBar.bounds
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.updateSearchBarViewFrame()
    }

    func refreshData(refreshControl: UIRefreshControl?) {

        Session.sharedInstance().activeUser.refreshFriendsList().onContextSuccess { () -> () in
            
            self.tableView.reloadData()
            
        }.onDownloadFinished { () -> () in
            
            refreshControl?.endRefreshing()
            
        }.onDownloadFailure { (error, alert) -> () in
            
            alert.show()
        }
        
        if let searchText = self.searchController?.searchBar.text {
         
            self.getUsersMatchingSearch(searchText)
        }
    }
    
    func getUsersMatchingSearch(searchText: String) {

        self.usersMatchingSearch = []
        
        self.tableView.reloadData()
        
        User.activeUsersContaining(searchText) { response in
         
            self.usersMatchingSearch = response
            self.tableView.reloadData()
        }
    }
    
    func friendsMatchingSearchText(array: Array<User>) -> Array<User> {
        
        var matches = Array<User>()
        
        if self.searchController?.searchBar.text.charCount() > 0 {
            
            for user in array {
                
                if user.Username.lowercaseString.contains(self.searchController!.searchBar.text.lowercaseString) {
                    
                    matches.append(user)
                }
            }
        }
        else{
            
            matches = array
        }
        
        return matches
    }
    
    func confirmedFriends() -> Array<User> {
        
        var array = Session.sharedInstance().activeUser.confirmedFriends()
        return self.friendsMatchingSearchText(array)
    }
    
    func pendingFriends() -> Array<User> {
        
        var array = Session.sharedInstance().activeUser.pendingFriends()
        return self.friendsMatchingSearchText(array)
    }
    
    
    func arrayForSection(section: Int) -> [User] {
        
        if section == 0 {
            
            return confirmedFriends()
        }
        else if section == 1 {
            
            return pendingFriends()
        }
        else {
            return self.usersMatchingSearch
        }
    }
    
    func viewOverview(friend: User) {
        
        var v = OverviewViewController()
        v.friend = friend
        self.navigationController?.pushViewController(v, animated: true)
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var rc = ""
        
        if section == 0 {
            
            rc = self.confirmedFriends().count > 0 ? "Friends" : ""
        }
        else if section == 1{
            rc = self.pendingFriends().count > 0 ? "Pending" : ""
        }
        else{
            rc = self.usersMatchingSearch.count > 0 ? "Add friend" : ""
        }
        return rc
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        var rc = ""
        
        if section == 0 {
            
            rc = self.confirmedFriends().count == 0 ? "No matches" : ""
        }
        else if section == 1{
            rc = self.pendingFriends().count == 0 ? "No matches pending" : ""
        }
        else{
            rc = (self.searchController?.searchBar.text.charCount() > 0 && self.usersMatchingSearch.count == 0) ? "No matches online" : ""
        }
        return rc
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayForSection(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        let friend = self.arrayForSection(indexPath.section)[indexPath.row]
        
        cell.textLabel?.text = friend.Username
        
        if indexPath.section == 2 {
            
            cell.detailTextLabel?.text = "Tap to add friend"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            
            var relation: User = self.usersMatchingSearch[indexPath.row]
            
            Session.sharedInstance().activeUser.addFriend(relation.UserID, completion: { () -> () in
                
                self.refreshData(nil)
            })
        }
        else {
            
            let friend = self.arrayForSection(indexPath.section)[indexPath.row]
            viewOverview(friend)
        }
    }
}


extension FriendsViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.getUsersMatchingSearch(searchController.searchBar.text)
    }
    
}
