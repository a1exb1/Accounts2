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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPayment")
    }

    func setupLabel() {
        
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.label)
        
        self.label.addTopConstraint(toView: self.view, relation: .Equal, constant: 64)
        self.label.addLeftConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.label.addRightConstraint(toView: self.view, relation: .Equal, constant: 0)
        self.label.addHeightConstraint(relation: .Equal, constant: 50)
        
        self.label.text = "friend: \(self.friend.Username)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPayment(){
        
        self.openPayment(0)
    }
    
    func openPayment(id:Int){
        
        var v = PaymentViewController()
        self.navigationController?.pushViewController(v, animated: true)
    }

}
