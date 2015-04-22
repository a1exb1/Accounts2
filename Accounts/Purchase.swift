//
//  Purchase.swift
//  Accounts
//
//  Created by Alex Bechmann on 21/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class Purchase: JSONObject {
   
    var PurchaseID: Int = 0
    var friends: [User] = []
    var Amount: Double = 0
    var Description = ""
    
    var billSplitDictionary = Dictionary<User, Double>()
    
    func save(onSuccess:(() -> ())?, onFailure:(() -> ())?, onFinished:(() -> ())?) {
        
        if PurchaseID > 0 {
            
        }
        else{
            
            var urlString = AppTools.WebMvcController("Transaction", action: "AddPurchase") + "?Amount=\(self.Amount)&UserID=\(Session.sharedInstance().activeUser.UserID)"
            
            for friend in self.friends {
                
                urlString = urlString + "&relationUserIDs=\(friend.UserID)&relationUserAmounts=\(self.billSplitDictionary[friend]!)"
            }
            
            JSONReader.JsonAsyncRequest(urlString, data: nil, httpMethod: .GET, onSuccess: { (json) -> () in
                
                var response:Response = Response.createObjectFromJson(json)
                
                if response.Status == ResponseStatus.Success {
                    
                    onSuccess?()
                }
                else{
                    
                    Tools.ShowAlertControllerOK(response.Message, completionHandler: { (response) -> () in
                    })
                    
                    onFailure?()
                }
                
            }, onFailure: { (error) -> () in
                
                onFailure?()
                
            }, onFinished: { () -> () in
                
                onFinished?()
            })
        }
    }
    
    func splitTheBill() {
        
        self.billSplitDictionary = Dictionary<User, Double>()
        var amount:Double = self.Amount / Double(self.friends.count + 1)
        
        for friend in self.friends {
            
            self.billSplitDictionary[friend] = amount
        }
        
        //self.billSplitDictionary[self] = amount
    }
}
