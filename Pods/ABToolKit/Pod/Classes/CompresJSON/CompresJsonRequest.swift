//
//  CompresJsonRequest.swift
//  CompresJSON
//
//  Created by Alex Bechmann on 09/05/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class CompresJsonRequest: JsonRequest {
   
    override public class func create< T : JsonRequest >(urlString:String, parameters:Dictionary<String, AnyObject>?, method:Alamofire.Method) -> T {
        
        return CompresJsonRequest(urlString: urlString, parameters: parameters, method: method) as! T
    }
    
    internal override func exec() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if let params = self.parameters {
            
            var err: NSError?
            var json: String = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)!.toString()
            
            json = CompresJSON.encryptAndCompressAsNecessary(json)
            
            self.parameters = Dictionary<String, AnyObject>()
            self.parameters!["data"] = json
        }
        
        self.alamofireRequest = request(self.method, self.urlString, parameters: self.parameters, encoding: ParameterEncoding.URL)
            .response{ (request, response, data, error) in
                
                if let e = error {
                    
                    println(e.localizedDescription)
                    
                    var alert = self.alertControllerForError(e, completion: { (retry) -> () in
                        
                        if retry {
                            
                            self.cancel()
                            self.exec()
                        }
                    })
                    
                    self.failDownload(e, alert: alert)
                }
                    
                else{
                    let json = JSON(data: data! as! NSData)
                    
                    let encryptedJson = json["data"].stringValue
                    let unencryptedJson = CompresJSON.decryptAndDecompressAsNecessary(encryptedJson)
                    
                    if let dataFromString = unencryptedJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
                        
                        let unpackedJson = JSON(data: dataFromString)
                        
                        self.succeedDownload(unpackedJson)
                    }
                    else {
                        
                        println("got nil - retrying")
                        self.cancel()
                        self.exec()
                    }
                }
                
                self.finishDownload()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
}
