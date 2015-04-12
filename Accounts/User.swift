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
            
            var friend:User = User.createObjectFromJson(friendJSON)! as User
            self.Friends.append(friend)
        }
    }
    
    func getUnconfirmedInvites(completion:(invites:Array<Relation>) -> ()) {
        
        var data: Dictionary<String, AnyObject> = [
            "UserID" : self.UserID
        ]
        
        JSONReader.JsonAsyncRequest(AppTools.WebMvcController(kMVCControllerName, action: "FriendInvitations"), data: data, httpMethod: .POST) { (response:JSON) -> () in

            var relations = Array<Relation>()
            
            for (index: String, relationJSON: JSON) in response {
                
                var relation:Relation = Relation.createObjectFromJson(relationJSON)! as Relation
                relations.append(relation)
            }
            
            completion(invites: relations)
        }
    }
    
    func addFriend(relationUserID:Int, completion: () -> ()) {
        
        var data = [
            "UserID": self.UserID,
            "relationUserID" : relationUserID
        ]
        
        JSONReader.JsonAsyncRequest(AppTools.WebMvcController(kMVCControllerName, action: "AddFriend"), data: data, httpMethod: .POST) { (response: JSON) -> () in
            
            completion()
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
    
    func refreshFriendsList(completion:() -> ()) {
        
        JSONReader.JsonAsyncRequest(AppTools.WebMvcController(kMVCControllerName, action: "GetFriends"), data: [ "UserID" : self.UserID ], httpMethod: .POST) { (response:JSON) -> () in
            
            self.setFriendsFromJSON(response)
            completion()
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
    
    class func activeUsersContaining(string: String, completion:(users:Array<User>) -> ()) {
        
        var matches = Array<User>()
        
        var data:Dictionary<String, AnyObject> = [
            "searchText" : string,
            "UserID" : Session.sharedInstance().activeUser.UserID
        ]
        
        JSONReader.JsonAsyncRequest(AppTools.WebMvcController(kMVCControllerName, action: "ActiveUsersMatching"), data: data, httpMethod: .POST) { (response:JSON) -> () in
            
            for (index: String, matchJSON: JSON) in response {
                
                var match:User = User.createObjectFromJson(matchJSON)! as User
                matches.append(match)
            }

            completion(users: matches)
        }
        
    }
}
