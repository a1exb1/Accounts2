//
//  Settings.swift
//  Accounts
//
//  Created by Alex Bechmann on 11/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

let kCurrencySettingKey = "Currency"

let kCompresJSONSettingsKeys = (compresJSONEncryptKey: "compresJSONEncrypt", compresJSONCompressKey: "compresJSONCompress", acceptEncodingKey: "alamofireAcceptEncoding", httpsEnabledKey: "HTTPSEnabled")

private let kCurrencySettingLocaleDictionary: Dictionary<String, String> = [
    "GBP": "en_GB",
    "DKK": "da_DK"
]

class Settings: NSObject {
    
    class func getCurrencyLocaleWithIdentifier() -> (locale: NSLocale, identifier: String) {
        
        if !Defaults.hasKey(kCurrencySettingKey) {
            
            Defaults[kCurrencySettingKey] = "GBP"
        }
        setDefaultValueIfNotExistsForKey(kCurrencySettingKey, value: "GBP")
        
        let currencyIdentifier: String = Defaults[kCurrencySettingKey].string!
        
        return (locale: NSLocale(localeIdentifier: kCurrencySettingLocaleDictionary[currencyIdentifier]!), identifier: currencyIdentifier)

    }
    
    class func setLocaleByIdentifier(identifier: String) {
        
        Defaults[kCurrencySettingKey] = identifier
    }
    
    class func setDefaultValueIfNotExistsForKey(key: String, value: AnyObject) {
        
        if !Defaults.hasKey(key) {
            
            Defaults[key] = value
        }
    }
    
    //MARK: - CompresJSON
    
    class func getCompresJSONSettings() -> (compresJSONEncrypt: Bool, compresJSONCompress: Bool, acceptEncoding: String, httpsEnabled: Bool) {
        
        let keys = kCompresJSONSettingsKeys
        
        setDefaultValueIfNotExistsForKey(keys.compresJSONEncryptKey, value: false)
        setDefaultValueIfNotExistsForKey(keys.compresJSONCompressKey, value: false)
        setDefaultValueIfNotExistsForKey(keys.acceptEncodingKey, value: "deflate")
        setDefaultValueIfNotExistsForKey(keys.httpsEnabledKey, value: false)
        
        return (compresJSONEncrypt: Defaults[keys.compresJSONEncryptKey].bool!,  compresJSONCompress: Defaults[keys.compresJSONCompressKey].bool!, acceptEncoding: Defaults[keys.acceptEncodingKey].string!, httpsEnabled: Defaults[keys.httpsEnabledKey].bool!)
    }
    
    class func setAcceptEncoding(value: String) {
        
        let keys = kCompresJSONSettingsKeys
        
        Defaults[keys.acceptEncodingKey] = value
        
        AppDelegate.setAlamofireHeaders()
    }
    
    class func setCompresJSONEncryption(value: Bool) {
        
        let keys = kCompresJSONSettingsKeys
        
        Defaults[keys.compresJSONEncryptKey] = value
        
        AppDelegate.setAlamofireHeaders()
    }
    
    class func setCompresJSONCompression(value: Bool) {
        
        let keys = kCompresJSONSettingsKeys
        
        Defaults[keys.compresJSONCompressKey] = value
        
        AppDelegate.setAlamofireHeaders()
    }
    
    class func setHTTPSEnabled(value: Bool) {
        
        let keys = kCompresJSONSettingsKeys
        
        Defaults[keys.httpsEnabledKey] = value
        
        AppDelegate.setAlamofireHeaders()
    }
}
