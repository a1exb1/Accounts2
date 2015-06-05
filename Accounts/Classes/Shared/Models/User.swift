//
//  User.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyJSON
import SwiftyUserDefaults

private let kActiveUserDefaultsKey = "activeUser"

class User: JSONObject {
    
    var UserID = 0
    var Username = ""
    var Friends: Array<User> = []
    var relationStatusToActiveUser: RelationStatus = RelationStatus.Undefined
    var transactions: Array<Transaction> = []
    
//    override func setExtraPropertiesFromJSON(json:JSON)  {
//        
//        self.relationStatusToActiveUser = RelationStatus(rawValue: json["relationStatus"].intValue)!
//    }
    
    override func registerClassesForJsonMapping() {
    
        registerClass(User.self, propertyKey: "Friends", jsonKey: "friends")
    }
    
    
    func getTransactions() -> JsonRequest? {
        
        return Transaction.webApiGetMultipleObjects(Transaction.self, completion: { (objects) -> () in
            
            self.transactions = objects
        })
    }
    
    
    
//    func getUnconfirmedInvites(completion:(invites:Array<Relation>) -> ()) {
//        
//        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "FriendInvitations")
//        var data: Dictionary<String, AnyObject> = [
//            "UserID" : self.UserID
//        ]
//    
//        JsonRequest.create(urlString, parameters: data, method: .POST).onDownloadSuccess { (json, request) -> () in
//            
//            let invites: Array<Relation> = Relation.convertJsonToMultipleObjects(Relation.self, json: json)
//            completion(invites: invites)
//        }
//        
//        Relation.webApiGetMultipleObjects(Relation.self, query: nil) { (objects) -> () in
//            
//            completion(invites: objects)
//        }
//    }
    
    func addFriend(relationUserID:Int, completion: () -> ()) {
        
//        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "AddFriend")
//        var data = [
//            "UserID": self.UserID,
//            "relationUserID" : relationUserID
//        ]
//        
//        JsonRequest.create(urlString, parameters: data, method: Method.POST).onDownloadSuccess { (json, request) -> () in
//            
//            completion()
//        }
    }
    
    func saveUserOnDevice() {

        Defaults[kActiveUserDefaultsKey] = kActiveUser
    }
    
    class func userSavedOnDevice() -> User? {
        
        return Defaults[kActiveUserDefaultsKey].object as? User
    }
    
//    func refreshFriendsList() -> JsonRequest {
//        
////        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "GetFriends")
////        var data = [ "UserID" : self.UserID ]
////        
////        return JsonRequest.create(urlString, parameters: data, method: .POST).onDownloadSuccess({ (json, request) -> () in
////            
////            self.Friends = User.convertJsonToMultipleObjects(json)
////            request.succeedContext()
////        })
//    }
    
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
        
//        var urlString = AppTools.WebMvcController(kMVCControllerName, action: "ActiveUsersMatching")
//        var data:Dictionary<String, AnyObject> = [
//            "searchText" : string,
//            "UserID" : kActiveUser.UserID
//        ]
//        
//        
//        
//        JsonRequest.create(urlString, parameters: data, method: .POST).onDownloadSuccess { (json, request) -> () in
//            
//            let matches: Array<User> = User.convertJsonToMultipleObjects(json)
//            completion(users: matches)
//        }
    }
}
