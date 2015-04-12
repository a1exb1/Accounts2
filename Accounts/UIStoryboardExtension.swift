//
//  UIStoryboardExtension.swift
//  Accounts
//
//  Created by Alex Bechmann on 12/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func initialViewControllerFromStoryboardNamed(name:String) -> UIViewController {
        
        var storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateInitialViewController() as UIViewController
    }
}

