//
//  Transaction.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyJSON

class Transaction: JSONObject {
   
    var TransactionID: Int = 0
    var user = User()
    var friend = User()
    var Amount: Double = 0
    var Description = ""
    var purchase = Purchase()
    
    override func registerClassesForJsonMapping() {
        
        //registerClass(User.self, propertyKey: "user", jsonKey: "User")
        //registerClass(User.self, propertyKey: "friend", jsonKey: "User1")
        //registerClass(Purchase.self, propertyKey: "purchase", jsonKey: "Purchase")
    }
    
    override func setExtraPropertiesFromJSON(json: JSON) {
       
        user = User.createObjectFromJson(json["User"])
        friend = User.createObjectFromJson(json["User1"])
        purchase = Purchase.createObjectFromJson(json["Purchase"])
    }
    
    override func webApiRestObjectID() -> Int? {
        
        return TransactionID
    }
}
