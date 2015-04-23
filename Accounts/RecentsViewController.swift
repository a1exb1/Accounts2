//
//  PurchasesViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class RecentsViewController: UIViewController {

    var tableView = UITableView()
    let user = Session.sharedInstance().activeUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPurchase")
        
        self.setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(nil)
    }
    
    func refresh(refreshControl: UIRefreshControl?) {
        
        user.getTransactions().onContextSuccess { () -> () in
            
            self.tableView.reloadData()
            
        }.onDownloadFinished { () -> () in
            
            refreshControl?.endRefreshing()
        }
    }

    func setupTableView() {
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        self.tableView.fillSuperView(UIEdgeInsetsZero)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPurchase() {
        
        var v = PurchaseViewController()
        self.navigationController?.pushViewController(v, animated: true)
    }
}

extension RecentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user.transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        let transaction = self.user.transactions[indexPath.row]
        
        cell.textLabel?.text = "amount: \(transaction.Amount)"
        
        return cell
    }
}
