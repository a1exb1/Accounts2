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
    
    var tableViews: Array<UITableView> = []
    public var shouldDeselectCellOnViewWillAppear = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldDeselectCellOnViewWillAppear {
            
            for tableView in tableViews {
                
                deselectSelectedCell(tableView)
            }
        }
    }
    
    public func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource:UITableViewDataSource) {
        
        view.addSubview(tableView)
        
        setupTableViewConstraints(tableView)
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableViews.append(tableView)
        
        tableView.reloadData()
    }
    
    public func setupTableViewRefreshControl(tableView: UITableView) {
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.AllEvents)
        tableView.addSubview(refreshControl)
    }
    
    public func setupTableViewConstraints(tableView: UITableView) {
        
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.fillSuperView(UIEdgeInsetsZero)
    }
    
    public func refresh(refreshControl: UIRefreshControl?) {
        
    }
    
    public func deselectSelectedCell(tableView: UITableView) {
        
        if let indexPath = tableView.indexPathForSelectedRow() {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    //MARK: - Dismiss view controller
    
    public func dismissViewControllerFromCurrentContextAnimated(animated: Bool) {
        
        if navigationController?.viewControllers.count > 1 {
            
            navigationController?.popViewControllerAnimated(animated)
        }
        else {
            
            dismissViewControllerAnimated(animated, completion: nil)
        }
    }
}

