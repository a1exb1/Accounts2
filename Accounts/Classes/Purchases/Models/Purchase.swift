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
    
    var billSplitDictionary = Dictionary<User, Double>()
    
    func save() -> JsonRequest? {
        
        if PurchaseID > 0 {
            
        }
        else{
            
            
        }
        
        //TODO: INSERT ONLY ATM
        var urlString = "" // AppTools.WebMvcController("Transaction", action: "AddPurchase") + "?Amount=\(self.Amount)&UserID=\(kActiveUser.UserID)"
        
        for friend in self.friends {
            
            urlString = urlString + "&relationUserIDs=\(friend.UserID)&relationUserAmounts=\(self.billSplitDictionary[friend]!)"
        }
        
//        return JsonRequest.create(urlString, parameters: nil, method: .GET).onDownloadSuccess({ (json, request) -> () in
//            
//            var response:Response = Response.createObjectFromJson(json["Response"])
//            
//            if response.Status == ResponseStatus.Success {
//                
//                request.succeedContext()
//            }
//            else{
//                
//                Tools.ShowAlertControllerOK(response.Message, completionHandler: { (response) -> () in
//                })
//                
//                request.failContext()
//            }
//        })
        return nil // temp
    }
    
    func splitTheBill() {
        
        self.billSplitDictionary = Dictionary<User, Double>()
        var amount:Double = self.Amount / Double(self.friends.count + 1)
        
        for friend in self.friends {
            
            self.billSplitDictionary[friend] = amount
        }
    }
}
