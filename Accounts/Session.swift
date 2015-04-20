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
   
    var activeUser:User = User()
    
    class func sharedInstance() -> Session {
        return kSharedSessionInstance
    }
    
    func login(username: String, password:String, completion: (success: Bool) -> ()) {
        
        var urlString = AppTools.WebMvcController("User", action: "Login")
        var data = [
            "username" : username,
            "password" : password
        ]
        
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: .GET, onSuccess: { (json) -> () in
            
            var r:Response = Response.createObjectFromJson(json["Response"])
            
            if r.Status == .Success {
                
                self.activeUser = User.createObjectFromJson(json["User"])
                self.activeUser.saveUserOnDevice()
            }
            
            completion(success: (self.userIsLoggedIn() && r.Status == .Success))
            
        }, onFailure: { (error: NSErrorPointer) -> () in
            
            
        }) { () -> () in
            
            
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
