//
//  MenuViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 12/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController {

    var tableView = UITableView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.setupTableView()
    }

    func setupTableView() {
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        cell.textLabel?.text = "Logout"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        Session.sharedInstance().logout()
    }
    
}