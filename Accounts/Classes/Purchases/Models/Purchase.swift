//
//  Purchase.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit
import ABToolKit

class Purchase: JSONObject {
   
    var PurchaseID: Int = 0
    var friends: [User] = []
    var Amount: Double = 0
    var Description = ""
    var UserID = kActiveUser.UserID
    
    var billSplitDictionary = Dictionary<User, Double>()
    
    func save() -> JsonRequest? {
        
        if !modelIsValid() {
            
            return nil
        }
        
        var urlString = ""
        
        if PurchaseID > 0 {
            
            println("update not supported yet (or ever)")
            return nil
        }
        else{
            
            urlString = "\(Purchase.webApiUrls().insertUrl()!)/"
        }
        
        splitTheBill()
        
        var c = 0
        for friend in self.friends {
            
            let prefix = c == 0 ? "?" : "&"
            
            urlString = urlString + "\(prefix)RelationUserIDs=\(friend.UserID)&RelationUserAmounts=\(self.billSplitDictionary[friend]!)"
            
            c++
        }
    
        let params = convertToDictionary(["UserID", "Amount"], includeNestedProperties: false)

        return JsonRequest.create(urlString, parameters: params, method: .POST).onDownloadSuccessWithRequestInfo({ (json, request, httpUrlRequest, httpUrlResponse) -> () in

            if httpUrlResponse?.statusCode == 200 || httpUrlResponse?.statusCode == 201 {
                
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
    
    func modelIsValid() -> Bool{
        
        var modelIsValid = true
        var errorMessage = ""
        
        
        if !(Amount > 0) {
         
            errorMessage = "Amount is 0"
        }
        
        if friends.count == 0 {
            
            errorMessage == "You havnt split this with anyone!"
        }
        
        if errorMessage.characterCount() > 0 {
            
            UIAlertView(title: "Purchase not saved!", message: errorMessage, delegate: nil, cancelButtonTitle: "OK").show()
            return false
        }
        
        return true
    }
}
