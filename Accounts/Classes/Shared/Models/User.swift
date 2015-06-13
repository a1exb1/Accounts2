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

private let kActiveUserDefaultsKey = "activeUser"

class User: CompresJSONObject {
    
    var UserID = 0
    var Username = ""
    var Password = ""
    var friends: Array<User> = []
    
    //friend
    //var relationStatusToActiveUser: RelationStatus = RelationStatus.Undefined
    var DifferenceBetweenActiveUser: Double = 0
    
    var localeDifferenceBetweenActiveUser: Double {
        
        get {
            
            let currencyIdentifier = Settings.getCurrencyLocaleWithIdentifier().identifier
            
            if currencyIdentifier == "DKK" {
                
                return self.DifferenceBetweenActiveUser * 10
            }
            else {
                
                return self.DifferenceBetweenActiveUser
            }
        }
        
        set(newValue) {
            
            let currencyIdentifier = Settings.getCurrencyLocaleWithIdentifier().identifier
            
            if currencyIdentifier == "DKK" {
                
                self.DifferenceBetweenActiveUser = newValue / 10
            }
            else {
                
                self.DifferenceBetweenActiveUser = newValue
            }
        }
    }
    
    //var transactions: Array<Transaction> = []
    
//    override func setExtraPropertiesFromJSON(json:JSON)  {
//        
//        self.relationStatusToActiveUser = RelationStatus(rawValue: json["relationStatus"].intValue)!
//    }
    
    override func registerClassesForJsonMapping() {
    
        registerProperty("DifferenceBetweenActiveUser", withJsonKey: "Difference")
        registerClass(User.self, forKey: "friends")
    }
    
    
    class func login(username: String, password: String) -> CompresJsonRequest {
        
        return CompresJsonRequest.create("http://alex.bechmann.co.uk/iou/api/Users/Login/?Username=\(username)&Password=\(password)", parameters: nil, method: .POST).onDownloadSuccessWithRequestInfo { (json, request, httpRequest, httpResponse) -> () in
            
            if httpResponse?.statusCode == 200 {
                
                var user: User = User.createObjectFromJson(json)
                User.saveUserOnDevice(user as User?)
                kActiveUser = user
                
                request.succeedContext()
            }
            else {
                
                request.failContext()
            }
        } as! CompresJsonRequest
    }
    
    func logout() {
        
        User.saveUserOnDevice(nil)
    }

    
//    func getTransactionsLog(completion: (transactions: Array<Transaction>) -> ()) -> JsonRequest? {
//        
//        let url = "\(User.webApiUrls().getUrl(UserID))/Transactions"
//        
//        return JsonRequest.create(url, parameters: ["userID" : UserID], method: .GET).onDownloadSuccess({ (json, request) -> () in
//            
//            completion(transactions: Transaction.convertJsonToMultipleObjects(Transaction.self, json: json))
//        })
//    }
    
    func getFriends() -> CompresJsonRequest {
        
        let s: String = User.webApiUrls().getUrl(UserID)!
        
        let url = "\(s)/Friends"

        return CompresJsonRequest.create(url, parameters: nil, method: .GET).onDownloadSuccess({ (json, request) -> () in
            
            self.friends = User.convertJsonToMultipleObjects(User.self, json: json)
        }) as! CompresJsonRequest
    }
    
    func getTransactionsBetweenFriend(friend: User, completion: (transactions: Array<Transaction>) -> ()) -> CompresJsonRequest {
        
        let url = "\(WebApiDefaults.sharedInstance().baseUrl!)/Users/TransactionsBetween/\(UserID)/and/\(friend.UserID)?$orderby=TransactionDate%20desc" // not doing it for purchases
        
        let request = CompresJsonRequest.create(url, parameters: nil, method: .GET).onDownloadSuccess({ (json, request) -> () in
            
            let transactions:Array<Transaction> = Transaction.convertJsonToMultipleObjects(Transaction.self, json: json)
            completion(transactions: transactions)
        }) as! CompresJsonRequest
        
        request.alamofireRequest?.responseString(encoding: nil, completionHandler: { (request, response, str, error) -> Void in
        
        let contentLength: AnyObject = response!.allHeaderFields["Content-Length"]!
        var length: CGFloat = CGFloat("\(contentLength)".toInt()!) / 1024
        let l = NSString(format: "%.02f", length)
        println("Content-Length: \(l)kb")
            
            
        
        })
        
        return request
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

        User.saveUserOnDevice(self as User?)
    }
    
    class func saveUserOnDevice(user: User?) {
        
        if let u = user {
            
            var objectData: NSData = NSKeyedArchiver.archivedDataWithRootObject(u)
            NSUserDefaults.standardUserDefaults().setObject(objectData, forKey: kActiveUserDefaultsKey)
        }
        else {
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kActiveUserDefaultsKey)
        }
        
    }
    
    class func userSavedOnDevice() -> User? {
        
        if let objectData:NSData = NSUserDefaults.standardUserDefaults().objectForKey(kActiveUserDefaultsKey) as? NSData {
            
            let user: User = (NSKeyedUnarchiver.unarchiveObjectWithData(objectData) as? User)!
            return user
        }
        
        return nil
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        self.UserID = decoder.decodeObjectForKey("UserID") as! Int
        self.Username = decoder.decodeObjectForKey("Username") as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject(UserID, forKey: "UserID")
        coder.encodeObject(Username, forKey: "Username")
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
    
//    func confirmedFriends() -> Array<User> {
//        
//        var rc = Array<User>()
//        
//        for friend in self.Friends {
//            
//            if friend.relationStatusToActiveUser == .Confirmed {
//                rc.append(friend)
//            }
//        }
//        
//        return rc
//    }
//    
//    func pendingFriends() -> Array<User> {
//        
//        var rc = Array<User>()
//        
//        for friend in self.Friends {
//            
//            if friend.relationStatusToActiveUser == .Pending {
//                rc.append(friend)
//            }
//        }
//        
//        return rc
//    }

    
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
    
    override func webApiRestObjectID() -> Int? {
        
        return UserID
    }
    
    class func userListExcludingID(id: Int?) -> Array<User> {
        
        var usersToChooseFrom = [User]()
        var allUsersInContext = [User]()
        
        for friend in kActiveUser.friends {
            
            allUsersInContext.append(friend)
        }
        allUsersInContext.append(kActiveUser)
        
        for user in allUsersInContext {
            
            if let excludeID = id {
                
                if user.UserID != excludeID{
                    
                    usersToChooseFrom.append(user)
                }
            }
            else {
                
                usersToChooseFrom.append(user)
            }
        }
        
        return usersToChooseFrom
    }
}
