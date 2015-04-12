//
//  Relation.swift
//  Accounts
//
//  Created by Alex Bechmann on 12/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class Relation: JSONObject {
   
    var RelationID:Int = 0
    var user = User()
    var relationUser = User()

    override func setExtraPropertiesFromJSON(json: JSON) {

        self.user = User.createObjectFromJson(json["User"]) as User!
    }
    
}
