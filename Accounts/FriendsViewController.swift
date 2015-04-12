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
        
        self.refreshData()
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
    
    func refreshData(){

        Session.sharedInstance().activeUser.refreshFriendsList { () -> () in
            
            self.tableView.reloadData()
        }
    }
    
    func getUsersMatchingSearch(searchText: String) {
        
        self.usersMatchingSearch = []
        
        User.activeUsersContaining(searchText) { response in
         
            self.usersMatchingSearch = response
            self.tableView.reloadData()
        }
    }
    
    func friendsMatchingSearchText() -> Array<User> {
        
        var matches = Array<User>()
        
        if self.searchBar.text.count() > 0 {
            
            for user in Session.sharedInstance().activeUser.Friends {
                
                if user.Username.contains(self.searchBar.text) {
                    
                    matches.append(user)
                }
            }
        }
        else{
            
            matches = Session.sharedInstance().activeUser.Friends
        }
        
        return matches
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var rc = ""
        
        if section == 0 {
            
            rc = self.friendsMatchingSearchText().count > 0 ? "Friends" : ""
        }
        else{
            rc = self.usersMatchingSearch.count > 0 ? "Add friend" : ""
        }
        return rc
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        var rc = ""
        
        if section == 0 {
            
            rc = self.friendsMatchingSearchText().count == 0 ? "No matches" : ""
        }
        else{
            rc = (self.searchBar.text.count() > 0 && self.usersMatchingSearch.count == 0) ? "No matches online" : ""
        }
        return rc
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? self.friendsMatchingSearchText().count : self.usersMatchingSearch.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = self.friendsMatchingSearchText()[indexPath.row].Username
        }
        else{
            
            cell.textLabel?.text = self.usersMatchingSearch[indexPath.row].Username
            cell.detailTextLabel?.text = "Tap to add friend"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //self.openPayment(indexPath.row)

        if indexPath.section == 1 {
            
            var relation: User = self.usersMatchingSearch[indexPath.row]
            
            Session.sharedInstance().activeUser.addFriend(relation.UserID, completion: { () -> () in
                
                self.refreshData()
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
    }
}

