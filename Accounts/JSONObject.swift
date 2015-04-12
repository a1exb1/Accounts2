//
//  JSONObject.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class JSONObject: NSObject {
    
    class func jsonURL(id:Int) -> String {
        return ""
    }
    
    class func getObjectFromJsonAsync(id:Int, completion: (object:JSONObject?) -> () ) {

        JSONReader.JsonAsyncRequest((self as AnyClass).jsonURL(id), data: nil, httpMethod: .GET) { (json:JSON) -> () in
            
            completion(object: self.createObjectFromJson(json))
        }
    }
    
    class func getObjectFromJsonAsync(url:String, completion: (object:JSONObject?) -> () ) {
        
        JSONReader.JsonAsyncRequest(url, data: nil, httpMethod: .GET) { (json:JSON) -> () in
            
            completion(object: self.createObjectFromJson(json))
        }
    }
    
    class func createObjectFromJson(json:JSON) -> JSONObject? {
        
        var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
        var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as JSONObject
        rc.setExtraPropertiesFromJSON(json)
        return rc
    }
    
    
    func setExtraPropertiesFromJSON(json:JSON) {
        
    }
    
    func convertToJSONString() -> String {

        return self.JSONString()
    }
}
