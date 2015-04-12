//
//  ViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class FriendsViewController: BaseViewController {
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Friends"
        
        self.setupTableView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPayment")
        self.load()
    }
    
    func setupTableView(){
        
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

    func addPayment(){
        
        self.openPayment(0)
    }
    
    func openPayment(id:Int){
        
    }
    
    func load(){

    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Session.sharedInstance().activeUser.Friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        cell.textLabel?.text = Session.sharedInstance().activeUser.Friends[indexPath.row].Username
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.openPayment(indexPath.row)
    }

}

