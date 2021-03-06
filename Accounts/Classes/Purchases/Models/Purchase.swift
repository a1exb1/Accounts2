//
//  Purchase.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit
import ABToolKit
import Alamofire
import SwiftyJSON

class Purchase: JSONObject {
   
    var PurchaseID: Int = 0
    var friends: [User] = []
    var Amount: Double = 0
    
    var localeAmount: Double {
        
        get {
            
            let currencyIdentifier = Settings.getCurrencyLocaleWithIdentifier().identifier
            
            if currencyIdentifier == "DKK" {
                
                return self.Amount * 10
            }
            else {
                
                return self.Amount
            }
        }
        
        set(newValue) {
            
            let currencyIdentifier = Settings.getCurrencyLocaleWithIdentifier().identifier
            
            if currencyIdentifier == "DKK" {
                
                self.Amount = newValue / 10
            }
            else {
                
                self.Amount = newValue
            }
        }
    }
    
    var Description = ""
    var user = User()
    var billSplitDictionary = Dictionary<User, Double>()
    var DatePurchased:NSDate = NSDate()
    var DateEntered: NSDate = NSDate()
    //var transactions = Array<Transaction>()
    
    override func registerClassesForJsonMapping() {
        
        registerDate("DatePurchased")
        registerDate("DateEntered")
        registerClass(Transaction.self, propertyKey: "transactions", jsonKey: "Transactions")
        //registerClass(User.self, propertyKey: "user", jsonKey: "User")
        //registerClass(User.self, propertyKey: "friends", jsonKey: "RelationUsers")
    }
    
    override func setExtraPropertiesFromJSON(json: JSON) {
        
        user.UserID = json["UserID"].intValue
        
        friends = User.convertJsonToMultipleObjects(User.self, json: json["RelationUsers"])
        
        for friend in friends {
            
            if friend.UserID == user.UserID {
                
                let index = find(friends, friend)!
                friends.removeAtIndex(index)
            }
        }
        
        user = User.createObjectFromJson(json["User"])
    }
    
    func save() -> JsonRequest? {
        
        if !modelIsValid() {
            
            return nil
        }

        var urlString = ""
        let httpMethod: Alamofire.Method = PurchaseID == 0 ? .POST : .PUT
        
        if PurchaseID > 0 {
            
            urlString = Purchase.webApiUrls().updateUrl(PurchaseID)!
        }
        else {
            
            urlString = Purchase.webApiUrls().insertUrl()!
        }
        
        splitTheBill()
        
        var c = 0
        for friend in self.friends {
            
            let prefix = c == 0 ? "?" : "&"
            urlString = urlString + "\(prefix)RelationUserIDs=\(friend.UserID)&RelationUserAmounts=\(self.billSplitDictionary[friend]!)"
            c++
        }
    
        var params = convertToDictionary(["Description", "Amount", "PurchaseID"], includeNestedProperties: false)
        params["UserID"] = user.UserID
        params["DateEntered"] = DateEntered.toString(JSONMappingDefaults.sharedInstance().webApiSendDateFormat)
        params["DatePurchased"] = DatePurchased.toString(JSONMappingDefaults.sharedInstance().webApiSendDateFormat)
        
        return JsonRequest.create(urlString, parameters: params, method: httpMethod).onDownloadSuccessWithRequestInfo({ (json, request, httpUrlRequest, httpUrlResponse) -> () in
            println(httpUrlResponse!.statusCode)
            if httpUrlResponse?.statusCode == 200 || httpUrlResponse?.statusCode == 201 || httpUrlResponse?.statusCode == 204 {
                
                request.succeedContext()
            }
            else {
                
                request.failContext()
            }
            
        })
    }
    
    func splitTheBill() {
        
        self.billSplitDictionary = Dictionary<User, Double>()
        var amount:Double = self.Amount / Double(self.friends.count + 1)
        
        for friend in self.friends {
            
            self.billSplitDictionary[friend] = amount
        }
    }
    
    override func webApiRestObjectID() -> Int? {
        
        return PurchaseID
    }
    
    override func modelIsValid() -> Bool {

        var errors:Array<String> = []
        
        if Amount == 0 {
         
            errors.append("Amount is 0")
        }
        
        if friends.count == 0 {
            
            errors.append("You havnt split this with anyone!")
        }
        
        if Description == "" {
            
            errors.append("Description is empty")
        }
        
        var c = 1
        var errorMessageString = ""
        
        for error in errors {
            
            let suffix = c == errors.count ? "" : ", "
            errorMessageString += "\(error)\(suffix)"
            c++
        }
        
        if errors.count > 0 {
            
            //UIAlertView(title: "Purchase not saved!", message: errorMessageString, delegate: nil, cancelButtonTitle: "OK").show()
        }
        
        return errors.count > 0 ? false : true
    }
}
