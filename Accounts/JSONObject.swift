//
//  JSONObject.swift
//  Accounts
//
//  Created by Alex Bechmann on 08/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class JSONObject: NSObject {
    
    required override init() {}
    
    class func jsonURL(id:Int) -> String {
        return ""
    }
    
//    class func getObjectFromJsonAsync(id:Int, completion: (object:JSONObject?) -> () ) {
//
//        JSONReader.JsonAsyncRequest((self as AnyClass).jsonURL(id), data: nil, httpMethod: .GET) { (json:JSON) -> () in
//            
//            completion(object: self.createObjectFromJson(json))
//        }
//    }
//    
//    class func getObjectFromJsonAsync(url:String, completion: (object:JSONObject?) -> () ) {
//        
//        JSONReader.JsonAsyncRequest(url, data: nil, httpMethod: .GET) { (json:JSON) -> () in
//            
//            completion(object: self.createObjectFromJson(json))
//        }
//    }
    
    //<T : Person>() -> T
    
    class func getObjectFromJsonAsync< T : JSONObject >(id:Int, completion: (object:T) -> () ) {
        
        JSONReader.JsonAsyncRequest((self as AnyClass).jsonURL(id), data: nil, httpMethod: .GET, onSuccess: { (json) -> () in

            completion(object: self.createObjectFromJson(json))
            
        }, onFailure: { (error) -> () in
            
            
        }) { () -> () in
            
            
        }
        
    }
    
    class func getObjectFromJsonAsync< T : JSONObject >(url:String, completion: (object:T) -> () ) {
        
        JSONReader.JsonAsyncRequest(url, data: nil, httpMethod: .GET, onSuccess: { (json) -> () in
            
            completion(object: self.createObjectFromJson(json))
            
            }, onFailure: { (error) -> () in
                
                
            }) { () -> () in
                
                
        }
    }

    class func createObjectFromJson< T : JSONObject >(json:JSON) -> T {
        
        var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
        var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as! T
        rc.setExtraPropertiesFromJSON(json)
        return rc as! T
    }
    
    
    // With type
//    class func getObjectFromJsonAsync< T : JSONObject >(type: T.Type, id:Int, completion: (object:T) -> () ) {
//        
//        JSONReader.JsonAsyncRequest((self as AnyClass).jsonURL(id), data: nil, httpMethod: HttpMethod.GET, onSuccess: { (json:JSON) -> () in
//            
//            var obj:T = self.createObjectFromJson(json)
//            completion(object: obj)
//            
//        }, onFailure: nil, onFinished: nil)
//    }
//    
//    class func getObjectFromJsonAsync< T : JSONObject >(type: T.Type, url:String, completion: (object:T) -> () ) {
//        
//        JSONReader.JsonAsyncRequest(url, data: nil, httpMethod: httpMethod, onSuccess: { (json) -> () in
//            
//            var obj:T = self.createObjectFromJson(json)
//            completion(object: obj)
//            
//        }, onFailure: nil, onFinished: nil)
//        
//    }
//    
//    class func createObjectFromJson< T : JSONObject >(type: T.Type, json:JSON) -> T {
//        
//        var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
//        var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as! T
//        rc.setExtraPropertiesFromJSON(json)
//        return rc as! T
//    }
    
    
    
    
    
//    class func createObjectFromJson< T : JSONObject >(json:JSON, type: T.Type ) -> T? {
//        
//        var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
//        var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as! T
//        rc.setExtraPropertiesFromJSON(json)
//        return rc as? T
//    }
    
//    class func createObjectFromJson(json:JSON) -> JSONObject? {
//
//        
//        var mapper = DCKeyValueObjectMapping.mapperForClass(self.classForCoder())
//        var rc: JSONObject = mapper.parseDictionary(json.dictionaryObject) as! T
//        rc.setExtraPropertiesFromJSON(json)
//        return rc as? T
//    }
    
    
    func setExtraPropertiesFromJSON(json:JSON) {
        
    }
    
    func convertToJSONString() -> String {

        return self.JSONString()
    }
}
