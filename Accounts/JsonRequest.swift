//
//  Test.swift
//  jsonreaderoptimizations
//
//  Created by Alex Bechmann on 22/04/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit


class JsonRequest {
    
    var urlString = ""
    var method: Method = .GET
    var parameters: Dictionary<String, AnyObject>?
    
    private var succeedDownloadClosures: [(json: JSON, request: JsonRequest) -> ()] = []
    private var succeedContextClosures: [() -> ()] = []
    
    private var failDownloadClosures: [(error: NSError, alert: UIAlertController) -> ()] = []
    private var failContextClosures: [() -> ()] = []
    
    private var finishDownloadClosures: [() -> ()] = []
    
    class func create(urlString:String, parameters:Dictionary<String, AnyObject>?, method:Method) -> JsonRequest {
        
        return JsonRequest(urlString: urlString, parameters: parameters, method: method)
        
    }
    
    private convenience init(urlString:String, parameters:Dictionary<String, AnyObject>?, method:Method) {
        self.init()
        
        self.urlString = urlString
        self.parameters = parameters
        self.method = method
        
        go()
    }
    
    func onDownloadSuccess(success: (json: JSON, request: JsonRequest) -> ()) -> JsonRequest {
        self.succeedDownloadClosures.append(success)
        return self
    }
    
    func onContextSuccess(success: () -> ()) -> JsonRequest {
        self.succeedContextClosures.append(success)
        return self
    }
    
    
    func onDownloadFailure(failure: (error: NSError, alert: UIAlertController) -> ()) -> JsonRequest {
        self.failDownloadClosures.append(failure)
        return self
    }
    
    func onContextFailure(failure: () -> ()) -> JsonRequest {
        self.failContextClosures.append(failure)
        return self
    }
    
    
    func onDownloadFinished(finished: () -> ()) -> JsonRequest {
        self.finishDownloadClosures.append(finished)
        return self
    }
    
    
    
    func succeedDownload(json: JSON) {
        for closure in self.succeedDownloadClosures {
            closure(json: json, request: self)
        }
    }
    
    func succeedContext() {
        for closure in self.succeedContextClosures {
            closure()
        }
    }
    
    
    func failDownload(error: NSError, alert: UIAlertController) {
        for closure in self.failDownloadClosures {
            closure(error: error, alert: alert)
        }
    }
    
    func failContext() {
        for closure in self.failContextClosures {
            closure()
        }
    }
    
    
    func finishDownload() {
        for closure in self.finishDownloadClosures {
            closure()
        }
    }
    
    
    private func go() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        request(method, urlString, parameters: parameters, encoding: ParameterEncoding.URL)
            .response{ (request, response, data, error) in
                
                if let e = error {
                    
                    var alert = self.alertControllerForError(e, completion: { (retry) -> () in
                        
                        if retry{
                            self.go()
                        }
                    })
                    
                    self.failDownload(e, alert: alert)
                }
                    
                else{
                    
                    let json = JSON(data: data! as! NSData)
                    self.succeedDownload(json)
                }
                
                self.finishDownload()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    private func alertControllerForError(error: NSError, completion: (retry: Bool) -> ()) -> UIAlertController {
        
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
            completion(retry: false)
        }
        alertController.addAction(cancelAction)
        
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default) { (action) in
            completion(retry: true)
        }
        alertController.addAction(retryAction)
        
        return alertController
    }

}

extension UIAlertController {
    
    func show() {
        
        topMostController().presentViewController(self, animated: true) { () -> Void in
        }
    }
    
    private func topMostController() -> UIViewController
    {
        var topController = UIApplication.sharedApplication().keyWindow!.rootViewController;
        while ((topController!.presentedViewController) != nil) {
            topController = topController!.presentedViewController;
        }
        return topController!
    }
}

