//
//  AppTools.swift
//  Accounts
//
//  Created by Alex Bechmann on 11/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class AppTools: NSObject {
 
    class func Domain() -> String {
        
        return "http://alex.bechmann.co.uk/iou"
    }
    
    class func WebApiURL(webApiControllerName:String) -> String{
        return Domain() + "/Api/" + webApiControllerName + "/"
    }
    
    class func WebMvcController(controller:String, action:String) -> String{
        return Domain() + "/" + controller + "/" + action + "/"
    }
    
}
