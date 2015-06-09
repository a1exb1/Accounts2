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
    var Description = ""
    var user = User()
    var billSplitDictionary = Dictionary<User, Double>()
    var DatePurchased:NSDate = NSDate()
    
    override func registerClassesForJsonMapping() {
        
        registerDate("DatePurchased")
        
    }
    
    override func setExtraPropertiesFromJSON(json: JSON) {
        
        user.UserID = json["UserID"].intValue
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
        
        
        user = kActiveUser
        splitTheBill()
        
        var c = 0
        for friend in self.friends {
            
            let prefix = c == 0 ? "?" : "&"
            urlString = urlString + "\(prefix)RelationUserIDs=\(friend.UserID)&RelationUserAmounts=\(self.billSplitDictionary[friend]!)"
            c++
        }
    
        var params = convertToDictionary(["Amount"], includeNestedProperties: false)
        params["UserID"] = user.UserID
        
        println(urlString)
        println(params)
        return nil
        
        return JsonRequest.create(urlString, parameters: params, method: httpMethod).onDownloadSuccessWithRequestInfo({ (json, request, httpUrlRequest, httpUrlResponse) -> () in

            if httpUrlResponse?.statusCode == 200 || httpUrlResponse?.statusCode == 201 || httpUrlResponse?.statusCode == 204 {
                
                request.succeedContext()
            }
            else {
                
                request.failContext()
            }
            
        }).onDownloadFailure( { (error, alert) in
        
            alert.show()
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
