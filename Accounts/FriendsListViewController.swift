//
//  FriendsListViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

protocol FriendsListViewControllerDelegate {
    
    func didSelectFriends(friends: [User])
}

class FriendsListViewController: BaseViewController {

    var friends: [User] = []
    var selectedFriends: [User] = []
    var tableView = UITableView()
    var delegate: FriendsListViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.friends = Session.sharedInstance().activeUser.Friends
        self.setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationButtons()
        
        Session.sharedInstance().activeUser.refreshFriendsList({ () -> () in
            
            self.friends = Session.sharedInstance().activeUser.Friends // needed?
            self.tableView.reloadData()
            
            }, onFailure: { () -> () in
                
                
            }) { () -> () in
                
                
        }
    }
    
    func select() {
        
        self.delegate?.didSelectFriends(self.selectedFriends)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setupNavigationButtons() {
        
        if self.selectedFriends.count > 0 {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.Plain, target: self, action: "select")
        }
        else{
            
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    func setupTableView() {
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsetsZero)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
     
        var friend = self.friends[indexPath.row]
        
        cell.textLabel?.text = friend.Username
        
        if contains(self.selectedFriends, friend) {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        var friend = self.friends[indexPath.row]
        
        if contains(self.selectedFriends, friend){
            
            if let index = find(self.selectedFriends, friend) {
                
                self.selectedFriends.removeAtIndex(index)
            }
        }
        else{
            
            self.selectedFriends.append(friend)
        }
        
        
        
        tableView.reloadData()
        self.setupNavigationButtons()
    }
    
    
}

