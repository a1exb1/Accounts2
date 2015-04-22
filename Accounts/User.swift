//
//  User.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

let kMVCControllerName = "User"

class User: JSONObject {
    
    var UserID = 0
    var Username = ""
    var Friends: Array<User> = []
    var relationStatusToActiveUser: RelationStatus = RelationStatus.Undefined
    
    override class func jsonURL(id:Int) -> String {
        
        return AppTools.WebApiURL("Users") + "/\(id)"
    }
    
    override func setExtraPropertiesFromJSON(json:JSON) {
        
        super.setExtraPropertiesFromJSON(json)
        
        self.setFriendsFromJSON(json["friends"])
        self.relationStatusToActiveUser = RelationStatus(rawValue: json["relationStatus"].intValue)!
    }
    
    func setFriendsFromJSON(json:JSON) {
        
        self.Friends = Array<User>()
        
        for (index: String, friendJSON: JSON) in json {
            
            var friend:User = User.createObjectFromJson(friendJSON)
            self.Friends.append(friend)
        }
    }
    
    func getUnconfirmedInvites(completion:(invites:Array<Relation>) -> ()) {
        
        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "FriendInvitations")
        var data: Dictionary<String, AnyObject> = [
            "UserID" : self.UserID
        ]
    
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: .POST, onSuccess: { (response:JSON) -> () in
            
            var relations = Array<Relation>()
            
            for (index: String, relationJSON: JSON) in response {
                
                var relation:Relation = Relation.createObjectFromJson(relationJSON)
                relations.append(relation)
            }
            
            completion(invites: relations)
            
            }, onFailure: nil, onFinished: nil )
    }
    
    func addFriend(relationUserID:Int, completion: () -> ()) {
        
        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "AddFriend")
        var data = [
            "UserID": self.UserID,
            "relationUserID" : relationUserID
        ]
        
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: .POST, onSuccess: { (json) -> () in
            
            completion()
            
        }, onFailure: { (error: NSErrorPointer) -> () in
            
            
        }) { () -> () in
            
            
        }
    }
    
    func saveUserOnDevice() {

        Tools.SetValueInPlistDocuments("AppSettings", key:"activeUser", value:self.convertToJSONString())
    }
    
    class func userSavedOnDevice() -> User? {
        
        var user:User? = nil
        
        if let userStr:String = Tools.GetValueFromPlistDocuments("AppSettings", key: "activeUser") {
            
            if userStr.charCount() > 0 {
                
                let data:NSData = userStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                user = User.createObjectFromJson(JSON(data: data)) as User
            }
        }
        
        return user
    }
    
    func refreshFriendsList(onSuccess: (() -> ())?, onFailure:(() -> ())?, onFinished: (() -> ())?) {
        
        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "GetFriends")
        var data = [ "UserID" : self.UserID ]
        
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: .POST, onSuccess: { (json) -> () in
            
            self.setFriendsFromJSON(json)
            onSuccess?()
            
        }, onFailure: { (error: NSErrorPointer) -> () in
            
            onFailure?()
            
        }) { () -> () in
            
            onFinished?()
        }
    }
    
    func confirmedFriends() -> Array<User> {
        
        var rc = Array<User>()
        
        for friend in self.Friends {
            
            if friend.relationStatusToActiveUser == .Confirmed {
                rc.append(friend)
            }
        }
        
        return rc
    }
    
    func pendingFriends() -> Array<User> {
        
        var rc = Array<User>()
        
        for friend in self.Friends {
            
            if friend.relationStatusToActiveUser == .Pending {
                rc.append(friend)
            }
        }
        
        return rc
    }
    
    func addTransaction(transaction:Transaction, onSuccess:(() -> ())?, onFailure:(() -> ())?, onFinished:(() -> ())?) {
        
        var urlString = AppTools.WebMvcController("Transaction", action: "AddTransaction")
        var data:Dictionary<String, AnyObject> = [
            "UserID" : self.UserID,
            "RelationUserID" : transaction.friend.UserID,
            "Amount" : transaction.Amount,
            //"Description" : transaction.Description
        ]
        
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: HttpMethod.POST, onSuccess: { (json) -> () in
            
            onSuccess?()
            
        }, onFailure: { (error) -> () in
            
            Tools.ShowAlertControllerOK("Transaction not added successfully!", completionHandler: { (response) -> () in
            })
            
            onFailure?()
            
        }) { () -> () in
            
            onFinished?()
        }
    }
    
    class func activeUsersContaining(string: String, completion:(users:Array<User>) -> ()) {
        
        var matches = Array<User>()
        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "ActiveUsersMatching")
        var data:Dictionary<String, AnyObject> = [
            "searchText" : string,
            "UserID" : Session.sharedInstance().activeUser.UserID
        ]
        
        JSONReader.JsonAsyncRequest(urlString, data: data, httpMethod: .POST, onSuccess: { (json) -> () in
            
            for (index: String, matchJSON: JSON) in json {
                
                var match:User = User.createObjectFromJson(matchJSON)
                matches.append(match)
            }
            
            completion(users: matches)
            
        }, onFailure: { (error: NSErrorPointer) -> () in
            
            
        }) { () -> () in
            
            
        }
        
    }
}
