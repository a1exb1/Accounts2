//
//  CompresJSON.swift
//  EncryptionTests3
//
//  Created by Alex Bechmann on 08/05/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit

let kCompresJSONSharedInstance = CompresJSON()

public class CompresJSON: NSObject {
   
    public class func sharedInstance() -> CompresJSON {
        
        return kCompresJSONSharedInstance
    }
    
    public var settings: CompresJSONSettings = CompresJSONSettings()
    
    public class func encryptAndCompressAsNecessary(str: String) -> String {
        
        CompresJSON.printErrorIfEncryptionKeyIsNotSet()
        
        var rc = str
        
        if CompresJSON.sharedInstance().settings.shouldCompress {
            
            rc = rc.compress()
        }
        
        if CompresJSON.sharedInstance().settings.shouldEncrypt {
            
            rc = Encryptor.encrypt(rc, key: CompresJSON.sharedInstance().settings.encryptionKey)
        }
        
        return rc
    }

    public class func decryptAndDecompressAsNecessary(str: String) -> String {
            
        CompresJSON.printErrorIfEncryptionKeyIsNotSet()

        var rc = str
        
        if CompresJSON.sharedInstance().settings.shouldEncrypt {
            
            rc = Encryptor.decrypt(rc, key: CompresJSON.sharedInstance().settings.encryptionKey)
        }
        
        if CompresJSON.sharedInstance().settings.shouldCompress {
            
            rc = rc.decompress()
        }

        return rc
    }
    
    public class func printErrorIfEncryptionKeyIsNotSet() {
    
        if CompresJSON.sharedInstance().settings.encryptionKey == "" {
        
            println("Encryption key not set: add to appdelegate: CompresJSON.sharedInstance().settings.encryptionKey = xxxx")
        }
    }
    
}
