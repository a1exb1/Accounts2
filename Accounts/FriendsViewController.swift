//
//  ViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

let kSearchBarMargin: CGFloat = 5

class FriendsViewController: BaseViewController {
    
    var tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    var usersMatchingSearch: Array<User> = []
    var searchBar = UISearchBar()
    
    var searchBarView = UIView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupTableView()
        self.setupSearchBar()
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPayment")
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
        
        self.updateSearchBarViewFrame()
        self.navigationController?.navigationBar.addSubview(self.searchBarView)
        
        self.searchBarView.addSubview(searchBar)
        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchBar.fillSuperView(UIEdgeInsets(top: kSearchBarMargin, left: kSearchBarMargin, bottom: -kSearchBarMargin, right: -kSearchBarMargin))
        
        searchBar.placeholder = "Search existing or new friends"
        searchBar.returnKeyType = UIReturnKeyType.Search
        searchBar.searchBarStyle = UISearchBarStyle.Minimal;
        searchBar.delegate = self
    }
    
    func updateSearchBarViewFrame() {
        
        self.searchBarView.frame = navigationController!.navigationBar.bounds
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.updateSearchBarViewFrame()
    }
    
    func addPayment(){
        
        self.openPayment(0)
    }
    
    func openPayment(id:Int){
        
    }
    
    func refreshData(refreshControl: UIRefreshControl?) {

        Session.sharedInstance().activeUser.refreshFriendsList { () -> () in
            
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        }
        
        self.getUsersMatchingSearch(self.searchBar.text)
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
        
        if self.searchBar.text.count() > 0 {
            
            for user in array {
                
                if user.Username.contains(self.searchBar.text) {
                    
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
            rc = (self.searchBar.text.count() > 0 && self.usersMatchingSearch.count == 0) ? "No matches online" : ""
        }
        return rc
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rc = 0
        
        switch section {
            
        case 0: rc = self.confirmedFriends().count; break;
        case 1: rc = self.pendingFriends().count;  break;
        case 2: rc = self.usersMatchingSearch.count; break;
            
        default:break;
        }
        
        return rc
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = self.confirmedFriends()[indexPath.row].Username
        }
        else if indexPath.section == 1{
            
            cell.textLabel?.text = self.pendingFriends()[indexPath.row].Username
        }
        else{
            
            cell.textLabel?.text = self.usersMatchingSearch[indexPath.row].Username
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
    }

}

extension FriendsViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        self.getUsersMatchingSearch(searchText)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        
        self.refreshData(nil)
    }
}

