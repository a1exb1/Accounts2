//
//  BaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setTabBar(image:UIImage){
        if let tabBarItem = self.tabBarItem{
            tabBarItem.image = image
        }
    }

}
