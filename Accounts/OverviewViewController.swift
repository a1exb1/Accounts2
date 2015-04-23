//
//  OverviewViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class OverviewViewController: BaseViewController {

    var label = UILabel()
    var friend = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLabel()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addTransaction")
        
        self.title = self.friend.Username
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }

    func setupLabel() {
        
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.label)
        
        self.label.addTopConstraint(toView: self.view, relation: .Equal, constant: 64)
        self.label.addLeftConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.label.addRightConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.label.addHeightConstraint(relation: .Equal, constant: 50)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        
        self.label.text = ""
        self.view.showLoader()
        
        var urlString = AppTools.WebMvcController("Transaction", action: "DifferenceBetweenUsers")
        var data = [
            "UserID" : Session.sharedInstance().activeUser.UserID,
            "relationUserID" : self.friend.UserID
        ]
        
        JsonRequest.create(urlString, parameters: data, method: .POST).onDownloadSuccess { (json, request) -> () in
            
            var difference = json["difference"].doubleValue
            
            var oweText = ""
            if difference > 0 {
                oweText = "\(self.friend.Username) owes you:"
            }
            else{
                oweText = "You owe \(self.friend.Username):"
            }
            
            self.label.text = "\(oweText) \(difference)"
            
        }.onDownloadFinished { () -> () in
            
            self.view.hideLoader()
        }

    }
    
    func addTransaction(){
        
        self.openTransaction(nil)
    }
    
    func openTransaction(transaction:Transaction?){
        
        var v = TransactionViewController()
        
        if let t = transaction {
            t.friend = self.friend
            v.transaction = t
        }
        else{
            v.transaction.friend = self.friend
        }
        
        self.navigationController?.pushViewController(v, animated: true)
    }

}
