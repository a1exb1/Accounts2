//
//  AppDelegate.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyUserDefaults
import Alamofire

var kActiveUser = User()

let kViewBackgroundColor = UIColor.whiteColor()
let kViewBackgroundGradientTop =  UIColor(hex: "00AEE5")
let kViewBackgroundGradientBottom =  UIColor(hex: "00BF6A")

let kTableViewBackgroundColor = UIColor.clearColor()

let kTableViewCellBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.55)
let kTableViewCellTextColor = UIColor.whiteColor()
let kTableViewCellDetailTextColor = UIColor.whiteColor()
let kTableViewCellSeperatorStyle = UITableViewCellSeparatorStyle.SingleLine
let kTableViewCellSeperatorColor = UIColor.clearColor()
let kTableViewCellHeight: CGFloat = 50
let kTableViewCellTintColor = UIColor.whiteColor()

let kNavigationBarPositiveActionColor = kNavigationBarTintColor
let kNavigationBarTintColor = UIColor(hex: "00AEE5")
let kNavigationBarBarTintColor:UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.85)
let kNavigationBarTitleColor = UIColor.blackColor()
let kNavigationBarStyle = UIBarStyle.Default

let kFormDeleteButtonTextColor = AccountColor.negativeColor()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let settings = CompresJSON.sharedInstance().settings
        
        settings.encryptionKey = "7e4bac048ef766e83f0ec8c079e1f90c2eb690a9"
        settings.shouldCompress = false
        settings.shouldEncrypt = false
        //settings.encryptUrlComponents = true
        
        Session.sharedSession().domain = "http://alex.bechmann.co.uk/iou"
        WebApiDefaults.sharedInstance().baseUrl = "\(Session.sharedSession().domain)/api"
        
        JSONMappingDefaults.sharedInstance().webApiSendDateFormat = DateFormat.ISO8601.rawValue
        JSONMappingDefaults.sharedInstance().dateFormat = DateFormat.ISO8601.rawValue
        
        //ALAMOFIRE HEADERS
        AppDelegate.setAlamofireHeaders()
        
        setupAppearances()
        
        if let user = User.userSavedOnDevice() {
            
            kActiveUser = user
        }
        else {
            
            setWindowToLogin()
        }
        
        return true
    }
    
    func setupAppearances() {
        
        UINavigationBar.appearance().tintColor = kNavigationBarTintColor
        UINavigationBar.appearance().barTintColor = kNavigationBarBarTintColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(kNavigationBarBarTintColor, size: CGSize(width: 10, height: 10)), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().barStyle = kNavigationBarStyle
        
        UITableViewCell.appearance().backgroundColor = kTableViewCellBackgroundColor
        UITableViewCell.appearance().textLabel?.textColor = kTableViewCellTextColor
        UITableViewCell.appearance().tintColor = kTableViewCellTintColor
        
        UITableView.appearance().separatorStyle = kTableViewCellSeperatorStyle
        UITableView.appearance().separatorColor = kTableViewCellSeperatorColor
        UITableView.appearance().backgroundColor = kTableViewBackgroundColor
        
        FormViewTextFieldCell.appearance().textLabel?.textColor = UIColor.yellowColor()
    }
    
    class func setAlamofireHeaders() {
        
        var compresJSONSettings = Settings.getCompresJSONSettings()
        
        CompresJSON.sharedInstance().settings.shouldEncrypt = compresJSONSettings.compresJSONEncrypt
        CompresJSON.sharedInstance().settings.shouldCompress = compresJSONSettings.compresJSONCompress
        
        let s = compresJSONSettings.httpsEnabled ? "s" : ""
        
        Session.sharedSession().domain = "http\(s)://alex.bechmann.co.uk/iou"
        WebApiDefaults.sharedInstance().baseUrl = "\(Session.sharedSession().domain)/api"
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders =
        [
            "CompresJSON-Encrypt": "\(compresJSONSettings.compresJSONEncrypt)",
            "CompresJSON-Compress": "\(compresJSONSettings.compresJSONCompress)",
            "Accept-Encoding1": compresJSONSettings.acceptEncoding,
            "Accept-Encoding": compresJSONSettings.acceptEncoding
        ]
    }
    
    private func setWindowToLogin() {
        
        let bounds: CGRect = UIScreen.mainScreen().bounds
        window = UIWindow(frame: bounds)
        window?.rootViewController = UIStoryboard.initialViewControllerFromStoryboardNamed("Login")
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

