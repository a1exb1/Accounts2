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
        
        return AppTools.WebApiURL("Users") + "/\(id)"
    }
    
    override func setExtraPropertiesFromJSON(json:JSON) {
        
        super.setExtraPropertiesFromJSON(json)
        
        self.Friends = Array<User>()
        
        for (index: String, friendJSON: JSON) in json["Friends"] {
            
            var friend:User = User.createObjectFromJson(friendJSON)! as User
            self.Friends.append(friend)
        }
    }
    
    func saveUserOnDevice() {

        Tools.SetValueInPlistDocuments("AppSettings", key:"activeUser", value:self.convertToJSONString())
    }
    
    class func userSavedOnDevice() -> User? {
        
        var user:User? = nil
        
        if let userStr:String = Tools.GetValueFromPlistDocuments("AppSettings", key: "activeUser") {
            
            if userStr.count() > 0 {
                
                let data:NSData = userStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                user = User.createObjectFromJson(JSON(data: data)) as User!
            }
            
            
        }
        
        return user
    }
}
