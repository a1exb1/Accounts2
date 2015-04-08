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
    
    class func createObjectFromJsonAsync(id:Int, completion: (object:JSONObject?) -> () ) {

        JSONReader.JsonAsyncRequest((self as AnyClass).jsonURL(id), data: nil, httpMethod: .GET) { (json:JSON) -> () in
            
            var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
            var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as JSONObject
            completion(object: rc as JSONObject)
        }
    }
    
    class func createObjectFromJsonAsync(url:String, completion: (object:JSONObject?) -> () ) {
        
        JSONReader.JsonAsyncRequest(url, data: nil, httpMethod: .GET) { (json:JSON) -> () in
            
            var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
            var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as JSONObject
            completion(object: rc as JSONObject)
        }
    }
}
