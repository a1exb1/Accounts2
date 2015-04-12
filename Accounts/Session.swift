//
//  Session.swift
//  Accounts
//
//  Created by Alex Bechmann on 11/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

let kSharedSessionInstance = Session()

class Session: NSObject {
   
    var activeUser = User()
    
    class func sharedInstance() -> Session {
        return kSharedSessionInstance
    }
    
    func login(username: String, password:String, completion: (success: Bool) -> ()) {
        
        var data = [
            "username" : username,
            "password" : password
        ]

        JSONReader.JsonAsyncRequest(AppTools.WebMvcController("User", action: "Login"), data: data, httpMethod: .GET) { (response: JSON) -> () in
            
            var r = Response.createObjectFromJson(response["Response"])! as Response
            
            if r.Status == .Success {
                
                var userJSON = response["User"]
                self.activeUser = User.createObjectFromJson(response["User"])! as User
                self.activeUser.saveUserOnDevice()
            }
            
            
            completion(success: (self.userIsLoggedIn() && r.Status == .Success))
        }
    }
    
    func logout() {
        
        self.activeUser = User()
        self.activeUser.saveUserOnDevice()
        
        UIApplication.sharedApplication().keyWindow?.rootViewController = UIStoryboard.initialViewControllerFromStoryboardNamed("Login")
        UIApplication.sharedApplication().keyWindow?.makeKeyAndVisible()
        
    }
    
    func userIsLoggedIn() -> Bool {
        
        return self.activeUser.UserID > 0
    }
    
}
