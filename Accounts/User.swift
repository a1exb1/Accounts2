//
//  User.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class User: JSONObject {
    
    var id = 0
    var Username = ""
    
    override class func jsonURL(id:Int) -> String {
        return "http://topik.ustwo.com/Users/\(id)"
    }
}
