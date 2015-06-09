//
//  SelectFriendsViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit


protocol SelectFriendsDelegate {
    
    func didSelectFriends(friends: Array<User>)
}

protocol SelectFriendDelegate {
    
    func didSelectFriend(friend: User)
}

class SelectFriendsViewController: BaseViewController {

    var tableView = UITableView()
    var selectMultipleFriendsDelegate: SelectFriendsDelegate?
    var selectFriendDelegate: SelectFriendDelegate?
    var friendIsSelected = Dictionary<Int, Bool>()
    var allowEditing = false
    var allowMultipleSelection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        if allowMultipleSelection {

            if allowEditing {
                
                title = "Select friends"
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
            }
            else {
                
                title = "Friends"
            }
        }
        else {
            
            if allowEditing {
                
                title = "Select friend"
            }
            else {
                
                title = "Friend"
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(nil)
    }
    
    override func refresh(refreshControl: UIRefreshControl?) {
        
        kActiveUser.getFriends().onDownloadFinished({ () -> () in
            
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }).onDownloadFailure({ (error, alert) -> () in
            
            alert.show()
        })
    }
    
    func done() {
        
        var friends = Array<User>()
        
        for values in friendIsSelected {
            
            for friend in kActiveUser.friends {
                
                if friend.UserID == values.0 {
                    
                    friends.append(friend)
                }
            }
        }
        
        selectMultipleFriendsDelegate?.didSelectFriends(friends)
        navigationController?.popViewControllerAnimated(true)
    }

    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setSelectedFriends(friends: Array<User>) {
        
        for friend in friends {
            
            friendIsSelected[friend.UserID] = true
        }
    }
    
    func setSelectedFriend(friend: User) {
        
        setSelectedFriends([friend])
    }
}

extension SelectFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return kActiveUser.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let friend = kActiveUser.friends[indexPath.row]
        
        cell.textLabel?.text = friend.Username
        
        var selected = false
        
        if let s = friendIsSelected[friend.UserID] {
            
            selected = s
        }
        
        cell.accessoryType = selected ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if allowEditing {
            
            let friend = kActiveUser.friends[indexPath.row]
            
            if allowMultipleSelection {
                
                if let v = friendIsSelected[friend.UserID] {
                    
                    friendIsSelected.removeValueForKey(friend.UserID)
                }
                else {
                    
                    friendIsSelected[friend.UserID] = true
                }
                
                tableView.reloadData()
            }
            else {
                
                selectFriendDelegate?.didSelectFriend(friend)
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}