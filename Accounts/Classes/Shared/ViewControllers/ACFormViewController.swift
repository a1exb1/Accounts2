//
//  AccountFormViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 10/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit

class ACFormViewController: FormViewController {

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
    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
//        
//        setupNavigationBarAppearance()
//    }
}

extension ACFormViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return kTableViewCellHeight
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        view.endEditing(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if let cell = c as? FormViewTextFieldCell {
            
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
            ]
            
            cell.textField.inputAccessoryView = toolbar
        }
        
        return c
    }
}