//
//  User.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class User: JSONObject {
    
    var UserID = 0
    var Username = ""
    var Friends: Array<User> = []
    
    override class func jsonURL(id:Int) -> String {
        return "http://alex.bechmann.co.uk/iou/api/Users/\(id)"
    }
    
    override func setExtraPropertiesFromJSON(json:JSON) {
        
        self.Friends = Array<User>()
        
        for (index: String, friendJSON: JSON) in json["Friends"] {
            
            var friend:User = User.createObjectFromJson(friendJSON)! as User
            self.Friends.append(friend)
        }
    }
    
    func saveUserOnDevice() {
        println(self.convertToJSONString())
        //Tools.SetValueInPlistDocuments("AppSettings", key:"activeUser", value:self.convertToJSONString())
    }
}
