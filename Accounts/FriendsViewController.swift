//
//  ViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class FriendsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Friends"
        
        self.setTabBar(Tools.imageWithColor(UIColor.redColor(), size: CGSize(width: 10, height: 10)))
        
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.setupTableViewConstraints()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPayment")
    }
    
    func setupTableViewConstraints(){
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.tableView.addTopConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addLeftConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addRightConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.tableView.addBottomConstraint(toView: self.view, relation: .Equal, constant: 0)
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        cell.textLabel?.text = "Person"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.openPayment(indexPath.row)
    }
    
    func addPayment(){
        
        self.openPayment(0)
    }
    
    func openPayment(id:Int){
        
        
    }
}

