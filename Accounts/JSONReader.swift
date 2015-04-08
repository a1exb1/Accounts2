//
//  JSONReader.swift
//  LessonManager_Dec_14
//
//  Created by Alex Bechmann on 24/12/2014.
//  Copyright (c) 2014 Alex Bechmann. All rights reserved.
//

import UIKit

//@objc protocol JsonDelegate{
//    optional func ReceivedJSON(requestString:String, responseData:NSData)
//    optional func ReceivedJSONNotification(requestString:String)
//}

enum RequestStatus: Int{
    case Failed = 0
    case Success = 1
}

enum HttpMethod: String{
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

extension String {
    func contains(find: String) -> Bool{
        if let temp = self.rangeOfString(find){
            return true
        }
        return false
    }
}

class JSONReader: NSObject {
    
    class func JsonAsyncRequest(urlString:String, data:Dictionary<String, AnyObject>?, httpMethod:HttpMethod, completionHandler:(response: JSON) -> ()){
        
        JsonAsyncRequest(urlString, data: data, httpMethod: httpMethod) { (response:NSData) -> () in
            let json = JSON(data: response)
            completionHandler(response: json)
        }
        
    }
    
    class func JsonAsyncRequest(urlString:String, data:Dictionary<String, AnyObject>?, httpMethod:HttpMethod, completionHandler:(response: NSData) -> ()){
        var rc:NSArray = NSArray()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var urlStr:String = urlString
        
        if httpMethod == .GET{
            urlStr = QueryStringFromDictionary(urlString, dict: data)
        }
        urlStr = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        var url = NSURL(string: urlStr)
        var request =  NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 16) //NSURLRequest(URL: url!)
        request.HTTPMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if httpMethod != .GET{
            if data != nil{
                var params = data as Dictionary<String, AnyObject>!
                var err: NSError?
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            var response: NSURLResponse?
            var error: NSErrorPointer = nil
            var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if data != nil{
                    
                    completionHandler(response: data!)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                else{
                    Tools.ShowAlertControllerOK("Data download failed"){ response in }
                }
                
            }
            
        })
        
    }
    
    class func QueryStringFromDictionary(urlString:String, dict:Dictionary<String, AnyObject>?) -> String{
        var rc:String = urlString
        if dict != nil{
            for (key,value) in dict!{
                var connector = rc.contains("?") ? "&": "?"
                rc += connector
                if value is String{
                    rc += key + "=" + (value as String)
                }
                if value is Int{
                    rc += key + "=" + String((value as Int))
                }
                
            }
        }
        return rc
    }
    
    class func DictionaryFromQueryString(queryString:String?) -> Dictionary<String, String>?{
        
        if queryString == nil{
            return nil
        }
        
        var dict = Dictionary<String, String>()
        var pairs:Array<AnyObject> = queryString!.componentsSeparatedByString("&")
        
        for pair in pairs {
            var elements:Array<AnyObject> = queryString!.componentsSeparatedByString("=")
            var key:String = elements[0] as String //.stringByReplacingPercentEscapesUsingEncoding(0)!
            var value:String = elements[1] as String //.stringByReplacingPercentEscapesUsingEncoding(0)!
            dict[key] = value
        }
        return dict;
    }
}
