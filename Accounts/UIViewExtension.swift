//
//  UIViewExtension.swift
//  Accounts
//
//  Created by Alex Bechmann on 22/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

extension UIView{
   
    func showLoader() {
        
        var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        actInd.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(actInd)
        actInd.addCenterYConstraint(toView: self)
        actInd.addCenterXConstraint(toView: self)
        actInd.startAnimating()
    }
    
    func hideLoader() {
        
        for v in self.subviews{
            if v is UIActivityIndicatorView{
                v.stopAnimating()
            }
        }
    }
    
}
