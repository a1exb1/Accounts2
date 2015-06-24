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
let kViewBackgroundGradientTop =  AccountColor.blueColor()
let kViewBackgroundGradientBottom =  AccountColor.greenColor()

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
let kNavigationBarBarTintColor:UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
let kNavigationBarTitleColor = UIColor.blackColor()
let kNavigationBarStyle = UIBarStyle.Default

let kFormDeleteButtonTextColor = AccountColor.negativeColor()

let kTableViewMaxWidth:CGFloat = 490
let kTableViewCellIpadCornerRadiusSize = CGSize(width: 10, height: 10)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        let settings = CompresJSON.sharedInstance().settings
//        
//        settings.encryptionKey = "7e4bac048ef766e83f0ec8c079e1f90c2eb690a9"
//        settings.shouldCompress = false
//        settings.shouldEncrypt = false
        
        Session.sharedSession().domain = "http://alex.bechmann.co.uk/iou"
        WebApiDefaults.sharedInstance().baseUrl = "\(Session.sharedSession().domain)/api"
        
        JSONMappingDefaults.sharedInstance().webApiSendDateFormat = DateFormat.ISO8601.rawValue
        JSONMappingDefaults.sharedInstance().dateFormat = DateFormat.ISO8601.rawValue
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
                "Accept-Encoding1": "deflate",
                "Accept-Encoding": "deflate"
        ]
        
        setupAppearances()
        
        if let user = User.userSavedOnDevice() {
            
            kActiveUser = user
        }
        else {
            
            setWindowToLogin()
        }
        
        //registerForLocalNotifications()
        
        return true
    }
    
    func registerForLocalNotifications() {
        
        var settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound, categories: ["NEW_PAYMENT"])
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        Defaults["Device_Token"] = deviceToken
        println(deviceToken.base64String())
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        println(userInfo)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        println(error)
    }
    
    func setupAppearances() {
        
        UINavigationBar.appearance().tintColor = kNavigationBarTintColor
        //UINavigationBar.appearance().barTintColor = kNavigationBarBarTintColor
        //UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(kNavigationBarBarTintColor, size: CGSize(width: 10, height: 10)), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().barStyle = kNavigationBarStyle
        
        UIToolbar.appearance().tintColor = kNavigationBarTintColor
        
        UITableViewCell.appearance().tintColor = kNavigationBarTintColor
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

