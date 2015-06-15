//
//  AcceptEncodingSettingViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 15/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class AcceptEncodingSettingViewController: ACBaseViewController {

    var tableView = UITableView()
    var data = ["None", "deflate", "gzip"]
    var currentValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        currentValue = Settings.getCompresJSONSettings().acceptEncoding
    }

    override func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension AcceptEncodingSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        setupTableViewCellAppearance(cell)
        
        cell.textLabel?.text = data[indexPath.row]
        cell.accessoryType = data[indexPath.row] == currentValue ? .Checkmark : .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var value = data[indexPath.row].replaceString("None", withString: "")
        
        Settings.setAcceptEncoding(value)
        
        navigationController?.popViewControllerAnimated(true)
    }
}