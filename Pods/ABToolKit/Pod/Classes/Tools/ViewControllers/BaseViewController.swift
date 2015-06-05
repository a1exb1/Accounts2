//
//  BaseViewController.swift
//  Pods
//
//  Created by Alex Bechmann on 30/05/2015.
//
//

import UIKit

@objc protocol BaseViewControllerDelegate {
    
    func preferredNavigationBar()
}

public class BaseViewController: UIViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    public func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource:UITableViewDataSource) {
        
        view.addSubview(tableView)
        
        setupTableViewConstraints(tableView)
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        
        setupTableViewRefreshControl(tableView)
    }
    
    func setupTableViewRefreshControl(tableView: UITableView) {
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.AllEvents)
        tableView.addSubview(refreshControl)
    }
    
    func setupTableViewConstraints(tableView: UITableView) {
        
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.fillSuperView(UIEdgeInsetsZero)
    }
    
    public func refresh(refreshControl: UIRefreshControl?) {
        
    }
    
    public func deselectTableViewSelectedCell(tableView: UITableView) {
        
        if let indexPath = tableView.indexPathForSelectedRow() {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
}

