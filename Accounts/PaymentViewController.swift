//
//  PaymentViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 16/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class PaymentViewController: ABTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        cell.textLabel?.text = "hello"
        
        return cell
    }
    
}
