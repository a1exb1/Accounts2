//
//  FindFriendsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

class FindFriendsViewController: BaseViewController {

    var tableView = UITableView()
    var matches = [User]()
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add friend"
        
        edgesForExtendedLayout = UIRectEdge.None;
        
        setupTableView(tableView, delegate: self, dataSource: self)
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        setupSearchController()
    }
    
    
    func setupSearchController() {
        
        let searchBar = searchController.searchBar
        
        searchController.delegate = self
        searchBar.delegate = self
        
        tableView.tableHeaderView = searchBar
        searchBar.sizeToFit()
        tableView.contentInset = UIEdgeInsets(top: searchBar.frame.height, left: 0, bottom: 0, right: 0)
        
        searchController.dimsBackgroundDuringPresentation = false
        
        view.addSubview(searchController.searchBar)
    }
    
    func getMatches(searchText: String) {
    
        JsonRequest.create("\(User.webApiUrls().getUrl(kActiveUser.UserID)!)/ActiveUsersMatching/\(searchText)", parameters: nil, method: .GET).onDownloadSuccess { (json, request) -> () in
            
            self.matches = User.convertJsonToMultipleObjects(User.self, json: json)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.active = false
        searchController.delegate = nil
        searchController.searchBar.delegate = nil
        
        //searchController.searchBar.removeFromSuperview()
        
    }
    
    func addFriend(match:User) {
        
        searchController.active = false
        
        kActiveUser.addFriend(match.UserID, completion: { (success) -> () in
            
            if success {
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                
                UIAlertView(title: "Oops!", message: "Something went wrong!", delegate: self, cancelButtonTitle: "OK").show()
            }
        })
        
        
    }
}

extension FindFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: .Value1, reuseIdentifier: identifier)
        })
        
        let match = matches[indexPath.row]
        
        cell.textLabel?.text = match.Username
        cell.detailTextLabel?.text = "Add as friend"
        
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.Insert
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = matches[indexPath.row]
        addFriend(user)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = matches[indexPath.row]
        addFriend(user)
    }
}

extension FindFriendsViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        getMatches(searchText)
    }
}