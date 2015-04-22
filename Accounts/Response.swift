//
//  Response.swift
//  Accounts
//
//  Created by Alex Bechmann on 11/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

enum ResponseStatus:Int {
    case Failed = 0
    case Success = 1
}

class Response: JSONObject {
   
    var Status:ResponseStatus = ResponseStatus.Failed
    var Message:String = ""
    
    override func setExtraPropertiesFromJSON(json: JSON) {
        self.Status = ResponseStatus(rawValue: json["Response"]["Status"].intValue)!
    }
}
