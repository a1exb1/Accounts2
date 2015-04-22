//
//  Transaction.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class Transaction: JSONObject {
   
    var user = User()
    var friend = User()
    var Amount: Double = 0
    var Description = ""
    
}
