//
//  Transaction.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class Transaction: JSONObject {
   
    var user = User()
    var friend = User()
    var Amount: Double = 0
    var Description = ""
    var purchase = Purchase()
    
    override func setExtraPropertiesFromJSON(json: JSON) {
        
        self.friend = User.createObjectFromJson(json["User1"])
        self.user = User.createObjectFromJson(json["User"])
        
        println(json["Purchase"].stringValue)
        
        if !json["Purchase"].dictionaryValue.isEmpty {
            
            self.purchase = Purchase.createObjectFromJson(json["Purchase"])
        }
    }
}
