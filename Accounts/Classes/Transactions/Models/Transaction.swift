//
//  Transaction.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit
import ABToolKit

class Transaction: JSONObject {
   
    var user = User()
    var friend = User()
    var Amount: Double = 0
    var Description = ""
    var purchase = Purchase()
    
    override func registerClassesForJsonMapping() {
        
        registerClass(User.self, propertyKey: "user", jsonKey: "User")
        registerClass(User.self, propertyKey: "friend", jsonKey: "User1")
        registerClass(Purchase.self, propertyKey: "purchase", jsonKey: "Purchase")
    }
}
