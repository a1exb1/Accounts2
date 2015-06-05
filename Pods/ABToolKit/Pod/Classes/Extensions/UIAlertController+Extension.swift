//
//  UIAlertController+Extension.swift
//  objectmapperTest
//
//  Created by Alex Bechmann on 28/04/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    public func show() {

        UIViewController.topMostController().presentViewController(self, animated: true) { () -> Void in
        }
    }
}