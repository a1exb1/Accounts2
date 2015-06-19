//
//  ACBaseViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 10/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class ACBaseViewController: BaseViewController {

    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
    }
    
    func setupNavigationBarAppearance() {
        
        blurView.removeFromSuperview()
        
        if let navigationController = navigationController{
            
            let frame = navigationController.navigationBar.frame
            
            blurView.frame = CGRect(x: frame.origin.x, y: -frame.origin.y, width: frame.width, height: frame.height + frame.origin.y)
        }
        
        navigationController?.navigationBar.addSubview(blurView)
    }
}

extension ACBaseViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return kTableViewCellHeight
    }
}