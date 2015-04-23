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
    
    func login(username: String, password:String) -> JsonRequest {
        
        var urlString = AppTools.WebMvcController("User", action: "Login")
        var data = [
            "username" : username,
            "password" : password
        ]
        
        return JsonRequest.create(urlString, parameters: data, method: .GET).onDownloadSuccess { (json, request) -> () in
            println(json)
            var r:Response = Response.createObjectFromJson(json["Response"])
            
            if r.Status == .Success {
                
                self.activeUser = User.createObjectFromJson(json["User"])
                self.activeUser.saveUserOnDevice()
            }
            
            (self.userIsLoggedIn() && r.Status == .Success) ? request.succeedContext() : request.failContext()
            
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
